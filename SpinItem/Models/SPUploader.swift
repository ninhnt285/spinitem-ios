//
//  SPUploader.swift
//  SpinItem
//
//  Created by Nguyen Thanh Ninh on 3/5/18.
//  Copyright © 2018 TheBigDev Co., Ltd. All rights reserved.
//

import UIKit

class SPUploadFile: NSObject {
    var title: String?
    var destination: String?
    var size: Int64?
    var fileData: Data?
    
    convenience init(fileData: Data?) {
        self.init()
        self.fileData = fileData
    }
    
    convenience init(jsonData: [String: Any]) {
        self.init()
        self.saveFromJsonData(jsonData: jsonData)
    }
    
    func saveFromJsonData(jsonData: [String: Any]) {
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
    
    func uploadToServer(path: String, completion: @escaping (Error?) -> ()) {
        if let fileData = self.fileData {
            SPRequest.request().upload(path: path, data: fileData, completion: { (jsonData, err) in
                // Check any errors
                if let error = err {
                    completion(error)
                    return
                }
                // Save jsonData to Object
                self.saveFromJsonData(jsonData: jsonData!)
                completion(nil)
            })
        } else {
            completion(SPError.createErrorFromString(domain: "SPUploadFile.uploadToServer", errorText: "Data not set"))
        }
    }
}
