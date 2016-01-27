//
//  GridlockViewController.swift
//  GridLock
//
//  Created by David Mattia on 1/27/16.
//  Copyright © 2016 David Mattia. All rights reserved.
//

import UIKit

class GridlockViewController: UIViewController {
    var startTime: NSDate?
    var endTime: NSDate?
    @IBOutlet weak var endButton: UIButton!
    @IBOutlet weak var startButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.endButton.enabled = false
    }
    
    @IBAction func startButtonPressed(sender: AnyObject) {
        startTime = NSDate()
        swapButtonEnabled(nil)
    }
    
    @IBAction func endButtonPressed(sender: AnyObject) {
        endTime = NSDate()
        let timeElapsed = endTime?.timeIntervalSinceDate(startTime!)
        let alert = UIAlertController(title: "Session Ended", message: String(format: "You made it %.1f seconds", timeElapsed!), preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: swapButtonEnabled))
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    func swapButtonEnabled(alert: UIAlertAction!) {
        self.endButton.enabled = !self.endButton.enabled
        self.startButton.enabled = !self.startButton.enabled
    }
}