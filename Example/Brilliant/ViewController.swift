//
//  ViewController.swift
//  Brilliant
//
//  Created by Paul Berry on 09/20/2015.
//  Copyright (c) 2015 Paul Berry. All rights reserved.
//

import UIKit
import Brilliant

class ViewController: UIViewController {

  @IBOutlet weak var appLabel: UILabel!
  @IBOutlet weak var surveyButton: UIButton!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    // Setup User Info
    Brilliant.sharedInstance.userEmail = "USER_EMAIL"
    Brilliant.sharedInstance.userAcctCreationDate = NSDate().timeIntervalSince1970
    Brilliant.sharedInstance.userType = "USER_TYPE (OPTIONAL)"
    
    // Always init after setting user info
    Brilliant.sharedInstance.initWithAppKey("wd5vTAb9JXprZ52RxiSO/8g8nnpyLG5llQpH8QOFSsP12+imFKMuX1IhdCWLFQ1wKrhsSMtpyJ/aIK2zMvXdUw==")
  }
  
  @IBAction func surveyButtonPressed(sender: AnyObject) {
    Brilliant.sharedInstance.showNpsSurvey("EVENT_NAME")
  }
}

