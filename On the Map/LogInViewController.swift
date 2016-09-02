//
//  LoginViewController.swift
//  On the Map
//
//  Created by Steven Chen on 4/7/16.
//  Copyright © 2016 Steven Chen. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController, UITextFieldDelegate{

    @IBOutlet weak var userNameTextField: UITextField!
    @IBOutlet weak var passwrodTextField: UITextField!
    
    var user:Students?
    var uniqueKey:String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        userNameTextField.delegate = self
        passwrodTextField.delegate = self
        self.navigationController?.setNavigationBarHidden(true, animated: false)

     //   subscribeToKeyboardNotifications()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidDisappear(animated: Bool) {
     //   unsubscribeFromKeyboardNotifications()
    }
    
    // MARK: Buttons
    @IBAction func loginButton(sender: AnyObject) {
        UdacityClient.sharedInstance().authentiation(userNameTextField.text!, password: passwrodTextField.text!){ (success, key,errorString) in
            if success {
                
                UdacityClient.sharedInstance().getUserData(key) {(firstName, LastName, errorString) in
                    let defaults = NSUserDefaults.standardUserDefaults()
                
                    defaults.setObject(key, forKey: "uniqueKey")
                    defaults.setObject(firstName, forKey: "firstName")
                    defaults.setObject(LastName, forKey: "lastName")
//                    NSUserDefaults.standardUserDefaults().synchronize()

                    print(defaults.objectForKey("firstName") as! String)
                    performUIUpdatesOnMain(){
                     //   let controller = self.storyboard!.instantiateViewControllerWithIdentifier("TabBar") as! UITabBarController
                        
                       // self.presentViewController(controller, animated: true, completion: nil)
                        self.performSegueWithIdentifier("MapView", sender: nil)
                    }
                }
            }else {
                print("Unable to Log In")
            }
        }
    }
    
    @IBAction func signUpButton(sender: AnyObject) {
        if let url = NSURL(string: "https://www.udacity.com/account/auth#!/signup") {
            UIApplication.sharedApplication().openURL(url)
        }
    }
    
    // MARK: Error
    //change to an alert view with error message: incorrect log in info later
    private func displayError(errorString: String?) {
        if let errorString = errorString {
           print(errorString)
        }
    }
    
    // MARK: TextField Delegate
    func textFieldDidBeginEditing(textField: UITextField) {
        textField.text = nil
        textField.textColor = UIColor.blackColor()
    }
    
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
    
    // MARK: Navigation
    // view controller is signing up to be notified when keyboard will apper
    func subscribeToKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(LoginViewController.keyboardWillShow(_:)), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(LoginViewController.keyboardWillHide(_:)), name: UIKeyboardWillHideNotification, object: nil)
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

        return keyboardSize.CGRectValue().height
    }
}

