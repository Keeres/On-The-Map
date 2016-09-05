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
    var user:StudentInformation!
    
    var location:String?
    var mediaURL:String?
    var longitude:Double?
    var latitude:Double?
    var update: Bool?
    var viewControllers: [UIViewController]?
    var geocoder = CLGeocoder()
    var activityIndicator = UIActivityIndicatorView()

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
        showActivityIndicatory()
        
        geocoder.geocodeAddressString(location!, completionHandler: {(placemarks: [CLPlacemark]?, error: NSError?) -> Void in
            
            if error != nil{
                self.activityIndicator.stopAnimating()
                AlertView.displayError(self, error: "Error Finding the Location")
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
            }
              self.activityIndicator.stopAnimating()
        }
    )}
    
    func showActivityIndicatory() {
        activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.Gray)
        activityIndicator.frame = CGRect(x: 0, y: 0, width: 70, height: 70)
        activityIndicator.center = self.view.center
        self.view.addSubview(activityIndicator)
        activityIndicator.startAnimating()
        
    }
    
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
        let dictionary : [String:AnyObject] = ["uniqueKey":defaults.objectForKey("uniqueKey")!, "firstName":defaults.objectForKey("firstName")!, "lastName":defaults.objectForKey("lastName")!, "mediaURL":self.mediaURL!, "mapString":self.location!, "latitude":self.latitude!, "longitude":self.longitude!]

        user = StudentInformation(studentDictionary: dictionary)
    }
    
    func updateUserInfo(){
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.setDouble(user!.latitude!, forKey: "latitude")
        defaults.setDouble(user!.longitude!, forKey: "longitude")
        defaults.setObject(user!.mapString, forKey: "mapString")
        defaults.setObject(user!.mediaURL, forKey: "mediaURL")
    }
    
    func postMyLocation(){
        UdacityClient.sharedInstance().postUserInformation(user.uniqueKey, firstName: user.firstName, lastName: user.lastName, mapString: user.mapString, mediaURL: user.mediaURL, latitude: user.latitude, longitude: user.longitude) {(success, objectId, errorString) in

            if success{
                performUIUpdatesOnMain(){
                    self.updateUserInfo()

                    NSNotificationCenter.defaultCenter().postNotificationName("update", object: nil)
                    
                    let presentingViewController = self.presentingViewController
                    
                    self.dismissViewControllerAnimated(true, completion: {
                        presentingViewController!.dismissViewControllerAnimated(false, completion:nil)
                    })
                }
            }else{
                AlertView.displayError(self, error: errorString!)
            }
        }
    }
    
    func updateMyLocation(){
        UdacityClient.sharedInstance().updateUserInformation(self.user.uniqueKey, firstName: self.user.firstName, lastName: self.user.lastName, mapString: self.user.mapString, mediaURL: self.user.mediaURL, latitude: self.user.latitude, longitude: self.user.longitude) {(success, errorString) in
            if success{
                
                performUIUpdatesOnMain(){
                    self.updateUserInfo()
                    
                    NSNotificationCenter.defaultCenter().postNotificationName("update", object: nil)
                    
                    self.presentingViewController!.presentingViewController!.dismissViewControllerAnimated(false, completion: nil)
                }
            }else{
                AlertView.displayError(self, error: errorString!)
            }
        }
    }
    
  
    
    //MARK: Buttons
    @IBAction func submit(sender: AnyObject) {
        if urlTextField.text!.isEmpty{
            AlertView.displayError(self, error: "Please enter a link")
        }else{
            userInfoSetup()
            if update == false{
                postMyLocation()
                print("post")
            }else if update == true{
                updateMyLocation()
                print("update")
            }else{
                AlertView.displayError(self, error: "Error Adding Location")
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
