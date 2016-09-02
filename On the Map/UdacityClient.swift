//
//  UdacityClient.swift
//  On the Map
//
//  Created by Steven Chen on 4/9/16.
//  Copyright © 2016 Steven Chen. All rights reserved.
//

import Foundation

class UdacityClient : NSObject {

    func authentiation(username:String, password:String, completionHandler: (success: Bool, ID:String, errorString: String?) -> Void) {
        
        let request = NSMutableURLRequest(URL: NSURL(string: "https://www.udacity.com/api/session")!)
        request.HTTPMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.HTTPBody = "{\"udacity\": {\"username\": \"\(username)\", \"password\": \"\(password)\"}}".dataUsingEncoding(NSUTF8StringEncoding)

        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request) {data, response, error in
            if error != nil { // Handle error…
                return
            }
         
            let newData = data!.subdataWithRange(NSMakeRange(5, data!.length - 5)) /* subset response data! */
            
            let parsedResult: AnyObject!

            do {
                parsedResult = try NSJSONSerialization.JSONObjectWithData(newData, options: .AllowFragments)
            } catch {
                print("Could not parse the data as JSON: '\(data)'")
                
                return
            }
            print(parsedResult)
            guard let account = parsedResult[UdacityClient.ResponseKey.Account] as? [String:AnyObject] else {
                print("no account found")
                return
            }
            print(account)
            guard let registered = account[UdacityClient.ResponseKey.Registered] as? Bool else {
                print("account not found")
                return
            }

            guard let key = account[UdacityClient.ResponseKey.Key] as? String else {
                print("key not found")
                return
            }
           
            print(account)
            completionHandler(success: registered, ID:key, errorString: "no error")
        }
        task.resume()
    }
    
    func getUserData(uniqueKey:String, completionHandler: (firstName: String, lastName:String, errorString: String?) -> Void){
        let request = NSMutableURLRequest(URL: NSURL(string: "https://www.udacity.com/api/users/"+uniqueKey)!)
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request) { data, response, error in
            if error != nil { // Handle error...
                return
            }
            let newData = data!.subdataWithRange(NSMakeRange(5, data!.length - 5)) /* subset response data! */
            
            let parsedResult: AnyObject!
            
            do {
                parsedResult = try NSJSONSerialization.JSONObjectWithData(newData, options: .AllowFragments)
            } catch {
                print("Could not parse the data as JSON: '\(data)'")
                
                return
            }
            
            guard let user = parsedResult["user"] as? [String:AnyObject] else {
                print("User info not found")
                return
            }

            guard let firstName = user["first_name"] as? String else {
                print("First name not found")
                return
            }
            
            guard let lastName = user["last_name"] as? String else {
                print("Last name not found")
                return
            }

            completionHandler(firstName: firstName, lastName: lastName, errorString: nil)
        }
        task.resume()
    }
    
    func queryForExistingData(uniqueKey:String, completionHandler: (success: Bool, objectId:String, errorString: String?) -> Void){
     
        let urlString = "https://api.parse.com/1/classes/StudentLocation?where=%7B%22uniqueKey%22%3A%22\(uniqueKey)%22%7D"
        let url = NSURL(string: urlString)
        print(url)
        let request = NSMutableURLRequest(URL: url!)
        request.addValue("QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr", forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue("QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY", forHTTPHeaderField: "X-Parse-REST-API-Key")
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request) { data, response, error in
            if error != nil {
                print("no user data found")
                return
            }
          //  print(NSString(data: data!, encoding: NSUTF8StringEncoding))
            
            let parsedResult: AnyObject!
       //     let newData = data!.subdataWithRange(NSMakeRange(5, data!.length - 5)) /* subset response data! */

            do {
                parsedResult = try NSJSONSerialization.JSONObjectWithData(data!, options: .AllowFragments)
            } catch {
                print("Could not parse the data as JSON: '\(data)'")
                
                return
            }
            
            guard let results = parsedResult["results"]!![0] as? [String:AnyObject] else{
                print("no results found")
                completionHandler(success: false, objectId: "", errorString:"Did not find an exisiting objectId")
                
                return
            }
         
            guard let objectID = results["objectId"] as? String else{
                print("no object ID found")
                completionHandler(success: false, objectId: "", errorString:"Did not find an exisiting objectId")
                
                return
            }
           completionHandler(success: true, objectId:objectID, errorString: nil)
        }
        task.resume()
    }
    
    // create a URL from parameters
     func udacityURLFromParameters(parameters: [String:AnyObject]) -> NSURL {
        
        let components = NSURLComponents()
        components.scheme = UdacityClient.Constants.ApiScheme
        components.host = UdacityClient.Constants.ApiHost
        components.queryItems = [NSURLQueryItem]()
        
        for (key, value) in parameters {
            let queryItem = NSURLQueryItem(name: key, value: "\(value)")
            components.queryItems!.append(queryItem)
        }
        
        return components.URL!
    }
    
    
    // MARK: Shared Instance
    class func sharedInstance() -> UdacityClient {
        struct Singleton {
            static var sharedInstance = UdacityClient()
        }
        return Singleton.sharedInstance
    }
}
