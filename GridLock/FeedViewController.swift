//
//  FeedViewController.swift
//  GridLock
//
//  Created by David Mattia on 1/30/16.
//  Copyright © 2016 David Mattia. All rights reserved.
//

import UIKit

class FeedViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var feedTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.feedTableView.delegate = self
        self.feedTableView.dataSource = self
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 90
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cellID = "feedCell"
        let cell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: cellID)
        
        if let textLabel = cell.textLabel {
            textLabel.text = "Hello"
        }
        
        return cell
    }
    
}
