//
//  SPError.swift
//  SpinItem
//
//  Created by Nguyen Thanh Ninh on 3/4/18.
//  Copyright © 2018 TheBigDev Co., Ltd. All rights reserved.
//

import Foundation

class SPError: NSObject {
    class func createErrorFromString(domain: String, errorText: String) -> Error {
        return NSError(domain: domain, code: 1, userInfo: [NSLocalizedDescriptionKey : errorText])
    }
}
