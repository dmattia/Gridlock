//
//  FeedViewController.swift
//  GridLock
//
//  Created by David Mattia on 1/30/16.
//  Copyright © 2016 David Mattia. All rights reserved.
//

import UIKit
import Parse

class FeedViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var feedTableView: UITableView!
    var challenges : [PFObject]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.feedTableView.delegate = self
        self.feedTableView.dataSource = self
    }
    
    override func viewDidAppear(animated: Bool) {
        let query = PFQuery(className: "Challenge")
        query.orderByDescending("updatedAt")
        query.findObjectsInBackgroundWithBlock { (challenges: [PFObject]?, error: NSError?) -> Void in
            self.challenges = challenges
            self.feedTableView.reloadData()
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let items = challenges {
            return items.count
        } else {
            return 0
        }
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 90
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cellID = "feedCell"
        let cell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: cellID)
        
        cell.textLabel?.font = UIFont(name: "Times", size: 18)
        
        // Find the username of the challenger
        let challenge = self.challenges![indexPath.row]
        let challengerId = challenge["challengerId"] as? String
        let challengeeId = challenge["challengeeId"] as? String
        let status = challenge["status"] as? String
        do {
            let challenger = try PFQuery.getUserObjectWithId(challengerId!)
            let challengee = try PFQuery.getUserObjectWithId(challengeeId!)
            
            cell.textLabel!.text = "\(challenger.username!) \(status!.lowercaseString) a challenge against \(challengee.username!)"
        } catch {
            cell.textLabel!.text = "Could not fetch challenge information"
        }
        
        return cell
    }
    
}
