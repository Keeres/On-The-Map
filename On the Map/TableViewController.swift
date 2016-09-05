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
    var uniqueKey:String?
    var appDelegate: AppDelegate!
    var students: [StudentInformation] {
        return (UIApplication.sharedApplication().delegate as! AppDelegate).students
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        let defaults = NSUserDefaults.standardUserDefaults()
        uniqueKey = defaults.objectForKey("uniqueKey") as? String
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        print("ASDF")
        tableView.reloadData()
    }
    
    // MARK: Buttons
    @IBAction func AddLocationButton(sender: AnyObject) {
        (self.tabBarController as? TabBarController)?.addLocation()
    }
   
    @IBAction func logoutButton(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func refreshButton(sender: AnyObject) {
        (self.tabBarController as? TabBarController)?.refreshStudentInfomation()
        tableView.reloadData()
    }
  
    // MARK: Table Delgate Functions
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int{

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
        let student = students[indexPath.row]

        if let url = student.mediaURL{
            if student.mediaURL.hasPrefix("http://") {
                UIApplication.sharedApplication().openURL(NSURL(string: url)!)
            } else {
                UIApplication.sharedApplication().openURL(NSURL(string: "http://\(url)")!)
            }
        }
    }
    
    
}
