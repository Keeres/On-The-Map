//
//  TabBarController.swift
//  On the Map
//
//  Created by Steven Chen on 9/3/16.
//  Copyright © 2016 Steven Chen. All rights reserved.
//

import UIKit

class TabBarController: UITabBarController, UIAlertViewDelegate  {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }

    
    func test(){
        if self.selectedViewController!.isKindOfClass( MapViewController) {
            print("trying to refresh an unknown view")

        } else if self.selectedViewController!.isKindOfClass(TableViewController){
            print("trying to refresh an unknown view")

        } else {
            print("trying to refresh an unknown view")
        }    }
    
    func addLocation(){
       
        let controller = (self.viewControllers![0] as! UINavigationController).topViewController as! MapViewController
    
        UdacityClient.sharedInstance().queryForExistingData(controller.uniqueKey!){(sucess, objectID, errorString) in
            
            if sucess == true{
                performUIUpdatesOnMain()
                    {
                        let defaults = NSUserDefaults.standardUserDefaults()
                        defaults.setObject(objectID, forKey: "objectID")
                        
                        let alert = UIAlertController(title:nil , message: "You Already Posted a Student Location. Would you like to Overwrite Your Current Location", preferredStyle: UIAlertControllerStyle.Alert)
                        alert.addAction(UIAlertAction(title: "Overwite", style: UIAlertActionStyle.Default, handler: self.alertViewButton))
                        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Default, handler: nil))
                        
                        self.presentViewController(alert, animated: true, completion: nil)
                }
            }else if !errorString!.isEmpty{
                AlertView.displayError(self, error: errorString!)
            }else{
                self.presentAddLocation(false)
            }
        }
    }
    
    func presentAddLocation(isUpdate:Bool){
        
        let addLocationController = self.storyboard!.instantiateViewControllerWithIdentifier("addLocationView") as! AddLocationViewController
        
        self.modalTransitionStyle = UIModalTransitionStyle.CoverVertical
        addLocationController.modalPresentationStyle = .OverFullScreen
        addLocationController.update = isUpdate
        self.presentViewController(addLocationController, animated: true, completion: nil)
    }
    
    func alertViewButton(actionTarget: UIAlertAction) {
            self.presentAddLocation(true)
        
    }
    
    func refreshStudentInfomation(){
        let controller = (self.viewControllers![0] as! UINavigationController).topViewController as! MapViewController

        controller.getStudentLocations()
    }
    
    func refreshTable(){
        let mapController = (self.viewControllers![0] as! UINavigationController).topViewController as! MapViewController
        let tableController = (self.viewControllers![1] as! UINavigationController).topViewController as! TableViewController
        
        UdacityClient.sharedInstance().getStudentLocationsRequest(){(success, studentLocations, errorString) in
            if success {
                mapController.parseStudentInformation(studentLocations)
                tableController.tableView.reloadData()
            } else {
                performUIUpdatesOnMain(){
                    AlertView.displayError(self, error: errorString!)
                }
            }
        }
    }
}
