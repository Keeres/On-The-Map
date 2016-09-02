//
//  MapViewController.swift
//  On the Map
//
//  Created by Steven Chen on 4/10/16.
//  Copyright © 2016 Steven Chen. All rights reserved.
//

import Foundation
import UIKit
import MapKit

class MapViewController: UIViewController, MKMapViewDelegate{
    
    @IBOutlet weak var mapView: MKMapView!
    var user:Students?
    var uniqueKey:String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self

        getStudentLocationsRequest()
        
        let defaults = NSUserDefaults.standardUserDefaults()
        uniqueKey = defaults.objectForKey("uniqueKey") as? String
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(MapViewController.updateUserAnnotation(_:)),name:"update", object: nil)

        }

    func getStudentLocationsRequest(){
        let request = NSMutableURLRequest(URL: NSURL(string: "https://parse.udacity.com/parse/classes/StudentLocation?limit=100")!)
        request.addValue("QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr", forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue("QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY", forHTTPHeaderField: "X-Parse-REST-API-Key")
        let session = NSURLSession.sharedSession()
        
        let task = session.dataTaskWithRequest(request) { data, response, error in
            if error != nil {
                print(error)
                
                let alert = UIAlertController(title:nil , message: "Error Downloading Student Information", preferredStyle: UIAlertControllerStyle.Alert)
                alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
                
                self.presentViewController(alert, animated: true, completion: nil)

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
         //   print(studentInformation)
          self.addAnnotations(studentInformation)
        }
        task.resume()
    }
    
    func addAnnotations(studentInformation: [[String : AnyObject]]){
        var annotations = [MKAnnotation]()

            for dictionary in studentInformation {

            // Notice that the float values are being used to create CLLocationDegree values.
            // This is a version of the Double type.
            let lat = CLLocationDegrees(dictionary["latitude"] as! Double)
            let long = CLLocationDegrees(dictionary["longitude"] as! Double)

            // The lat and long are used to create a CLLocationCoordinates2D instance.
            let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
            
            let first = dictionary["firstName"] as! String
            let last = dictionary["lastName"] as! String
            let mediaURL = dictionary["mediaURL"] as! String
            
            // Here we create the annotation and set its coordiate, title, and subtitle properties
            let annotation = MKPointAnnotation()
            annotation.coordinate = coordinate
            annotation.title = "\(first) \(last)"
            annotation.subtitle = mediaURL
            
            // Finally we place the annotation in an array of annotations.
            annotations.append(annotation)

        }
       print( annotations.count)
        self.mapView.addAnnotations(annotations)

    }
    
    func updateUserAnnotation(notification: NSNotification){
        let defaults = NSUserDefaults.standardUserDefaults()
        
        let lat = defaults.doubleForKey("latitude")
        let long = defaults.doubleForKey("longitude")
        
        let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)

        let first = defaults.objectForKey("firstName") as! String
        let last = defaults.objectForKey("lastName") as! String
        let mediaURL = defaults.objectForKey("MediaURL") as! String

        // Here we create the annotation and set its coordiate, title, and subtitle properties
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        annotation.title = "\(first) \(last)"
        annotation.subtitle = mediaURL
        
        self.mapView.addAnnotation(annotation)
    }
    
    // MARK: Buttons
    
    @IBAction func addLocation(sender: AnyObject) {
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
    
    
   // @IBAction func RefreshButton(sender: AnyObject) {
        //  self.getStudentLocationsRequest()

    //}
    
    func presentAddLocation(actionTarget: UIAlertAction){
        let addLocationController = self.storyboard!.instantiateViewControllerWithIdentifier("addLocationView") as! AddLocationViewController
        
        self.modalTransitionStyle = UIModalTransitionStyle.CoverVertical
        addLocationController.modalPresentationStyle = .OverFullScreen
        addLocationController.update = true
        self.presentViewController(addLocationController, animated: true, completion: nil)
    }
    
    // MARK: - MKMapViewDelegate
    
    // Here we create a view with a "right callout accessory view". You might choose to look into other
    // decoration alternatives. Notice the similarity between this method and the cellForRowAtIndexPath
    // method in TableViewDataSource.
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        let reuseId = "pin"

        var pinView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseId) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = true
            pinView!.pinTintColor = UIColor.redColor()
            pinView!.rightCalloutAccessoryView = UIButton(type: .DetailDisclosure)
        }
        else {
            pinView!.annotation = annotation
        }
        
        return pinView
    }
    
    // This delegate method is implemented to respond to taps. It opens the system browser
    // to the URL specified in the annotationViews subtitle property.
    func mapView(mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if control == view.rightCalloutAccessoryView {
            let app = UIApplication.sharedApplication()
            if let toOpen = view.annotation?.subtitle! {
                app.openURL(NSURL(string: toOpen)!)
            }
        }
    }
}


