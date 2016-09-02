//
//  Constants.swift
//  On the Map
//
//  Created by Steven Chen on 4/9/16.
//  Copyright © 2016 Steven Chen. All rights reserved.
//

import Foundation

extension UdacityClient {
    
    // MARK: Constants
    struct Constants {
        
        // MARK: API Key
        static let ApiKey : String = "4e8bdccc3bb63cefbec21f936eca5651"
        
        // MARK: URLs
        static let ApiScheme = "https"
        static let ApiHost = "www.udacity.com/api"
        static let parseAppID = "QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr"
        static let RESTAPIKey = "QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY"

        // MARK: Login
        static var loggedIn = false
    }
    
    // MARK: Methods
    struct Methods {
        
        // MARK: Account
        static let Session = "/session"
    }
    
    // MARK: Parameter Keys
    struct ParameterKeys {
        static let ApiKey = "api_key"
        static let RequestToken = "request_token"
        static let Session = "session"
        static let Username = "username"
        static let Password = "password"
        
    }
    
    // MARK: Parameter Values
    struct ParameterValues {
        static let Session = "session"
    }
    
    // MARK: Response Keys
    struct ResponseKey {
        static let Account = "account"
        static let Registered = "registered"
        static let Key = "key"
    }
    

}