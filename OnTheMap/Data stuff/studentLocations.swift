//
//  studentLocations.swift
//  OnTheMap
//
//  Created by Zabe Rauf on 5/22/18.
//  Copyright © 2018 Zaben. All rights reserved.
//

import Foundation

struct studentLocations {
    static var shared = studentLocations()
    
    // makes error with shared go away. Got help with this on
    init() {
        
    }
    
    var firstName: String!
    var lastName: String!
    var mediaURL: String!
    var latitude: Double!
    var longitude: Double!
    var mapString: String?
    var uniqueKey: String!
    
    init(_ results: [String:AnyObject]) {
        self.firstName = results["firstName"] as! String
        self.lastName = results["lastName"] as! String
        self.latitude = results["latitude"] as! Double
        self.longitude = results["longitude"] as! Double
        self.mapString = results["mapString"] as? String
        self.uniqueKey = results["uniqueKey"] as! String
        self.mediaURL = results["mediaURL"] as! String
    }
    
    // Dictionary of student locations information. Gather's the student data and stores
    // it into an object of type studentLocations() then append it into the studentLocationList array.
    
    mutating func build(_ results: AnyObject) -> [studentLocations] {
        var studentLocationList = [studentLocations]()
        for dictionary in results[JSONResponseKeys.Results] as! [[String:AnyObject]] {
            
            guard let _ = dictionary["latitude"] as? Double, let _ = dictionary["longitude"] as? Double else {
                continue
            }
            
            guard let _ = dictionary["firstName"] as? String, let _ = dictionary["lastName"] as? String else {
                continue
            }
            
            guard (dictionary["mediaURL"] as? String) != nil else{
                continue
            }
            
            guard let _ = dictionary["uniqueKey"] as? String else {
                continue
            }
            
            let studentLocation = studentLocations(dictionary)
            studentLocationList.append(studentLocation)
        }
        return studentLocationList
    }
    
    // getName() can retrieve the student name if needed and return it as a string
    
    func getName() -> String {
        return "\(self.firstName!) \(self.lastName!)"
    }
    
    func buildJSONBody(mediaURL: String, latitude: Double, longitude: Double) -> String{
        var jsonBody = HttpBody.LocationBody
        
        jsonBody = jsonBody.replacingOccurrences(of: JSONBodyValue.MediaURL, with: mediaURL)
        jsonBody = jsonBody.replacingOccurrences(of: JSONBodyValue.LastName, with: accountInfo.shared.lastName!)
        jsonBody = jsonBody.replacingOccurrences(of: JSONBodyValue.FirstName, with: accountInfo.shared.firstName!)
        jsonBody = jsonBody.replacingOccurrences(of: JSONBodyValue.Latitude, with: "\(latitude)")
        jsonBody = jsonBody.replacingOccurrences(of: JSONBodyValue.Longitude, with: "\(longitude)")
        jsonBody = jsonBody.replacingOccurrences(of: JSONBodyValue.MapString, with: "")
        jsonBody = jsonBody.replacingOccurrences(of: JSONBodyValue.uniqueKey, with: accountInfo.shared.userId!)
        jsonBody = jsonBody.replacingOccurrences(of: JSONBodyValue.MediaURL, with: mediaURL)
        
        return jsonBody
    }
}
