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

@objc public class Brilliant: NSObject {

    private static let lastSurveyShownTimeKey = "lastSurveyShownTime"
    private static let completedSurveyKey = "completedSurvey"
    
//  public static let sharedInstance = Brilliant()
    private static var instanceVar: Brilliant?
    private static var onceToken: dispatch_once_t = 0
    
  //  need to use herokuapp subdomain in order have insecure POST requests (https solves this)
  private let kBaseURL = "https://www.brilliantapp.com/api/"
//  private let kBaseURL = "http://localhost:3000/api/"
  
  public let appKey: String
  public let appStoreId: String
  public let userEmail: String?
  public let userType: String?
    
  public let userDate: NSDate?
    
    //These variables are sent down from the server
    public var appName: String?
  
  private var lastSurveyShownTime: NSDate! {
    
    willSet(date) {
      NSUserDefaults.standardUserDefaults().setObject(date, forKey: Brilliant.lastSurveyShownTimeKey)
    }
  }
  
  // is there a survey that needs to be sent to server?
  private var pendingSurvey = false
  
  // survey data to be sent to server or saved to disk
    internal var completedSurvey: Survey? {
    willSet(survey) {
        //TODO: Load out as map and convert to Survey object
      NSUserDefaults.standardUserDefaults().setObject(survey?.serialize(), forKey: Brilliant.completedSurveyKey)
    }
  }

  // days between seeing surveys
  private var SURVEY_INTERVAL = 14
    
    #if DEBUG
    static var kDEBUG: Bool = true
    #else
    static var kDEBUG: Bool = false
    #endif
    
    public static func createInstance(key: String, appStoreId: String, userEmail: String?, userType: String?, userDate: NSDate?)
    {
        dispatch_once(&onceToken) { () -> Void in
            instanceVar = Brilliant(key: key, appStoreId: appStoreId, userEmail: userEmail, userType: userType, userDate: userDate)
            
            // if a pending survey is saved, load and attempt to resend
            if let surveyMap = NSUserDefaults.standardUserDefaults().objectForKey(Brilliant.completedSurveyKey) as? [String : String]
            {
                Brilliant.sharedInstance().completedSurvey = Survey(map: surveyMap)
              Brilliant.sharedInstance().pendingSurvey = true
              Brilliant.sharedInstance().sendCompletedSurvey()
            }
            else
            {
              Brilliant.sharedInstance().pendingSurvey = false
              Brilliant.sharedInstance().completedSurvey = Survey()
            }
    
            // pull data from server (for now just app name to display)
            Brilliant.sharedInstance().getInitialSurveyData()
        }
    }
    
    public static func sharedInstance() -> Brilliant
    {
        return instanceVar!
    }
  
    init(key: String, appStoreId: String, userEmail: String?, userType: String?, userDate: NSDate?) {
        self.appKey = key
        self.appStoreId = appStoreId
        self.userEmail = userEmail
        self.userType = userType
        self.userDate = userDate
    
        // set or initalize lastSurveyShownTime
        if let lastDate = NSUserDefaults.standardUserDefaults().objectForKey(Brilliant.lastSurveyShownTimeKey) as? NSDate
        {
          self.lastSurveyShownTime = lastDate
        }
        else
        {
          self.lastSurveyShownTime =  NSDate.distantPast()
        }
  }

  // show the Nps Survey to user
  public func showNpsSurvey(event:String) {
    // only show survey if enough time has passed and no pendingSurvey to be sent
    if (daysSinceLastSurvey() > self.SURVEY_INTERVAL) && self.pendingSurvey == false && UIApplication.sharedApplication().delegate?.window != nil
    {
      self.completedSurvey?.event = event
      let rootVC = UIApplication.sharedApplication().delegate!.window??.rootViewController
      let surveyVC = SurveyViewController(nibName: nil, bundle: nil)
      let modalStyle = UIModalTransitionStyle.CrossDissolve
      surveyVC.modalTransitionStyle = modalStyle
      surveyVC.modalPresentationStyle = UIModalPresentationStyle.OverCurrentContext
      rootVC!.presentViewController(surveyVC, animated: true, completion: nil)
    }
    else
    {
      if self.pendingSurvey
      {
        self.sendCompletedSurvey()
        printDebug("Not showing survey, attempting to send pending survey")
      }
      else if(UIApplication.sharedApplication().delegate?.window == nil)
      {
        printDebug("UIApplication.sharedApplication window is nil")
      }
      else
      {
        printDebug("Not showing survey: \(daysSinceLastSurvey()) days since last survey, but interval is \(self.SURVEY_INTERVAL)")
      }
    }
  }
  
  //# MARK: - Server Calls
  
  // send NPS Survey to Brilliant Server
  public func sendCompletedSurvey() {
    
    if(completedSurvey == nil)
    {
        printDebug("Survey was not filled out")
        return
    }
    
    // set headers for auth and JSON content-type
    let headers = [
      "X-App-Key": self.appKey,
      "Content-Type": "application/json"
    ]
    
    // add user data
    self.completedSurvey!.userEmail = self.userEmail
    if let acctCreationDate = self.userDate {
      self.completedSurvey!.userAccountCreation = acctCreationDate
    }
    
    self.completedSurvey!.userType = self.userType
    
    weak var weakSelf = self
    // now send data to server
    Alamofire.request(.POST, "\(kBaseURL)surveys", headers: headers, parameters: ["nps_survey": self.completedSurvey!.serializeForSurvey()], encoding: .JSON)
      .responseString { _, response, result in
        if response?.statusCode == 201 {          // 201 means survey was created on server
          weakSelf?.printDebug("Successfully saved to server.")

          if !Brilliant.kDEBUG {
            weakSelf?.lastSurveyShownTime = NSDate()
          }
          
          // no need to listen for internet connection change anymore
          let reachability = Reachability.reachabilityForInternetConnection()
          NSNotificationCenter.defaultCenter().removeObserver(self,
            name: ReachabilityChangedNotification,
            object: reachability)
          
          weakSelf?.completedSurvey = nil
          weakSelf?.pendingSurvey = false
        }
        else {
          weakSelf?.printDebug("Saving Survey failed.")
          weakSelf?.pendingSurvey = true

          // start listening for internet connection changes
          let reachability = Reachability.reachabilityForInternetConnection()
          
          NSNotificationCenter.defaultCenter().addObserver(self,
            selector: "reachabilityChanged:",
            name: ReachabilityChangedNotification,
            object: reachability)
          
          reachability!.startNotifier()
          weakSelf?.printDebug("listening for network change")
        }
    }
  }

  private func getInitialSurveyData() {
    // set headers for auth and JSON content-type
    let headers = [
      "X-App-Key": self.appKey,
      "Content-Type": "application/json"
    ]
    
    weak var weakSelf = self
    Alamofire.request(.GET, "\(kBaseURL)initWithAppKey", headers: headers)
      .responseJSON { request, response, result in
        switch result {
        case .Success(let JSON):
          weakSelf?.appName = JSON["name"] as? String
          weakSelf?.printDebug("initialization server call success. Setting app name to: \(self.appName)")

        case .Failure(_,_):
          // default to app bundle name
          weakSelf?.appName = NSBundle.mainBundle().infoDictionary!["CFBundleName"] as? String
          weakSelf?.printDebug("initialization server call failure. Setting app name to: \(self.appName)")
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
