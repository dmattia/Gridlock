//
//  FriendsViewController.swift
//  GridLock
//
//  Created by David Mattia on 1/28/16.
//  Copyright © 2016 David Mattia. All rights reserved.
//

import UIKit
import Parse

class FriendsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var FriendsTableView: UITableView!
    var users: [PFObject]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.FriendsTableView.delegate = self
        self.FriendsTableView.dataSource = self
        
        let query = PFUser.query()
        query?.findObjectsInBackgroundWithBlock({ (users: [PFObject]?, error: NSError?) -> Void in
            self.users = users
            self.FriendsTableView.reloadData()
        })
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 90
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let friends = self.users {
            return friends.count
        } else {
            return 0
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cellIdentifier = "friendCell"
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier) as! FriendTableViewCell
        
        if let friends = self.users {
            let user = friends[indexPath.row] as! PFUser
            cell.nameLabel.text = user.username
            let points = user.objectForKey("points") as! Int
            cell.scoreLabel.text = "\(points)"
        }
        
        cell.challengeButton.tag = indexPath.row
        cell.challengeButton.addTarget(self, action: "challengeClicked:", forControlEvents: UIControlEvents.TouchUpInside)
        cell.selectionStyle = UITableViewCellSelectionStyle.None
        
        return cell
    }
    
    func challengeClicked(sender: UIButton!) {
        let challengee = (self.users![sender.tag] as! PFUser).username
        
        // Create an alertview to gather the information for a challenge
        var wagerTextField: UITextField?
        var messageTextField: UITextField?
        let alert = UIAlertController(title: "Challenge \(challengee!)!",
            message: "",
            preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "Send Challenge", style: UIAlertActionStyle.Default, handler: {
            (action) -> Void in
            print(wagerTextField?.text)
            print(messageTextField?.text)
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: nil))
        alert.addTextFieldWithConfigurationHandler({(textField: UITextField!) in
            textField.placeholder = "Points to Challenge"
            textField.keyboardType = UIKeyboardType.PhonePad
            wagerTextField = textField
        })
        alert.addTextFieldWithConfigurationHandler({(textField: UITextField!) in
            textField.placeholder = "Message to \(challengee!)"
            messageTextField = textField
        })
        self.presentViewController(alert, animated: true, completion: nil)
    }
}
