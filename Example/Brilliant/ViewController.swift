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
  
  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view, typically from a nib.
    Brilliant.sharedInstance.initWithAppKey("TheTestKey001")
    self.appLabel.text = Brilliant.sharedInstance.appKey
    
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }

}

