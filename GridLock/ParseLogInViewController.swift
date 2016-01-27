//
//  ParseLogInViewController.swift
//  GridLock
//
//  Created by David Mattia on 1/27/16.
//  Copyright © 2016 David Mattia. All rights reserved.
//

import UIKit
import Parse
import ParseUI

class ParseLogInViewController: PFLogInViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let logo = UILabel()
        logo.text = "GridLock"
        logo.textColor = UIColor.whiteColor()
        logo.font = UIFont(name: "Pacifico", size: 45)
        logo.shadowColor = UIColor.lightGrayColor()
        logo.shadowOffset = CGSizeMake(2, 2)
        logInView?.logo = logo
        
        self.logInView?.backgroundColor = UIColor.darkGrayColor()
        
        logInView?.logInButton?.setBackgroundImage(nil, forState: .Normal)
        logInView?.logInButton?.backgroundColor = UIColor(red: 52/255, green: 125/255, blue: 255/255, alpha: 1)
        logInView?.passwordForgottenButton?.setTitleColor(UIColor.whiteColor(), forState: .Normal)
                
        self.signUpController = ParseSignUpViewController()
    }
}