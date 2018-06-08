//
//  SPUser.swift
//  SpinItem
//
//  Created by Nguyen Thanh Ninh on 3/3/18.
//  Copyright © 2018 TheBigDev Co., Ltd. All rights reserved.
//

import Foundation

class SPUser: NSObject {
    var id: String?
    var username: String?
    var email: String?
    
    convenience init(jsonData: [String: Any]) {
        self.init()
        self.saveFromJsonData(jsonData: jsonData)
    }
    
    func saveFromJsonData(jsonData: [String: Any]) {
        if let id = jsonData["id"] as? String {
            self.id = id
        }
        if let username = jsonData["username"] as? String {
            self.username = username
        }
        if let email = jsonData["email"] as? String {
            self.email = email
        }
    }
    
    func convertToDictionary() -> [String: Any] {
        var result: [String: Any] = [:]
        if id != nil {
            result["id"] = id
        }
        if username != nil {
            result["username"] = username
        }
        if email != nil {
            result["email"] = email
        }
        return result
    }
    
    override var description: String {
        get {
            return "SPUser: \(self.convertToDictionary())"
        }
    }
}
