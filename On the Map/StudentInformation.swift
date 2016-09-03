//
//  StudentInformation.swift
//  On the Map
//
//  Created by Steven Chen on 9/2/16.
//  Copyright © 2016 Steven Chen. All rights reserved.
//

struct StudentInformation {
    
    let uniqueKey:String!
    let firstName:String!
    let lastName:String!
    let mediaURL:String!
    let mapString:String!
    let latitude:Double!
    let longitude:Double!
    
    init(studentDictionary:[String:AnyObject]){
        self.uniqueKey = studentDictionary["uniqueKey"] as! String
        self.firstName = studentDictionary["firstName"] as! String
        self.lastName = studentDictionary["lastName"] as! String
        self.mediaURL = studentDictionary["mediaURL"] as! String
        self.mapString = studentDictionary["mapString"] as! String
        self.longitude = studentDictionary["latitude"] as! Double
        self.latitude = studentDictionary["longitude"] as! Double
    }
}

