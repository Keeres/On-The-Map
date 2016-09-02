//
//  MyLocationViewController.swift
//  On the Map
//
//  Created by Steven Chen on 4/16/16.
//  Copyright © 2016 Steven Chen. All rights reserved.
//

import Foundation
import UIKit
import MapKit

class MyLocationViewController: UIViewController, MKMapViewDelegate, UITextFieldDelegate {
  
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var urlTextField: UITextField!
    @IBOutlet weak var submitButton: UIButton!
    var user:Students!
    
    var location:String?
    var mediaURL:String?
    var longitude:Double?
    var latitude:Double?
    var update: Bool?
    var viewControllers: [UIViewController]?
    var geocoder = CLGeocoder()

    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        urlTextField.delegate = self
        UINavigationBar.appearance().shadowImage = UIImage()
        UINavigationBar.appearance().setBackgroundImage(UIImage(), forBarMetrics: UIBarMetrics.Default)
        
        
        urlTextField.attributedPlaceholder = NSAttributedString(string:"Enter a Link to Share Here", attributes:[NSForegroundColorAttributeName: UIColor.whiteColor()])
        submitButton.layer.cornerRadius = 10
        
        showMyLocationWithPin()
    }
    
    func showMyLocationWithPin(){
        geocoder.geocodeAddressString(location!, completionHandler: {(placemarks: [CLPlacemark]?, error: NSError?) -> Void in
            
            if error != nil{
                let alert = UIAlertController(title:nil , message: "Error Finding the Location", preferredStyle: UIAlertControllerStyle.Alert)
                alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
                
                self.presentViewController(alert, animated: true, completion: nil)
            }
            
            if let placemark = placemarks?[0]  {
                
                let location = placemark.location;
                let coordinate = location!.coordinate;
                self.longitude = coordinate.longitude
                self.latitude = coordinate.latitude

                var zoomRect = MKMapRectNull;
                let annotationPoint = MKMapPointForCoordinate(coordinate)
                let pointRect = MKMapRectMake(annotationPoint.x, annotationPoint.y, 0.9, 0.9)
                zoomRect = MKMapRectUnion(zoomRect, pointRect)
                self.mapView.setVisibleMapRect(zoomRect,animated: true)
                self.mapView.addAnnotation(MKPlacemark(placemark: placemark))
                
                //Zoom in or out with pin in center
                let latDelta: CLLocationDegrees = 0.02
                let lonDelta: CLLocationDegrees = 0.02
                let span:MKCoordinateSpan = MKCoordinateSpanMake(latDelta, lonDelta)
                let locationTemp: CLLocationCoordinate2D = CLLocationCoordinate2DMake(self.latitude!, self.longitude!)
                let region: MKCoordinateRegion = MKCoordinateRegionMake(locationTemp, span)
                self.mapView.setRegion(region, animated: true)
               // self.map.showsUserLocation = true
                
            }else{
                let alert = UIAlertController(title: "Alert", message: "Please enter a location", preferredStyle: UIAlertControllerStyle.Alert)
                alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
                self.presentViewController(alert, animated: true, completion: nil)

            }
            
        }
    )}
    
    func zoomMapBy(delta delta:Double) {
        
        var region:MKCoordinateRegion  = self.mapView.region
        var span:MKCoordinateSpan  = mapView.region.span
        span.latitudeDelta*=delta;
        span.longitudeDelta*=delta;
        region.span=span;
        mapView .setRegion(region, animated: true)
        
    }
    
    func userInfoSetup(){
        let defaults = NSUserDefaults.standardUserDefaults()
        self.mediaURL = urlTextField.text

        user = Students(uniqueKey: defaults.objectForKey("uniqueKey") as! String, firstName: defaults.objectForKey("firstName") as! String, lastName: defaults.objectForKey("lastName") as! String, mediaURL:self.mediaURL!, mapString: self.location!, latitude: self.latitude!, longitude: self.longitude!)
        
        print(defaults.objectForKey("firstName") as! String)
        print(user.firstName!)
    }
    
    func postMyLocation(){
        let request = NSMutableURLRequest(URL: NSURL(string: "https://api.parse.com/1/classes/StudentLocation")!)
        request.HTTPMethod = "POST"
        request.addValue("QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr", forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue("QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY", forHTTPHeaderField: "X-Parse-REST-API-Key")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let json : [String: AnyObject] = ["uniqueKey":user!.uniqueKey!, "firstName":user.firstName!, "lastName":user!.lastName!, "mapString":user!.mapString!, "mediaURL":user!.mediaURL!, "latitude":user!.latitude!, "longitude":user!.longitude!]
        do{
            let jsonData = try NSJSONSerialization.dataWithJSONObject(json, options: .PrettyPrinted)
            request.HTTPBody = jsonData
        }catch{
            print("error")
        }
        
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request) { data, response, error in
            if error != nil { // Handle error…
                return
            }
        //    print(NSString(data: data!, encoding: NSUTF8StringEncoding))
            performUIUpdatesOnMain(){
                self.updateUserInfo()
                NSNotificationCenter.defaultCenter().postNotificationName("update", object: nil)

                let presentingViewController = self.presentingViewController
                
                self.dismissViewControllerAnimated(true, completion: {
                    presentingViewController!.dismissViewControllerAnimated(false, completion:nil)
                    
                })
            }
        }
        task.resume()
    }
    
    func updateMyLocation(){
        
        let urlString = "https://api.parse.com/1/classes/StudentLocation/8ZExGR5uX8"
        let url = NSURL(string: urlString)
        let request = NSMutableURLRequest(URL: url!)
        request.HTTPMethod = "PUT"
        request.addValue("QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr", forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue("QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY", forHTTPHeaderField: "X-Parse-REST-API-Key")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let json : [String: AnyObject] = ["uniqueKey":user!.uniqueKey!, "firstName":user!.firstName!, "lastName":user!.lastName!, "mapString":user!.mapString!, "mediaURL":user!.mediaURL!, "latitude":user!.latitude!, "longitude":user!.longitude!]
        do{
            let jsonData = try NSJSONSerialization.dataWithJSONObject(json, options: .PrettyPrinted)
            request.HTTPBody = jsonData
        }catch{
            print("error")
            let alert = UIAlertController(title:nil , message: "Posting Student Information Failed", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
            
            self.presentViewController(alert, animated: true, completion: nil)
        }
        
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request) { data, response, error in
            if error != nil { // Handle error…
                return
            }
         //   print(NSString(data: data!, encoding: NSUTF8StringEncoding))
            performUIUpdatesOnMain(){
                self.updateUserInfo()
                
                NSNotificationCenter.defaultCenter().postNotificationName("update", object: nil)
                
                self.presentingViewController!.presentingViewController!.dismissViewControllerAnimated(false, completion: nil)

            }
        }
        task.resume()
    }
    
    func updateUserInfo(){
       let defaults = NSUserDefaults.standardUserDefaults()
        defaults.setDouble(user!.latitude!, forKey: "latitude")
        defaults.setDouble(user!.longitude!, forKey: "longitude")
        defaults.setObject(user!.mapString, forKey: "mapString")
        defaults.setObject(user!.mediaURL, forKey: "mediaURL")
    }
    
    //MARK: Buttons
    @IBAction func submit(sender: AnyObject) {
        if urlTextField.text!.isEmpty{
            let alert = UIAlertController(title: "Warning", message: "Please enter a link", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
        }else{
            userInfoSetup()

            let defaults = NSUserDefaults.standardUserDefaults()
            let objectID = defaults.objectForKey("objectID") as! String
            
            if objectID.isEmpty || update == false{
                postMyLocation()
                print("post")
            }else{
                updateMyLocation()
                print("update")
            }
        }
    }
    
    @IBAction func cancelButton(sender: AnyObject) {
        self.presentingViewController!.presentingViewController!.dismissViewControllerAnimated(true, completion: {})

    }
    
    //MARK: TextView Delegate
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        if textField == "\n" {
            // Return FALSE so that the final '\n' character doesn't get added
            return false;
        }
        return true
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        urlTextField.placeholder = nil
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        urlTextField.attributedPlaceholder = NSAttributedString(string:"Enter a Link to Share Here", attributes:[NSForegroundColorAttributeName: UIColor.whiteColor()])
    }

    
    // MARK: Navigation
    // view controller is signing up to be notified when keyboard will apper
    func subscribeToKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(AddLocationViewController.keyboardWillShow(_:)), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(AddLocationViewController.keyboardWillHide(_:)), name: UIKeyboardWillHideNotification, object: nil)
    }
    
    // view controller unsubscribes notification when keyboard will disapper
    func unsubscribeFromKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().removeObserver(self, name:
            UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name:
            UIKeyboardWillHideNotification, object: nil)
    }
    
    // show and shift keyboard when notification is recieved
    func keyboardWillShow(notification: NSNotification) {  //notification annouce information across class
        view.frame.origin.y -= getKeyboardHeight(notification) //origin is top of the view
    }
    
    func keyboardWillHide(notification: NSNotification) {  //notification annouce information across class
        view.frame.origin.y += getKeyboardHeight(notification) //origin is top of the view
    }
    
    func getKeyboardHeight(notification: NSNotification) -> CGFloat {
        //notification carries information inside userInfo dictionary
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue // of CGRect
        print(keyboardSize.CGRectValue().height)
        return keyboardSize.CGRectValue().height
    }

}
