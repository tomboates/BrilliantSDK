//
//  Brilliant.swift
//  Pods
//
//  Created by Paul Berry on 9/20/15.
//
//

import Foundation
import ReachabilitySwift

@objc
public class Brilliant: NSObject {
    
    private static let lastSurveyShownTimeKey = "lastSurveyShownTime"
    private static let completedSurveyKey = "completedSurvey"
    
    //  public static let sharedInstance = Brilliant()
    private static var instanceVar: Brilliant?
    private static var onceToken: dispatch_once_t = 0
    
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
    
    public static func sharedInstance() -> Brilliant
    {
        return instanceVar!
    }
    
    public static func createInstance(key: String!, appStoreId: String!, userEmail: String?, userType: String?, userDate: NSDate?)
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
    
    private init(key: String, appStoreId: String, userEmail: String?, userType: String?, userDate: NSDate?) {
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
    public func showNpsSurvey(event: String)
    {
        // only show survey if enough time has passed and no pendingSurvey to be sent
        if (daysSinceLastSurvey() > self.SURVEY_INTERVAL) && self.pendingSurvey == false && UIApplication.sharedApplication().delegate?.window != nil
        {
            self.completedSurvey?.event = event
            let rootVC = UIApplication.sharedApplication().delegate!.window??.rootViewController
        
            let surveyVC = SurveyViewController(nibName: "SurveyViewController", bundle: Brilliant.xibBundle())
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
                LogUtil.printDebug("Not showing survey, attempting to send pending survey")
            }
            else if(UIApplication.sharedApplication().delegate?.window == nil)
            {
                LogUtil.printDebug("UIApplication.sharedApplication window is nil")
            }
            else
            {
                LogUtil.printDebug("Not showing survey: \(daysSinceLastSurvey()) days since last survey, but interval is \(self.SURVEY_INTERVAL)")
            }
        }
    }
    
    //# MARK: - Server Calls
    
    // send NPS Survey to Brilliant Server
    public func sendCompletedSurvey() {
        
        if(completedSurvey == nil)
        {
            LogUtil.printDebug("Survey was not filled out")
            return
        }        
        
        // add user data
        self.completedSurvey!.userEmail = self.userEmail
        if let acctCreationDate = self.userDate {
            self.completedSurvey!.userAccountCreation = acctCreationDate
        }
        
        self.completedSurvey!.userType = self.userType
        
        weak var weakSelf = self
        // now send data to server
        BrilliantWebClient.request(.POST, appKey: self.appKey, path: "surveys", params: ["nps_survey": self.completedSurvey!.serializeForSurvey()], success: { (JSON) -> Void in
            LogUtil.printDebug("Successfully saved to server.")
            
            if !Brilliant.kDEBUG {
                weakSelf?.lastSurveyShownTime = NSDate()
            }
            
            weakSelf?.completedSurvey = nil
            weakSelf?.pendingSurvey = false

            },
            failure:{ (Void) -> Void in
                LogUtil.printDebug("Saving Survey failed.")
                weakSelf?.pendingSurvey = true
        })
    }
    
    private func getInitialSurveyData() {
        weak var weakSelf = self
        BrilliantWebClient.request(.GET, appKey: self.appKey, path: "initWithAppKey", params: nil, success: { (JSON) -> Void in
            weakSelf?.appName = JSON["name"] as? String
            LogUtil.printDebug("initialization server call success. Setting app name to: \(self.appName)")
            }, failure:  { () -> Void in
                weakSelf?.appName = NSBundle.mainBundle().infoDictionary!["CFBundleName"] as? String
                LogUtil.printDebug("initialization server call failure. Setting app name to: \(self.appName)")
        })
    }
    
    //# MARK: - Network Connection
    
    func reachabilityChanged(note: NSNotification) {
        
        let reachability = note.object as! Reachability
        
        if reachability.isReachable() {
            if self.pendingSurvey == true {
                self.sendCompletedSurvey()
                LogUtil.printDebug("Network reconnected, attempting to send survey.")
            }
        }
    }
    
    //# MARK: - Helpers
    
    private func daysSinceLastSurvey() -> Int {
        return NSCalendar.currentCalendar().components(.Day, fromDate: self.lastSurveyShownTime, toDate: NSDate(), options: []).day
    }
    
    internal static func xibBundle() -> NSBundle
    {
        return NSBundle(forClass: Brilliant.self)
    }
    
    internal static func imageBundle() -> NSBundle
    {
        let bundleURL = NSBundle(forClass: Brilliant.self).URLForResource("Brilliant", withExtension: "bundle")
        return NSBundle(URL: bundleURL!)!
    }
    
    //Texts
    func positiveFeedbackText(number: Int) -> String
    {
        return String(format: "Great can you tell us why you choose a %d?", number)
    }
    
    func negativeFeedbackText(number: Int) -> String
    {
        return String(format: "Bummer! Can you tell us why you choose a %d?", number)
    }
    
    
    //Colors
    
    func npsButtonColor() -> UIColor
    {
        return UIColor(red: 0.313, green: 0.854, blue: 0.451, alpha: 1)
    }
    
    func noThanksButtonColor() -> UIColor
    {
        return UIColor(red: 0.313, green: 0.854, blue: 0.451, alpha: 1)
    }
    
    func submitCommentsColor() -> UIColor
    {
        return UIColor(red: 0.313, green: 0.854, blue: 0.451, alpha: 1)
    }
    
    func npsReviewColor() -> UIColor
    {
        return UIColor(red: 0.313, green: 0.854, blue: 0.451, alpha: 1)
    }
    func npsDoneColor() -> UIColor
    {
        return UIColor(red: 0.313, green: 0.854, blue: 0.451, alpha: 1)
    }
    
    func shadowColor() -> UIColor
    {
        return UIColor(red: 0.211, green: 0.660, blue: 0.324, alpha: 1)
    }
    
    func mainLabelColor() -> UIColor
    {
        return UIColor.whiteColor()
    }
    
    //Fonts
    func mainLabelFont() -> UIFont
    {
        
        switch UIDevice.currentDevice().userInterfaceIdiom
        {
        case .Pad:
            return UIFont.systemFontOfSize(34)
        case .Phone:
            return UIFont.systemFontOfSize(23)
        case .TV:
            return UIFont.systemFontOfSize(34)
        case .Unspecified:
            return UIFont.systemFontOfSize(34)
        }
        
    }
    
    //Style Button
    func styleButton(button: UIButton)
    {
        button.layer.cornerRadius = 4
        button.tintColor = UIColor.whiteColor()
        button.layer.shadowColor = Brilliant.sharedInstance().shadowColor().CGColor
        button.layer.shadowOffset = CGSizeMake(0, 2)
        button.layer.shadowRadius = 0
        button.layer.shadowOpacity = 1.0
        button.backgroundColor = UIColor(red: 0.313, green: 0.854, blue: 0.451, alpha: 1)
    }
    
}
