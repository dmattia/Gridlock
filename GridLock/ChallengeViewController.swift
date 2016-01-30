//
//  ChallengeViewController.swift
//  GridLock
//
//  Created by David Mattia on 1/28/16.
//  Copyright © 2016 David Mattia. All rights reserved.
//

import UIKit
import Parse

class ChallengeViewController: UIViewController {
    var startTime: NSDate?
    var endTime: NSDate?
    @IBOutlet weak var startTimeTextField: UITextField!
    @IBOutlet weak var wagerTextField: UITextField!
    @IBOutlet weak var messageTextField: UITextField!
    var chalengee : PFUser?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func cancelClicked(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func saveClicked(sender: AnyObject) {
        let challenge = PFObject(className: "Challenge")
        challenge.setObject(self.startTime!, forKey: "startTime")
        challenge.setObject(self.endTime!, forKey: "endTime")
        challenge.setObject(PFUser.currentUser()!.objectId!, forKey: "challengerId")
        challenge.setObject((self.chalengee?.objectId)!, forKey: "challengeeId")
        challenge.setObject("Declared", forKey: "status")
        challenge.setObject((self.wagerTextField.text! as NSString).integerValue, forKey: "wager")
        challenge.setObject(self.messageTextField.text!, forKey: "message")
        challenge.saveInBackgroundWithBlock { (completed: Bool, error: NSError?) -> Void in
            if(completed) {
                print("Saved Challenge")
            } else {
                print("Error saving: \(error)")
            }
        }
        
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func openedStartTime(sender: UITextField) {
        let datePickerView:UIDatePicker = UIDatePicker()
        datePickerView.datePickerMode = UIDatePickerMode.DateAndTime
        datePickerView.minuteInterval = 5
        datePickerView.minimumDate = NSDate()
        sender.inputView = datePickerView
        datePickerView.addTarget(self, action: Selector("datePickerValueChanged:"), forControlEvents: UIControlEvents.ValueChanged)
    }
    
    func datePickerValueChanged(sender:UIDatePicker) {
        self.startTime = sender.date
        self.endTime = sender.date.dateByAddingTimeInterval(NSTimeInterval(60*60))
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateStyle = NSDateFormatterStyle.ShortStyle
        dateFormatter.timeStyle = NSDateFormatterStyle.ShortStyle
        self.startTimeTextField.text = dateFormatter.stringFromDate(sender.date)
    }
}

