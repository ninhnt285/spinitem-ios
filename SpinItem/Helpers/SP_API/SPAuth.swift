//
//  Auth.swift
//  SpinItem
//
//  Created by Nguyen Thanh Ninh on 3/3/18.
//  Copyright © 2018 TheBigDev Co., Ltd. All rights reserved.
//

import Foundation

class SPAuth: NSObject {
    let sb = Strongbox()
    var currentUser: SPUser? = nil
    var accessToken: String? = nil
    
    private static var sharedSPAuth: SPAuth = {
        let authInstance = SPAuth()
        return authInstance
    }()
    
    private override init() {
        super.init()
        if let accessToken = sb.unarchive(objectForKey: "accessToken") as? String {
            self.accessToken = accessToken
        }
        
        if let currentUserData = sb.unarchive(objectForKey: "currentUserData") as? [String: Any] {
            self.currentUser = SPUser(jsonData: currentUserData)
        }
    }
    
    class func auth() -> SPAuth {
        return sharedSPAuth
    }
    
    func signIn(withEmail email: String, password: String, completion: @escaping (SPUser?, Error?) -> ()) {
        SPRequest.request().send(path: "/login", type: SPRequestType.POST, data: ["email" : email, "password": password]) { (returnData, error) in
            // check for any errors
            if let err = error {
                completion(nil, err)
                return
            }
            // Get accessToken
            if let accessToken = returnData!["token"] as? String {
                self.accessToken = accessToken
                // Save token to KeyChain API
                _ = self.sb.archive(accessToken, key: "accessToken")
                // Get user detail
                SPRequest.request().send(path: "/users/me", type: SPRequestType.GET, completion: { (userData, error) in
                    if let err = error {
                        completion(nil, err)
                        return
                    }
                    _ = self.sb.archive(userData, key: "currentUserData")
                    self.currentUser = SPUser(jsonData: userData!)
                    completion(self.currentUser, error)
                })
                return
            }
            // Throw unknown error
            completion(nil, SPError.createErrorFromString(domain: "SPAuth.signIn", errorText: "Unknow error"))
        }
    }
    
    func createUser(withEmail email: String, username: String, password: String, completion: @escaping (SPUser?, Error?) -> ()) {
        let newUserPostData: [String: Any] = [
            "email": email,
            "username": username,
            "password": password
        ]
        SPRequest.request().send(path: "/register", type: SPRequestType.POST, data: newUserPostData) { (returnData, error) in
            // check for any errors
            if let err = error {
                completion(nil, err)
                return
            }
            // Get accessToken
            if let accessToken = returnData!["token"] as? String {
                self.accessToken = accessToken
                // Save token to KeyChain API
                _ = self.sb.archive(accessToken, key: "accessToken")
                // Get user detail
                SPRequest.request().send(path: "/users/me", type: SPRequestType.GET, completion: { (userData, error) in
                    if let err = error {
                        completion(nil, err)
                        return
                    }
                    _ = self.sb.archive(userData, key: "currentUserData")
                    self.currentUser = SPUser(jsonData: userData!)
                    completion(self.currentUser, error)
                })
                return
            }
            // Throw unknown error
            completion(nil, SPError.createErrorFromString(domain: "SPAuth.signIn", errorText: "Unknow error"))
        }
    }
    
    func signOut() throws {
        self.currentUser = nil
        self.accessToken = nil
        if !sb.archive(nil, key: "accessToken") || !sb.archive(nil, key: "currentUserData") {
            throw SPError.createErrorFromString(domain: "SPAuth.signOut", errorText: "Unknown error")
        }
    }
}
