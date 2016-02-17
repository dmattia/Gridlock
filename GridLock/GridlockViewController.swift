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
    var alwaysRunningTimer: NSTimer?
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
    
    func startChallenges() {
        // Start any challenge where the start time has recently passed
        let acceptedQuery = PFQuery(className: "Challenge")
        acceptedQuery.whereKey("status", equalTo: "Accepted")
        acceptedQuery.whereKey("startTime", lessThan: NSDate())
        /*
        acceptedQuery.findObjectsInBackgroundWithBlock { (objects: [PFObject]?, error: NSError?) -> Void in
            for object in objects! {
                object.setObject("Started", forKey: "status")
                object.saveInBackground()
            }
        }
        */
    }
    
    func checkForWinners() {
        // Finish any challenge where the end time has passed
        // TODO: Actually have this check who won
        let startedQuery = PFQuery(className: "Challenge")
        
        // hacky, should switch eventually
        //startedQuery.whereKey("status", equalTo: "Started")
        startedQuery.whereKey("status", notEqualTo: "Finished")
        
        startedQuery.whereKey("endTime", lessThan: NSDate())
        startedQuery.findObjectsInBackgroundWithBlock { (objects: [PFObject]?, error: NSError?) -> Void in
            for object in objects! {
                // Update Points as this is a finished challenge
                let challenge = object
                let challengerId = challenge["challengerId"] as? String
                let wagerValue = challenge["wager"] as! NSNumber
                do {
                    let challenger = try PFQuery.getUserObjectWithId(challengerId!)
                    let challengerName = challenger.username
                    
                    let alert = UIAlertController(title: "You win!",
                        message: "You won \(wagerValue) points for winning the challenge against \(challengerName!)!",
                        preferredStyle: UIAlertControllerStyle.Alert)
                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
                    self.presentViewController(alert, animated: true, completion: nil)
                    
                    // Add wager value to current user
                    if let user = PFUser.currentUser() {
                        if let currentPoints = user["challengePoints"] as? NSNumber {
                            PFUser.currentUser()!["challengePoints"] = currentPoints.integerValue + wagerValue.integerValue
                            PFUser.currentUser()!.saveInBackgroundWithBlock({ (completed: Bool, error: NSError?) -> Void in
                                self.updatePoints()
                            })
                        }
                    }
                } catch {
                    print("Could not find user with objectid")
                }
                
                object.setObject("Finished", forKey: "status")
                object.saveInBackgroundWithBlock({ (completed: Bool, error: NSError?) -> Void in
                    print("Object saved")
                    self.endButtonPressed(0)
                })
            }
        }
    }
    
    func displayLogIn() {
        let loginViewController = ParseLogInViewController()
        loginViewController.delegate = self
        PFUser.logOut()
        
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
            } else {
                print("User is already logged in")
                self.updatePoints()
                
                // Ask user to accept Challenges he hasn't accepted yet
                let declaredQuery = PFQuery(className: "Challenge")
                declaredQuery.whereKey("status", equalTo: "Declared")
                declaredQuery.whereKey("challengeeId", equalTo: PFUser.currentUser()!.objectId!)
                declaredQuery.findObjectsInBackgroundWithBlock { (objects: [PFObject]?, error: NSError?) -> Void in
                    for challenge in objects! {
                        
                        let challengerId = challenge["challengerId"] as? String
                        do {
                            let challenger = try PFQuery.getUserObjectWithId(challengerId!)
                            let challengerName = challenger.username
                            
                            let alert = UIAlertController(title: "Challenge From: \(challengerName!)",
                                message: "Would you like to accept?",
                                preferredStyle: UIAlertControllerStyle.Alert)
                            alert.addAction(UIAlertAction(title: "Yes", style: UIAlertActionStyle.Default, handler: nil))
                            alert.addAction(UIAlertAction(title: "No", style: UIAlertActionStyle.Cancel, handler: nil))
                            self.presentViewController(alert, animated: true, completion: {
                                challenge.setObject("Accepted", forKey: "status")
                                challenge.saveInBackground()
                            })
                        } catch {
                            print("Could not find user with objectid")
                        }
                        
                        challenge.saveInBackground()
                    }
                }
                
                self.startChallenges()
                self.checkForWinners()
            }
        })
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
        
        PFUser.logOut()
        
        self.alwaysRunningTimer = NSTimer(timeInterval: 1.0, target: self, selector: "updateDB", userInfo: nil, repeats: true)
        NSRunLoop.currentRunLoop().addTimer(self.alwaysRunningTimer!, forMode: NSRunLoopCommonModes)
    }
    
    func updateDB() {
        self.startChallenges()
        self.checkForWinners()
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
            // check if app has been resigned for more than 20 seconds
            let oldStartTime = self.startTime
            self.startTime = NSDate().dateByAddingTimeInterval(-self.elapsedTimeBeforeLeavingApp!)
            let timeSpentResigned = self.startTime?.timeIntervalSinceDate(oldStartTime!)
            if(timeSpentResigned > 10) {
                let alert = UIAlertController(title: "Session Ended",
                    message: String(format: "You left the app for %.1f seconds, so we have invalidated your session", timeSpentResigned!),
                    preferredStyle: UIAlertControllerStyle.Alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
                self.presentViewController(alert, animated: true, completion: nil)
                
                self.timer?.invalidate()
                self.countUpTimer?.invalidate()
                updatePoints()
                swapButtonEnabled(nil)
                self.timeLabel.text = "0.0"
            } else {
                let alert = UIAlertController(title: "Please stay in the App!",
                    message: String(format: "We have subtracted %.1f seconds from your current session due to you exiting the app", timeSpentResigned!),
                    preferredStyle: UIAlertControllerStyle.Alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
                self.presentViewController(alert, animated: true, completion: nil)
            }
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
        
        if let elapsed = self.elapsedTime {
            let alert = UIAlertController(title: "Session Ended", message: String(format: "You made it %.1f seconds", elapsed), preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
        }
    }
    
    func swapButtonEnabled(alert: UIAlertAction!) {
        self.endButton.enabled = !self.endButton.enabled
        self.startButton.enabled = !self.startButton.enabled
    }
}