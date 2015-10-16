//
//  Brilliant.swift
//  Pods
//
//  Created by Paul Berry on 9/20/15.
//
//

import Foundation
import Alamofire
import ReachabilitySwift

public class Brilliant {
  
  public static let sharedInstance = Brilliant()
//  private let kBaseURL = "http://brilliantapp.com/api/"
  private let kBaseURL = "http://localhost:3000/api/"
  
  public var appKey: String?
  public var userEmail: String?
  public var userAcctCreationDate: Double?
  public var userType: String?
  public var appName: String?
  
  private var lastSurveyShownTime: NSDate! {
    
    willSet(date) {
      NSUserDefaults.standardUserDefaults().setObject(date, forKey: "lastSurveyShownTime")
    }
  }
  
  // is there a survey that needs to be sent to server?
  private var pendingSurvey = false
  
  // survey data to be sent to server or saved to disk
  public var completedSurvey: Dictionary<String, String>? {
    willSet(survey) {
      NSUserDefaults.standardUserDefaults().setObject(survey, forKey: "completedSurvey")
    }
  }

  // days between seeing surveys
  private var SURVEY_INTERVAL = 14
  
  private static var kDEBUG = true
  
  private init() {}
  
  // initialization on app open. Sets api key, checks for pending surveys
  public func initWithAppKey(key:String) {
    self.appKey = key
    
    // set or initalize lastSurveyShownTime
    if let lastDate = NSUserDefaults.standardUserDefaults().objectForKey("lastSurveyShownTime") as? NSDate
    {
      self.lastSurveyShownTime = lastDate
    }else {
      // (Jan 9, 2007 iphone reveal, always will trigger survey at first)
      self.lastSurveyShownTime =  NSDate(timeIntervalSinceReferenceDate: 190_058_400.0)
    }
    
    // if a pending survey is saved, load and attempt to resend
    if let survey = NSUserDefaults.standardUserDefaults().objectForKey("completedSurvey") as? Dictionary<String, String>
    {
      self.completedSurvey = survey
      self.pendingSurvey = true
      printDebug("loaded survey from disk, attempting to send")
      self.sendCompletedSurvey()
    }else {
      self.pendingSurvey = false
      printDebug("no pending survey on disk: \(self.completedSurvey)")
    }
    
    // pull data from server (for now just app name to display)
    self.getInitialSurveyData()
  }

  // show the Nps Survey to user
  public func showNpsSurvey(event:String) {
    // only show survey if enough time has passed and no pendingSurvey to be sent
    if (daysSinceLastSurvey() > self.SURVEY_INTERVAL) && self.pendingSurvey == false {
      self.completedSurvey = ["event": event]
      let rootVC = UIApplication.sharedApplication().delegate?.window?!.rootViewController
      let surveyVC = SurveyViewController(nibName: nil, bundle: nil)
      rootVC!.presentViewController(surveyVC, animated: false, completion: nil)
    }else {
      printDebug("Not showing survey: \(daysSinceLastSurvey()) days since last survey, but interval is \(self.SURVEY_INTERVAL)")
    }
  }
  
  //# MARK: - Server Calls
  
  // send NPS Survey to Brilliant Server
  public func sendCompletedSurvey() {

    var attributes = self.completedSurvey!
    
    // set headers for auth and JSON content-type
    let headers = [
      "X-App-Key": self.appKey!,
      "Content-Type": "application/json"
    ]
    
    // add user data
    attributes["userEmail"] = self.userEmail
    attributes["userAcctCreation"] = String(self.userAcctCreationDate)
    attributes["userType"] = self.userType
    
    let params = ["nps_survey": attributes]
    
    // now send data to server
    Alamofire.request(.POST, "\(kBaseURL)surveys", headers: headers, parameters: params, encoding: .JSON)
      .responseString { _, response, result in
        if response?.statusCode == 201 {          // 201 means survey was created on server
          self.printDebug("Successfully saved to server.")
//          self.lastSurveyShownTime = NSDate()
          
          // no need to listen for internet connection change anymore
          let reachability = Reachability.reachabilityForInternetConnection()
          NSNotificationCenter.defaultCenter().removeObserver(self,
            name: ReachabilityChangedNotification,
            object: reachability)
          
          self.completedSurvey = nil
          self.pendingSurvey = false
        }
        else {
          self.printDebug("Saving Survey failed.")
          self.pendingSurvey = true

          // start listening for internet connection changes
          let reachability = Reachability.reachabilityForInternetConnection()
          
          NSNotificationCenter.defaultCenter().addObserver(self,
            selector: "reachabilityChanged:",
            name: ReachabilityChangedNotification,
            object: reachability)
          
          reachability!.startNotifier()
          self.printDebug("listening for network change")
        }
    }
  }

  private func getInitialSurveyData() {
    // set headers for auth and JSON content-type
    let headers = [
      "X-App-Key": self.appKey!,
      "Content-Type": "application/json"
    ]
    
    Alamofire.request(.GET, "\(kBaseURL)initWithAppKey", headers: headers)
      .responseJSON { request, response, result in
        switch result {
        case .Success(let JSON):
          self.appName = JSON["name"] as? String
          self.printDebug("initialization server call success. Setting app name to: \(self.appName)")

        case .Failure(_,_):
          // default to app bundle name
          self.appName = NSBundle.mainBundle().infoDictionary!["CFBundleName"] as? String
          self.printDebug("initialization server call failure. Setting app name to: \(self.appName)")
        }
    }
  }
  
  //# MARK: - Network Connection
  
  func reachabilityChanged(note: NSNotification) {
    
    let reachability = note.object as! Reachability
    
    if reachability.isReachable() {
      if self.pendingSurvey == true {
        self.sendCompletedSurvey()
        printDebug("Network reconnected, attempting to send survey.")
      }
    }
  }
  
  //# MARK: - Helpers

  private func daysSinceLastSurvey() -> Int {
    return NSCalendar.currentCalendar().components(.Day, fromDate: self.lastSurveyShownTime, toDate: NSDate(), options: []).day
  }
  
  // only print if debug flag is set
  private func printDebug(string: String) {
    if Brilliant.kDEBUG {
      print(string)
    }
  }
}
