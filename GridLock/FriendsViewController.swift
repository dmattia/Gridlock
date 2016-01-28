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
            print(self.users)
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
        
        return cell
    }
}
