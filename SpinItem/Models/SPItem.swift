//
//  Item.swift
//  SpinItem
//
//  Created by Nguyen Thanh Ninh on 2/12/18.
//  Copyright © 2018 TheBigDev Co., Ltd. All rights reserved.
//

import Foundation

class SPItem: NSObject {
    var id: String?
    var userId: String?
    var title: String?
    var isActive: Bool?
    var backgroundUrl: String?
    var images: [String] = []
    
    convenience init(jsonData: [String: Any]) {
        self.init()
        self.saveFromJsonData(jsonData: jsonData)
    }
    
    func saveFromJsonData(jsonData: [String: Any]) {
        if let id = jsonData["id"] as? String {
            self.id = id
        }
        if let userId = jsonData["user_id"] as? String {
            self.userId = userId
        }
        if let title = jsonData["title"] as? String {
            self.title = title
        }
        if let isActive = jsonData["is_active"] as? Bool {
            self.isActive = isActive
        }
        if let backgroundUrl = jsonData["background_url"] as? String {
            self.backgroundUrl = backgroundUrl
        }
        if let images = jsonData["images"] as? [String] {
            self.images = images
        }
    }
    
    func convertToDictionary() -> [String: Any] {
        var result: [String: Any] = [:]
        if id != nil {
            result["id"] = id
        }
        if userId != nil {
            result["user_id"] = userId
        }
        if title != nil {
            result["title"] = title
        }
        if isActive != nil {
            result["is_active"] = isActive
        }
        if backgroundUrl != nil {
            result["background_url"] = backgroundUrl
        }
        result["images"] = images
        return result
    }
    
    // Save Item to server
    func addToServer(completion: @escaping (Error?) -> ()) {
        if title == nil {
            self.title = "New Item"
        }
        SPRequest.request().send(path: "/items", type: SPRequestType.POST, data: self.convertToDictionary()) { (result, err) in
            // Check any errors
            if (err != nil) {
                completion(err)
                return
            }
            // Get new item with id
            self.saveFromJsonData(jsonData: result!)
            completion(nil)
        }
    }
    
    // Update Item to server
    func updateToServer(completion: @escaping (Error?) -> ()) {
        if let itemId = self.id {
            SPRequest.request().send(path: "/items/\(itemId)", type: SPRequestType.PUT, data: self.convertToDictionary()) { (result, err) in
                // Check any errors
                if (err != nil) {
                    completion(err)
                    return
                }
                // Get new item with id
                self.saveFromJsonData(jsonData: result!)
                completion(nil)
            }
        } else {
            completion(SPError.createErrorFromString(domain: "SPItem.updateToServer", errorText: "This item didn't have ID"))
        }
    }
    
    func deleteToServer(completion: @escaping (Error?) -> ()) {
        if let itemId = self.id {
            SPRequest.request().send(path: "/items/\(itemId)", type: SPRequestType.DELETE) { (result, err) in
                // Check any errors
                if (err != nil) {
                    completion(err)
                    return
                }
                completion(nil)
            }
        } else {
            completion(SPError.createErrorFromString(domain: "SPItem.deleteToServer", errorText: "This item didn't have ID"))
        }
    }
    
    func getItem(completion: @escaping (Error?) -> ()) {
        if let id = self.id {
            SPRequest.request().send(path: "/items/\(id)", type: SPRequestType.GET, completion: { (jsonData, err) in
                // Check any errors
                if let error = err {
                    completion(error)
                    return
                }
                // Parse JSON Data to Item
                self.saveFromJsonData(jsonData: jsonData!)
                completion(nil)
            })
        } else {
            completion(SPError.createErrorFromString(domain: "SPItem.getItem", errorText: "Item didn't have ID"))
        }
    }
    
    // Get all items of current user
    class func getAllItems(completion: @escaping ([SPItem]?, Error?) -> ()) {
        SPRequest.request().send(path: "/items", type: SPRequestType.GET) { (result, err) in
            // Check all errors
            if let error = err {
                completion(nil, error)
                return
            }
            // Parse result to items
            var items = [SPItem]()
            if let jsonItems = result!["items"] as? [[String: Any]] {
                for jsonItem in jsonItems {
                    items.append(SPItem(jsonData: jsonItem))
                }
            }
            completion(items, nil)
        }
    }
    
    // Printable
    override var description: String {
        get {
            return "ItemId: \(self.id ?? "Unknown Id")"
        }
    }
}
