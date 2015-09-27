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
    // Do any additional setup after loading the view, typically from a nib.
    Brilliant.sharedInstance.initWithAppKey("mV4q8M7SUP9nXY41rronwvRbDpIH7t61WWiDkRQNDv2bXsh1lblsNg9E29cZh2plPMpsTh0GjZHfXmk2oxgoog==")

    // Now set user values
    Brilliant.sharedInstance.userEmail = "paul@me.com"
    Brilliant.sharedInstance.userAcctCreationDate = NSDate().timeIntervalSince1970
    Brilliant.sharedInstance.userType = "Premium"
    
  }
  
  @IBAction func surveyButtonPressed(sender: AnyObject) {
    Brilliant.sharedInstance.showNpsSurvey("activity completed")
  }
}

