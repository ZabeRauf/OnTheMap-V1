//
//  dataSource.swift
//  OnTheMap
//
//  Created by Zabe Rauf on 5/22/18.
//  Copyright © 2018 Zaben. All rights reserved.
//

import Foundation

class dataSource {
    var studentData = [studentLocations]()
    static let sharedInstance = dataSource()
    private init() { } 
}
