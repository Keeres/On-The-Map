//
//  TableViewController.swift
//  On the Map
//
//  Created by Steven Chen on 4/11/16.
//  Copyright © 2016 Steven Chen. All rights reserved.
//

import Foundation
import UIKit

class TableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource{
    
    @IBOutlet weak var tableView: UITableView!
    var students = [Students]()
    var uniqueKey:String?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        let defaults = NSUserDefaults.standardUserDefaults()
        uniqueKey = defaults.objectForKey("uniqueKey") as? String

        self.getStudentLocationsRequest()
        print(self.navigationController?.viewControllers.count)

    }
    
    func getStudentLocationsRequest(){
        let request = NSMutableURLRequest(URL: NSURL(string: "https://api.parse.com/1/classes/StudentLocation?limit=100")!)
        request.addValue("QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr", forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue("QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY", forHTTPHeaderField: "X-Parse-REST-API-Key")
        let session = NSURLSession.sharedSession()
        
        let task = session.dataTaskWithRequest(request) { data, response, error in
            if error != nil {
                print(error)
                return
            }
            //  print(NSString(data: data!, encoding: NSUTF8StringEncoding))
            
            let parsedResult: AnyObject!
            
            do {
                parsedResult = try NSJSONSerialization.JSONObjectWithData(data!, options: .AllowFragments) as? [String:AnyObject]
            } catch {
                print("Could not parse the data as JSON: '\(data)'")
                return
            }
            
            //print(parsedResult)
            
            guard let studentInformation = parsedResult["results"] as? [[String:AnyObject]] else {
                print("no account found")
                return
            }
            self.organizeStudentInformation(studentInformation)
        }
        task.resume()
        
    }

    func organizeStudentInformation(studentInformation: [[String : AnyObject]]){
        for dictionary in studentInformation {
            
            let key = dictionary["uniqueKey"] as! String
            let first = dictionary["firstName"] as! String
            let last = dictionary["lastName"] as! String
            let mediaURL = dictionary["mediaURL"] as! String
            let mapString = dictionary["mapString"] as! String
            let latitude = dictionary["latitude"] as! Double
            let longitude = dictionary["longitude"] as! Double
            
            let student = Students(uniqueKey: key, firstName: first, lastName: last, mediaURL: mediaURL, mapString: mapString, latitude: latitude, longitude: longitude)

            students.append(student)
        }
        performUIUpdatesOnMain(){
            self.tableView.reloadData()
        }
        
    }
    
    // MARK: Buttons
    
    @IBAction func AddLocationButton(sender: AnyObject) {
        UdacityClient.sharedInstance().queryForExistingData(uniqueKey!)  {(sucess, objectID, errorString) in
            
            if sucess == true{
                performUIUpdatesOnMain()
                    {
                        let defaults = NSUserDefaults.standardUserDefaults()
                        defaults.setObject(objectID, forKey: "objectID")
                        
                        let alert = UIAlertController(title:nil , message: "You Already Posted a Student Location. Would you like to Overwrite Your Current Location", preferredStyle: UIAlertControllerStyle.Alert)
                        alert.addAction(UIAlertAction(title: "Overwite", style: UIAlertActionStyle.Default, handler: self.presentAddLocation))
                        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Default, handler: nil))
                        
                        self.presentViewController(alert, animated: true, completion: nil)
                }
            }else{
                let addLocationController = self.storyboard!.instantiateViewControllerWithIdentifier("addLocationView") as! AddLocationViewController
                
                self.modalTransitionStyle = UIModalTransitionStyle.CoverVertical
                addLocationController.modalPresentationStyle = .OverFullScreen
                addLocationController.update = false
                self.presentViewController(addLocationController, animated: true, completion: nil)
            }
        }
    }
    
    func presentAddLocation(actionTarget: UIAlertAction){
        let addLocationController = self.storyboard!.instantiateViewControllerWithIdentifier("addLocationView") as! AddLocationViewController
        
        self.modalTransitionStyle = UIModalTransitionStyle.CoverVertical
        addLocationController.modalPresentationStyle = .OverFullScreen
        addLocationController.update = true
        self.presentViewController(addLocationController, animated: true, completion: nil)
        
    }
    
//    @IBAction func RefreshButton(sender: AnyObject) {
  //      self.getStudentLocationsRequest()
    //}
    
    // MARK: Table Delgate Functions
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
      //  print(students.count)
        return students.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell{
        let cell = tableView.dequeueReusableCellWithIdentifier("studentCell")! as UITableViewCell
        let student = students[indexPath.row]
        
        cell.textLabel?.text = student.firstName! + " " + student.lastName!
        

        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let indexPath = tableView.indexPathForSelectedRow!
      //  let currentCell = tableView.cellForRowAtIndexPath(indexPath)! as UITableViewCell
        let student = students[indexPath.row]
        print(student.mediaURL)
        if let url = NSURL(string: student.mediaURL) {
            UIApplication.sharedApplication().openURL(url)
        }

    }
    
    
}
