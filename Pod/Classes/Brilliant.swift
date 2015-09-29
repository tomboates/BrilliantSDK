//
//  Brilliant.swift
//  Pods
//
//  Created by Paul Berry on 9/20/15.
//
//

import Foundation
import Alamofire

public class Brilliant {
  
  public static let sharedInstance = Brilliant()
  private let kBaseURL = "http://localhost:3000/api/"
  
  public var appKey: String?
  public var userEmail: String?
  public var userAcctCreationDate: Double?
  public var userType: String?
  
  
  // (Jan 9, 2007 iphone reveal) default value so survey shows first time
  private var lastSurveyShownTime = NSDate(timeIntervalSinceReferenceDate: 190_058_400.0)
  private var SURVEY_INTERVAL = 14 // days between seeing surveys
  
  private init() {}
  
  // initialization function, as of right now just sets the app key for web requests
  public func initWithAppKey(key:String) {
    self.appKey = key
  }

  // show the Nps Survey to user
  public func showNpsSurvey(event:String) {
    if daysSinceLastSurvey() > self.SURVEY_INTERVAL {
      let rootVC = UIApplication.sharedApplication().delegate?.window?!.rootViewController
      let surveyVC = SurveyViewController(nibName: nil, bundle: nil)
      surveyVC.event = event
      rootVC!.presentViewController(surveyVC, animated: false, completion: nil)
    }else {
      
    }
  }
  
  // send NPS Survey to Brilliant Server
  public func sendCompletedSurvey(var attributes:Dictionary<String, String>) {
    // set headers for auth and JSON content-type
    let headers = [
      "X-App-Key": self.appKey!,
      "Content-Type": "application/json"
    ]
    
    // add user details to attributes
    attributes["userEmail"] = self.userEmail
    attributes["userAcctCreation"] = String(self.userAcctCreationDate)
    attributes["userType"] = self.userType
    
    let params = ["nps_survey": attributes]
    
    // now send data
    Alamofire.request(.POST, "\(kBaseURL)surveys", headers: headers, parameters: params, encoding: .JSON)
      .responseString { _, _, result in
        print("Success: \(result.isSuccess)")
        print("Response String: \(result.value)")
        
    }
  }

  //# MARK: - Helpers

  private func daysSinceLastSurvey() -> Int {
    return NSCalendar.currentCalendar().components(.Day, fromDate: self.lastSurveyShownTime, toDate: NSDate(), options: []).day
  }
}
