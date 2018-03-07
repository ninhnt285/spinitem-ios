//
//  Image.swift
//  SpinItem
//
//  Created by Nguyen Thanh Ninh on 2/12/18.
//  Copyright © 2018 TheBigDev Co., Ltd. All rights reserved.
//

import Foundation

class SPImage: NSObject {
    var id: String?
    var itemId: String?
    var index: Int?
    var captureIndex: Int?
    var isActive: Bool?
    var title: String?
    var destination: String?
    var size: Int64?
    // Not in server
    var isNeedUpdate: Bool = true
    var fileData: Data?
    
    convenience init(jsonData: [String: Any], isNeedUpdate: Bool = true) {
        self.init()
        self.saveFromJsonData(jsonData: jsonData)
        self.isNeedUpdate = isNeedUpdate
    }
    
    func saveFromJsonData(jsonData: [String: Any]) {
        if let id = jsonData["id"] as? String {
            self.id = id
        }
        if let itemId = jsonData["item_id"] as? String {
            self.itemId = itemId
        }
        if let index = jsonData["index"] as? Int {
            self.index = index
        }
        if let captureIndex = jsonData["capture_index"] as? Int {
            self.captureIndex = captureIndex
        }
        if let isActive = jsonData["is_active"] as? Bool {
            self.isActive = isActive
        }
        if let title = jsonData["title"] as? String {
            self.title = title
        }
        if let destination = jsonData["destination"] as? String {
            self.destination = destination
        }
        if let size = jsonData["size"] as? Int64 {
            self.size = size
        }
    }
    
    func convertToDictionary() -> [String: Any] {
        var result: [String: Any] = [:]
        if id != nil {
            result["id"] = id
        }
        if itemId != nil {
            result["item_id"] = itemId
        }
        if index != nil {
            result["index"] = index
        }
        if captureIndex != nil {
            result["capture_index"] = captureIndex
        }
        if isActive != nil {
            result["is_active"] = isActive
        }
        if title != nil {
            result["title"] = title
        }
        if destination != nil {
            result["destination"] = destination
        }
        if size != nil {
            result["size"] = size
        }
        return result
    }
    
    class func getAllByItemId(itemId: String, completion: @escaping ([SPImage]?, Error?) -> ()) {
        SPRequest.request().send(path: "/images?item_id=\(itemId)", type: SPRequestType.GET) { (result, err) in
            // Check for any errors
            if let error = err {
                completion(nil, error)
                return
            }
            // Parse images
            var images = [SPImage]()
            if let jsonImages = result!["images"] as? [[String: Any]] {
                for jsonImage in jsonImages {
                    let image = SPImage(jsonData: jsonImage, isNeedUpdate: false)
                    images.append(image)
                }
            }
            completion(images, nil)
        }
    }
    
    func addToServer(completion: @escaping (Error?) -> ()) {
        if let fileData = self.fileData {
            let uploadFile = SPUploadFile(fileData: fileData)
            uploadFile.uploadToServer(path: "/images/upload", completion: { (err) in
                // Check any errors
                if let error = err {
                    completion(error)
                    return
                }
                // Save File Info to Image
                self.saveFromJsonData(jsonData: uploadFile.convertToDictionary())
                // Upload to server and get ID
                SPRequest.request().send(path: "/images", type: SPRequestType.POST, data: self.convertToDictionary(), completion: { (jsonData, err) in
                    // Check any errors
                    if let error = err {
                        completion(error)
                        return
                    }
                    // Save ID to SPImage Object
                    self.saveFromJsonData(jsonData: jsonData!)
                    completion(nil)
                })
            })
        } else {
            completion(SPError.createErrorFromString(domain: "SPImage.uploadImage", errorText: "Image didn't have data"))
        }
    }
    
    func loadImageDataFromServer(completion: @escaping(Error?) -> ()) {
        if self.fileData != nil {
            completion(nil)
            return
        }
        if let destination = self.destination {
            SPRequest.request().downloadFile(path: destination, completion: { (data, err) in
                if let error = err {
                    completion(error)
                    return
                }
                self.fileData = data
                completion(nil)
            })
        } else {
            completion(SPError.createErrorFromString(domain: "SPImage.loadImageDataFromServer", errorText: "Image didn't have URL Destination"))
        }
    }
    
    override var description: String {
        get {
            return "ImageId: \(self.id ?? "Unknown Id")"
        }
    }
}
