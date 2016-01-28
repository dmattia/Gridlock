//
//  GridlockViewController.swift
//  GridLock
//
//  Created by David Mattia on 1/27/16.
//  Copyright © 2016 David Mattia. All rights reserved.
//

import UIKit
import Parse
import ParseUI

class GridlockViewController: UIViewController, PFLogInViewControllerDelegate {
    var startTime: NSDate?
    var endTime: NSDate?
    var elapsedTimeBeforeLeavingApp: NSTimeInterval?
    @IBOutlet weak var endButton: UIButton!
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var pointValue: UIBarButtonItem!
    
    func updatePoints() {
        let currentUser = PFUser.currentUser()
        if let userPoints = currentUser?.objectForKey("points") as? NSNumber {
            self.pointValue.title = "\(userPoints)"
        }
    }
    
    func displayLogIn() {
        let loginViewController = ParseLogInViewController()
        loginViewController.delegate = self
        
        loginViewController.fields = [
            PFLogInFields.UsernameAndPassword,
            PFLogInFields.LogInButton,
            PFLogInFields.SignUpButton,
            PFLogInFields.PasswordForgotten,
        ]
        
        self.presentViewController(loginViewController, animated: true, completion: nil)
    }
    
    func logInViewController(logInController: PFLogInViewController, didLogInUser user: PFUser) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func viewDidAppear(animated: Bool) {
        dispatch_async(dispatch_get_main_queue(), {
            if(PFUser.currentUser() == nil) {
                self.displayLogIn()
            }
        })
        self.updatePoints()
    }
    
    @IBAction func logoutButtonPressed(sender: AnyObject) {
        PFUser.logOut()
        self.displayLogIn()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.endButton.enabled = false
        
        NSNotificationCenter.defaultCenter().addObserver(self,
            selector: "appResigned",
            name: kApplicationWillResignActiveNotification,
            object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self,
            selector: "appReopened",
            name: kApplicationWillReOpenActiveNotification,
            object: nil)
    }
    
    func appResigned() {
        // Get the current time elapsed from @startTime.
        // This value will be set to @startTime on app resume.
        if(endButton.enabled) {
            self.elapsedTimeBeforeLeavingApp = NSDate().timeIntervalSinceDate(startTime!)
        }
    }
    
    func appReopened() {
        if(endButton.enabled) {
            self.startTime = NSDate().dateByAddingTimeInterval(-self.elapsedTimeBeforeLeavingApp!)
            
            let alert = UIAlertController(title: "Please stay in the App!",
                message: String(format: "We have subtracted %.1f seconds from your current session due to you exiting the app", elapsedTimeBeforeLeavingApp!),
                preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
        }
    }
    
    @IBAction func startButtonPressed(sender: AnyObject) {
        startTime = NSDate()
        swapButtonEnabled(nil)
    }
    
    @IBAction func endButtonPressed(sender: AnyObject) {
        endTime = NSDate()
        swapButtonEnabled(nil)
        if let timeElapsed = endTime?.timeIntervalSinceDate(startTime!) {
            // Add floor of timeElapsed to Score
            if let currentUser = PFUser.currentUser() {
                currentUser["points"] = (currentUser["points"] as! Double) + floor(timeElapsed)
                currentUser.saveInBackgroundWithBlock({ (completed: Bool, error: NSError?) -> Void in
                    self.updatePoints()
                })
            }
            
            let alert = UIAlertController(title: "Session Ended", message: String(format: "You made it %.1f seconds", timeElapsed), preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
        }
    }
    
    func swapButtonEnabled(alert: UIAlertAction!) {
        self.endButton.enabled = !self.endButton.enabled
        self.startButton.enabled = !self.startButton.enabled
    }
}