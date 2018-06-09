//
//  accountInfo.swift
//  OnTheMap
//
//  Created by Zabe Rauf on 5/22/18.
//  Copyright © 2018 Zaben. All rights reserved.
//

import Foundation

struct accountInfo {
    static var shared = accountInfo()
    
    var sessionID: String?
    var userId: String?
    var firstName: String?
    var lastName: String?
    
    func getFullName() -> String {
        return "\(firstName!) \(lastName!)"
    }
}
