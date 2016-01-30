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
    var elapsedTime: NSTimeInterval?
    var elapsedTimeBeforeLeavingApp: NSTimeInterval?
    var timer: NSTimer?
    var countUpTimer: NSTimer? // Used to add one point every second @timer runs
    var isInApp: Bool = true
    @IBOutlet weak var endButton: UIButton!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var pointValue: UIBarButtonItem!
    
    func updatePoints() {
        let currentUser = PFUser.currentUser()
        if let userPoints = currentUser?.objectForKey("points") as? NSNumber {
            let userChallengePoints = currentUser?.objectForKey("challengePoints") as? NSNumber
            let sum = userPoints.integerValue + (userChallengePoints?.integerValue)!
            self.pointValue.title = ("\(sum)")
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
        
        // Start any challenge where the start time has recently passed
        let declaredQuery = PFQuery(className: "Challenge")
        declaredQuery.whereKey("status", equalTo: "Declared")
        declaredQuery.whereKey("startTime", lessThan: NSDate())
        declaredQuery.findObjectsInBackgroundWithBlock { (objects: [PFObject]?, error: NSError?) -> Void in
            for object in objects! {
                object.setObject("Started", forKey: "status")
                object.saveInBackground()
            }
        }
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
        
        self.timeLabel.font = UIFont(name: "Share-TechMono", size: 60)
    }
    
    func appResigned() {
        // Get the current time elapsed from @startTime.
        // This value will be set to @startTime on app resume.
        if(endButton.enabled) {
            self.elapsedTimeBeforeLeavingApp = NSDate().timeIntervalSinceDate(startTime!)
        }
        self.isInApp = false
    }
    
    func appReopened() {
        self.isInApp = true
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
        self.timer = NSTimer(timeInterval: 0.1, target: self, selector: "countUp", userInfo: nil, repeats: true)
        NSRunLoop.currentRunLoop().addTimer(self.timer!, forMode: NSRunLoopCommonModes)
        
        self.countUpTimer = NSTimer(timeInterval: 1.0, target: self, selector: "addPoint", userInfo: nil, repeats: true)
        NSRunLoop.currentRunLoop().addTimer(self.countUpTimer!, forMode: NSRunLoopCommonModes)
    }
    
    func countUp() {
        self.elapsedTime = self.timer!.fireDate.timeIntervalSinceDate(self.startTime!)
        self.timeLabel.text = String(format: "%.1f", self.elapsedTime!)
    }
    
    func addPoint() {
        if(self.isInApp) {
            let newSum = (self.pointValue.title! as NSString).integerValue + 1
            self.pointValue.title = "\(newSum)"
        }
    }
    
    @IBAction func endButtonPressed(sender: AnyObject) {
        self.timer?.invalidate()
        self.countUpTimer?.invalidate()
        
        swapButtonEnabled(nil)
        // Add floor of timeElapsed to Score
        if let currentUser = PFUser.currentUser() {
            currentUser["points"] = (currentUser["points"] as! Double) + floor(self.elapsedTime!)
            currentUser.saveInBackgroundWithBlock({ (completed: Bool, error: NSError?) -> Void in
                self.updatePoints()
            })
        }
        
        let alert = UIAlertController(title: "Session Ended", message: String(format: "You made it %.1f seconds", self.elapsedTime!), preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    func swapButtonEnabled(alert: UIAlertAction!) {
        self.endButton.enabled = !self.endButton.enabled
        self.startButton.enabled = !self.startButton.enabled
    }
}