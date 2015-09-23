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
    Brilliant.sharedInstance.initWithAppKey("IFTwNt01zgAG1IgO6GkcOAQNjvvHr/izpfcTUZ1aNP8xQNgl233oh/al9doLpTFa75SpgWahya4sgKIHF9Q8kA==")
    // Now set defaults
    Brilliant.sharedInstance.userEmail = "paul@me.com"
//    Brilliant.sharedInstance.userAcctCreationDate = NSDate().timeIntervalSince1970
    Brilliant.sharedInstance.userType = "Premium"
    
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }

  @IBAction func surveyButtonPressed(sender: AnyObject) {
    Brilliant.sharedInstance.showNpsSurvey(self)
    //    let attributes: Dictionary<String, String> =
//    ["triggerTimestamp": String(NSDate().timeIntervalSince1970),
//      "completedTimestamp": String(NSDate().timeIntervalSince1970),
//      "npsRating": "10",
//      "comments": "This is amazing!",
//      "dismissAction": "ThanksXButton",
//      "event": "buttonPressed"]
//    
//    Brilliant.sharedInstance.sendCompletedSurvey(attributes)
  }
}

