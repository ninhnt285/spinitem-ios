//
//  Image.swift
//  SpinItem
//
//  Created by Nguyen Thanh Ninh on 2/12/18.
//  Copyright © 2018 TheBigDev Co., Ltd. All rights reserved.
//

import Foundation
import UIKit

class SPImage: NSObject {
    var id: String?
    var itemId: String?
    var index: Int?
    var captureIndex: Int?
    var isActive: Bool?
    var pitch: Float?
    var roll: Float?
    var yaw: Float?
    // File
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
        if let pitch = jsonData["pitch"] as? Float {
            self.pitch = pitch
        }
        if let roll = jsonData["roll"] as? Float {
            self.roll = roll
        }
        if let yaw = jsonData["yaw"] as? Float {
            self.yaw = yaw
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
        if pitch != nil {
            result["pitch"] = pitch
        }
        if roll != nil {
            result["roll"] = roll
        }
        if yaw != nil {
            result["yaw"] = yaw
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
        // Find max screen size
        let maxScreenSize = max(UIScreen.main.bounds.size.width, UIScreen.main.bounds.size.height)
        var maxImageSize = 1000
        switch maxScreenSize {
        case let x where x < 500:
            maxImageSize = 500
        case let x where x < 700:
            maxImageSize = 750
        default:
            maxImageSize = 1000
        }
        
        if let destination = self.destination {
            SPRequest.request().downloadFile(path: "http:" + destination.replacingOccurrences(of: "%s", with: "_\(maxImageSize)x\(maxImageSize)"), completion: { (data, err) in
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
            return "SPImage: \(self.convertToDictionary())"
        }
    }
}
