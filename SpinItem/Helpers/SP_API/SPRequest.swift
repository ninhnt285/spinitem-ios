//
//  SPRequest.swift
//  SpinItem
//
//  Created by Nguyen Thanh Ninh on 3/3/18.
//  Copyright © 2018 TheBigDev Co., Ltd. All rights reserved.
//

import Foundation

enum SPRequestType: String {
    case GET
    case POST
    case PUT
    case DELETE
}

class SPRequestReturn: NSObject {
    
}

class SPRequest: NSObject {
    private static var sharedSPRequest: SPRequest = {
        let requestInstance = SPRequest()
        return requestInstance
    }()
    
    class func request() -> SPRequest {
        return sharedSPRequest
    }
    
    let sb = Strongbox()
    
    override init() {
        super.init()
        accessToken = sb.unarchive(objectForKey: "accessToken") as? String
    }
    
    let apiUrl = "http://api.spinitem.com"
    var accessToken: String?
    
    func parseResultData(data: [String: Any], completion: @escaping ([String: Any]?, Error?)-> ()) {
        // Check error when server return
        if let error = data["error"] as? [String: Any] {
            if let message = error["message"] as? String {
                completion(nil, SPError.createErrorFromString(domain: "PSRequest.parseResultData", errorText: message))
                return
            }
        }
        // Return main data result
        if let resultData = data["data"] as? [String: Any] {
            completion(resultData, nil)
            return
        }
        // Throw any errors
        completion(nil, SPError.createErrorFromString(domain: "PSRequest.parseResultData", errorText: "Unknown Error"))
        return
    }
    
    /**
     Convenience method of send(path: String, type: SPRequestType, data: [String: Any]?, ...)
     Using for GET / DELETE method
     */
    func send(path: String, type: SPRequestType, completion: @escaping ([String: Any]?, Error?) -> ()) {
        self.send(path: path, type: type, data: nil, completion: completion)
    }
    
    /**
     Send request to server
     */
    func send(path: String, type: SPRequestType, data: [String: Any]?, completion: @escaping ([String: Any]?, Error?) -> ()) {
        // Make sure got valid URL
        guard let url = URL(string: apiUrl + path) else {
            completion(nil, SPError.createErrorFromString(domain: "SPRequest.send", errorText: "Invalid URL"))
            return
        }
        // Set up URL Request
        var request = URLRequest(url: url)
        request.httpMethod = type.rawValue
        do {
            if let _ = data {
                let jsonData = try JSONSerialization.data(withJSONObject: data!, options: [])
                request.httpBody = jsonData
            }
        } catch {
            completion(nil, SPError.createErrorFromString(domain: "SPRequest.send", errorText: "Error parse POST data"))
            return
        }
        request.addValue("Bearer " + (SPAuth.auth().accessToken ?? ""), forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        // Make the request
        let task = URLSession.shared.dataTask(with: request, completionHandler: { (data, response, err) in
            // Check for any errors
            guard err == nil else {
                completion(nil, SPError.createErrorFromString(domain: "SPRequest.send", errorText: "Error calling request"))
                return
            }
            // Make sure we got data
            guard let responseData = data else {
                completion(nil, SPError.createErrorFromString(domain: "SPRequest.send", errorText: "Did not receive data"))
                return
            }
            // Parse the result to JSON
            do {
                guard let jsonData = try JSONSerialization.jsonObject(with: responseData, options: []) as? [String: Any] else {
                    completion(nil, SPError.createErrorFromString(domain: "SPRequest.send", errorText: "Error trying to convert data to JSON 1"))
                    return
                }
                self.parseResultData(data: jsonData, completion: completion)
            } catch {
                completion(nil, SPError.createErrorFromString(domain: "SPRequest.send", errorText: "Error trying to convert data to JSON 2"))
            }
        })
        task.resume()
    }
    /**
     Upload file to server, and got info of saved file
     */
    func upload(path: String, data: Data, completion: @escaping ([String: Any]?, Error?) -> ()) {
        // Make sure got valid URL
        guard let url = URL(string: apiUrl + path) else {
            completion(nil, SPError.createErrorFromString(domain: "SPRequest.upload", errorText: "Invalid URL"))
            return
        }
        // Prepare HTTP Body Request
        let boundary = "Boundary-\(UUID().uuidString)"
        var body = Data()
        let mimetype = "image/jpg"
        body.append(Data("--\(boundary)\r\n".utf8))
        body.append(Data("Content-Disposition: form-data; name=\"file\"; filename=\"\(UUID().uuidString).jpg\"\r\n".utf8))
        body.append(Data("Content-Type: \(mimetype)\r\n\r\n".utf8))
        body.append(data)
        body.append(Data("\r\n".utf8))
        body.append(Data("--\(boundary)\r\n".utf8))
        // Set up URL Request
        var request = URLRequest(url: url)
        request.httpMethod = SPRequestType.POST.rawValue
        request.httpBody = body
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer " + (SPAuth.auth().accessToken ?? ""), forHTTPHeaderField: "Authorization")
        // Make the request
        let task = URLSession.shared.dataTask(with: request, completionHandler: { (data, response, err) in
            // Check for any errors
            guard err == nil else {
                completion(nil, SPError.createErrorFromString(domain: "SPRequest.upload", errorText: "Error calling request"))
                return
            }
            // Make sure we got data
            guard let responseData = data else {
                completion(nil, SPError.createErrorFromString(domain: "SPRequest.upload", errorText: "Did not receive data"))
                return
            }
            // Parse the result to JSON
            do {
                guard let jsonData = try JSONSerialization.jsonObject(with: responseData, options: []) as? [String: Any] else {
                    completion(nil, SPError.createErrorFromString(domain: "SPRequest.upload", errorText: "Error trying to convert data to JSON 1"))
                    return
                }
                self.parseResultData(data: jsonData, completion: completion)
            } catch {
                completion(nil, SPError.createErrorFromString(domain: "SPRequest.upload", errorText: "Error trying to convert data to JSON 2"))
            }
        })
        task.resume()
    }
    
    /**
     Download Image Data
     */
    func downloadFile(path: String, completion: @escaping (Data?, Error?) -> ()) {
        // Make sure got valid URL
        guard let url = URL(string: path) else {
            completion(nil, SPError.createErrorFromString(domain: "SPRequest.downloadFile", errorText: "Invalid URL"))
            return
        }
        URLSession.shared.dataTask(with: url) { data, response, error in
            completion(data, error)
        }.resume()
    }
}
