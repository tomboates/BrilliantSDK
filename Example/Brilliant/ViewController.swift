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
    Brilliant.sharedInstance.initWithAppKey("X8bZbhepqjAmg+GgF1607S4BtUmj3hN0oz8WKWK2AmgixYyqHy/s4ZSBfeHfA5mDnuKK+HcrfhE3AN59vf08lg==")

    // Setup User Info
    Brilliant.sharedInstance.userEmail = "USER_EMAIL"
    Brilliant.sharedInstance.userAcctCreationDate = NSDate().timeIntervalSince1970
    Brilliant.sharedInstance.userType = "USER_TYPE (OPTIONAL)"
  }
  
  @IBAction func surveyButtonPressed(sender: AnyObject) {
    Brilliant.sharedInstance.showNpsSurvey("EVENT_NAME")
  }
}

