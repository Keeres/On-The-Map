//
//  Students.swift
//  On the Map
//
//  Created by Steven Chen on 4/11/16.
//  Copyright © 2016 Steven Chen. All rights reserved.
//

import Foundation

struct Students {
    
    let uniqueKey:String!
    let firstName:String!
    let lastName:String!
    let mediaURL:String!
    let mapString:String!
    let latitude:Double!
    let longitude:Double!
    
    init(uniqueKey:String, firstName:String, lastName:String, mediaURL:String, mapString:String, latitude:Double, longitude:Double){
        self.uniqueKey = uniqueKey
        self.firstName = firstName
        self.lastName = lastName
        self.mediaURL = mediaURL
        self.mapString = mapString
        self.longitude = longitude
        self.latitude = latitude
    }
}