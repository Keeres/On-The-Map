//
//  UdacityClient.swift
//  On the Map
//
//  Created by Steven Chen on 4/9/16.
//  Copyright © 2016 Steven Chen. All rights reserved.
//

import UIKit

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
                completionHandler(success: false, ID:" ", errorString: "Failure to Connect")
                return
            }
         
            let newData = data!.subdataWithRange(NSMakeRange(5, data!.length - 5)) /* subset response data! */
            guard let httpResponse = response as? NSHTTPURLResponse else {
                print("error: not a valid http response")
                return
            }
            print(httpResponse.statusCode)
            
            switch (httpResponse.statusCode) {
            case 400:
                completionHandler(success: false, ID:" ", errorString: "Please enter an username or password")
                
            case 403:
                completionHandler(success: false, ID:" ", errorString: "Invalid username or password")

            default:
                let parsedResult: AnyObject!
                
                do {
                    parsedResult = try NSJSONSerialization.JSONObjectWithData(newData, options: .AllowFragments)
                } catch {
                    print("Error parsing JSON data '\(data)'")
                    
                    return
                }

                guard let account = parsedResult[UdacityClient.ResponseKey.Account] as? [String:AnyObject] else {
                    print("error locating account")
                    return
                }
                print(account)
                guard let registered = account[UdacityClient.ResponseKey.Registered] as? Bool else {
                    print("account not registered")
                    return
                }
                
                guard let key = account[UdacityClient.ResponseKey.Key] as? String else {
                    print("key not found")
                    return
                }
                
                completionHandler(success: registered, ID:key, errorString: "no error")
            }
          
        }
        task.resume()
    }
    
    func getUserData(uniqueKey:String, completionHandler: (success: Bool, firstName: String, lastName:String, errorString: String?) -> Void){
        let request = NSMutableURLRequest(URL: NSURL(string: "https://www.udacity.com/api/users/"+uniqueKey)!)
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request) { data, response, error in
            if error != nil { // Handle error...
                completionHandler(success: false, firstName: " ",lastName: " ", errorString: "Error Retrieving User Information")
                return
            }
            
            let newData = data!.subdataWithRange(NSMakeRange(5, data!.length - 5))
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
            
            completionHandler(success: true, firstName: firstName, lastName: lastName, errorString: nil)
        }
        task.resume()
    }

    
    func getStudentLocationsRequest( completionHandler: (success: Bool, studentLocations:[[String:AnyObject]], errorString: String?) -> Void) {
        
        let request = NSMutableURLRequest(URL: NSURL(string: "https://parse.udacity.com/parse/classes/StudentLocation?limit=100")!)
        request.addValue("QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr", forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue("QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY", forHTTPHeaderField: "X-Parse-REST-API-Key")
        let session = NSURLSession.sharedSession()
        
        let task = session.dataTaskWithRequest(request) { data, response, error in
            if error != nil {
                completionHandler(success: false, studentLocations:[[:]], errorString: "Error Retrieving Student Locations")
                return
            }
            
            let parsedResult: AnyObject!
            
            do {
                parsedResult = try NSJSONSerialization.JSONObjectWithData(data!, options: .AllowFragments) as? [String:AnyObject]
            } catch {
                print("Could not parse the data as JSON: '\(data)'")
                return
            }
                        
            guard let studentLocations = parsedResult["results"] as? [[String:AnyObject]] else {
                print("no account found")
                return
            }
            completionHandler(success: true, studentLocations:studentLocations, errorString: nil)
        }
        task.resume()
    }
    
    
    
    func queryForExistingData(uniqueKey:String, completionHandler: (success: Bool, objectId:String, errorString: String?) -> Void){
     
        let urlString = "https://parse.udacity.com/parse/classes/StudentLocation?where=%7B%22uniqueKey%22%3A%22\(uniqueKey)%22%7D"
        let url = NSURL(string: urlString)
        print(url)
        let request = NSMutableURLRequest(URL: url!)
        request.addValue("QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr", forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue("QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY", forHTTPHeaderField: "X-Parse-REST-API-Key")
        let session = NSURLSession.sharedSession()
        
        let task = session.dataTaskWithRequest(request) { data, response, error in
            if error != nil {
                completionHandler(success: false, objectId: "", errorString:"Error retrieving user data")
                return
            }
           print(NSString(data: data!, encoding: NSUTF8StringEncoding))
            
            guard let httpResponse = response as? NSHTTPURLResponse else {
                print("error: not a valid http response")
                return
            }
            print(httpResponse.statusCode)

            let parsedResult: AnyObject!

            do {
                parsedResult = try NSJSONSerialization.JSONObjectWithData(data!, options: .AllowFragments)
            } catch {
                print("Could not parse the data as JSON: '\(data)'")
                return
            }

            guard let results = parsedResult["results"] as? [[String:AnyObject]] else{
                print("No objectID Found")
                completionHandler(success: false, objectId: "", errorString:"")
                
                return
            }
         print(results)
            guard let objectID = results[0]["objectId"] as? String else{
                print("No objectID Found")
                completionHandler(success: false, objectId: "", errorString:"")
                
                return
            }
           completionHandler(success: true, objectId:objectID, errorString: nil)
        }
        task.resume()
    }
    
    func postUserInformation(uniqueKey:String, firstName:String, lastName:String, mapString:String, mediaURL:String, latitude:Double, longitude:Double, completionHandler: (success: Bool, objectId:String, errorString: String?) -> Void){
        
        let request = NSMutableURLRequest(URL: NSURL(string: "https://parse.udacity.com/parse/classes/StudentLocation")!)
        request.HTTPMethod = "POST"
        request.addValue("QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr", forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue("QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY", forHTTPHeaderField: "X-Parse-REST-API-Key")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        request.HTTPBody = "{\"uniqueKey\": \"\(uniqueKey)\", \"firstName\": \"\(firstName)\", \"lastName\": \"\(lastName)\",\"mapString\": \"\(mapString)\", \"mediaURL\": \"\(mediaURL)\",\"latitude\": \(latitude), \"longitude\": \(longitude)}".dataUsingEncoding(NSUTF8StringEncoding)
        
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request) { data, response, error in
            if error != nil { // Handle error…
                completionHandler(success: false, objectId: "", errorString:"Error retrieving user data")
                return
            }
            let parsedResult: AnyObject!
            
            do {
                parsedResult = try NSJSONSerialization.JSONObjectWithData(data!, options: .AllowFragments)
            } catch {
                print("Could not parse the data as JSON: '\(data)'")
                return
            }
            
            guard let objectID = parsedResult["objectId"] as? String else{
                completionHandler(success: false, objectId: "", errorString:"Error posting user information")
                
                return
            }
            completionHandler(success: true, objectId: objectID, errorString:nil)
        }
        task.resume()
    }

    func updateUserInformation(uniqueKey:String, firstName:String, lastName:String, mapString:String, mediaURL:String, latitude:Double, longitude:Double, completionHandler: (success: Bool, errorString: String?) -> Void){
        
        let urlString = "https://parse.udacity.com/parse/classes/StudentLocation/8ZExGR5uX8"
        let url = NSURL(string: urlString)
        let request = NSMutableURLRequest(URL: url!)
        request.HTTPMethod = "PUT"
        request.addValue("QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr", forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue("QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY", forHTTPHeaderField: "X-Parse-REST-API-Key")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        request.HTTPBody = "{\"uniqueKey\": \"\(uniqueKey)\", \"firstName\": \"\(firstName)\", \"lastName\": \"\(lastName)\",\"mapString\": \"\(mapString)\", \"mediaURL\": \"\(mediaURL)\",\"latitude\": \(latitude), \"longitude\": \(longitude)}".dataUsingEncoding(NSUTF8StringEncoding)

        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request) { data, response, error in
            if error != nil { // Handle error…
                completionHandler(success: false, errorString:"Error retrieving user data")
                return
            }
            let parsedResult: AnyObject!
            
            do {
                parsedResult = try NSJSONSerialization.JSONObjectWithData(data!, options: .AllowFragments)
            } catch {
                print("Could not parse the data as JSON: '\(data)'")
                return
            }
            
          /*  guard let update = parsedResult["updatedAt"] as? String else{
                completionHandler(success: false, errorString:"Error posting user information")
                
                return
            }*/
            completionHandler(success: true, errorString:nil)
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
