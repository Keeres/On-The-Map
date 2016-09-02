//
//  AddLocationViewController.swift
//  On the Map
//
//  Created by Steven Chen on 4/14/16.
//  Copyright © 2016 Steven Chen. All rights reserved.
//

import Foundation
import UIKit

class AddLocationViewController: UIViewController, UITextFieldDelegate{
    
    @IBOutlet weak var locationText: UITextField!
    @IBOutlet weak var findButton: UIButton!
    var update:Bool?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        locationText.delegate = self
        
        locationText.attributedPlaceholder = NSAttributedString(string:"Enter your location",attributes:[NSForegroundColorAttributeName: UIColor.whiteColor()])
        findButton.layer.cornerRadius = 10

    //    subscribeToKeyboardNotifications()
    }
    
    override func viewWillDisappear(animated: Bool) {
    //    super.viewWillDisappear(animated)
    //    unsubscribeFromKeyboardNotifications()
    }
    
    //MARK: Buttons
    @IBAction func cancelButton(sender: AnyObject) {
            self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func findOnMap(sender: AnyObject) {
        if locationText.text!.isEmpty{
            let alert = UIAlertController(title: "Alert", message: "Please enter a location", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
        }else{
            let controller = self.storyboard?.instantiateViewControllerWithIdentifier("MyLocation") as? MyLocationViewController
            
            controller!.location = self.locationText.text
            self.modalTransitionStyle = UIModalTransitionStyle.CrossDissolve
            controller!.modalPresentationStyle = .OverCurrentContext
            controller!.update = self.update
            self.presentViewController(controller!, animated: true, completion: nil)
        }
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
         locationText.placeholder = nil
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
     //   locationText.placeholder = "Enter your location"
        locationText.attributedPlaceholder = NSAttributedString(string:"Enter your location",attributes:[NSForegroundColorAttributeName: UIColor.whiteColor()])
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
