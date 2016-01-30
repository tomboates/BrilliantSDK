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
  }
  
  @IBAction func surveyButtonPressed(sender: AnyObject) {
    
    Brilliant.sharedInstance().showNpsSurvey("Button Clicked") { (success) -> Void in
        
    }
  }
}

