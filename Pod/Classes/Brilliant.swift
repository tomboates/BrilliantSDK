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

@objc
open class Brilliant: NSObject {
    
    fileprivate static let lastSurveyShownTimeKey = "lastSurveyShownTime"
    fileprivate static let completedSurveyKey = "completedSurvey"
    fileprivate static let uniqueIdentifierKey = "uniqueIdentifier"
    
    //  public static let sharedInstance = Brilliant()
    fileprivate static var instanceVar: Brilliant?
    fileprivate static var onceToken: Int = 0
    
    open let appKey: String
    open let appStoreId: String?
    open let userId: String?
    open let userType: String?
    fileprivate let uniqueIdentifier: UUID
    
    open let userDate: Date?
    
    internal var npsButtonColorCustom = UIColor(red: 0.313, green: 0.854, blue: 0.451, alpha: 1)
    internal var noThanksButtonColorCustom = UIColor(red: 0.313, green: 0.854, blue: 0.451, alpha: 1)
    internal var submitCommentsColorCustom = UIColor(red: 0.313, green: 0.854, blue: 0.451, alpha: 1)
    internal var npsReviewColorCustom = UIColor(red: 0.313, green: 0.854, blue: 0.451, alpha: 1)
    internal var npsDoneColorCustom = UIColor(red: 0.313, green: 0.854, blue: 0.451, alpha: 1)
    internal var shadowColorCustom = UIColor(red: 0.211, green: 0.660, blue: 0.324, alpha: 1)
    internal var mainLabelColorCustom = UIColor.white
    
    internal var customFontName = "Default"
    
    //These variables are sent down from the server
    open var appName: String?
    
    fileprivate var eligible: Bool = false
    fileprivate var npsCompletion: ((_ success: Bool) -> Void)?
    
    fileprivate var lastSurveyShownTime: Date! {
        
        willSet(date) {
            UserDefaults.standard.set(date, forKey: Brilliant.lastSurveyShownTimeKey)
        }
    }
    
    // is there a survey that needs to be sent to server?
    fileprivate var pendingSurvey = false
    
    // survey data to be sent to server or saved to disk
    internal var completedSurvey: Survey? {
        willSet(survey) {
            //TODO: Load out as map and convert to Survey object
            UserDefaults.standard.set(survey?.serialize(), forKey: Brilliant.completedSurveyKey)
        }
    }
    
    /*#if DEBUG
    static var kDEBUG: Bool = true
    #else
    static var kDEBUG: Bool = false
    #endif*/
    static var kDEBUG: Bool = false
    
    open static func sharedInstance() -> Brilliant
    {
        return instanceVar!
    }
    
    open static func createInstance(_ key: String!, appStoreId: String?, userId: String?, userType: String?, userDate: Date?)
    {
        instanceVar = Brilliant(key: key, appStoreId: appStoreId, userId: userId, userType: userType, userDate: userDate)
        
        // if a pending survey is saved, load and attempt to resend
        if let surveyMap = UserDefaults.standard.object(forKey: Brilliant.completedSurveyKey) as? [String : String]
        {
            Brilliant.sharedInstance().completedSurvey = Survey(map: surveyMap as [String : AnyObject])
            Brilliant.sharedInstance().pendingSurvey = true
            Brilliant.sharedInstance().sendCompletedSurvey()
        }
        else
        {
            Brilliant.sharedInstance().pendingSurvey = false
        }
        
        // pull data from server (for now just app name to display)
        Brilliant.sharedInstance().getInitialSurveyData()
    }
    
    fileprivate init(key: String, appStoreId: String?, userId: String?, userType: String?, userDate: Date?) {
        self.appKey = key
        self.appStoreId = appStoreId
        self.userId = userId
        self.userType = userType
        self.userDate = userDate
        
        let uniqueIdentifierStr = UserDefaults.standard.string(forKey: Brilliant.uniqueIdentifierKey)
        
        if(uniqueIdentifierStr == nil)
        {
            self.uniqueIdentifier = UUID()
            UserDefaults.standard.set(self.uniqueIdentifier.uuidString, forKey: Brilliant.uniqueIdentifierKey)
        }
        else
        {
            self.uniqueIdentifier = UUID(uuidString: uniqueIdentifierStr!)!
        }
        
        // set or initalize lastSurveyShownTime
        if let lastDate = UserDefaults.standard.object(forKey: Brilliant.lastSurveyShownTimeKey) as? Date
        {
            self.lastSurveyShownTime = lastDate
        }
        else
        {
            self.lastSurveyShownTime =  Date.distantPast
        }
    }
    
    // show the Nps Survey to user
    open func showNpsSurvey(_ event: String, completed: (Bool) -> Void)
    {
        // only show survey if enough time has passed and no pendingSurvey to be sent
        if eligible && self.pendingSurvey == false && UIApplication.shared.delegate?.window != nil
        {
            Brilliant.sharedInstance().completedSurvey = Survey(surveyId: UUID())
            self.completedSurvey?.event = event
            let rootVC = UIApplication.shared.delegate!.window??.rootViewController
        
            let surveyVC = SurveyViewController(nibName: "SurveyViewController", bundle: Brilliant.xibBundle())
            let modalStyle = UIModalTransitionStyle.crossDissolve
            surveyVC.modalTransitionStyle = modalStyle
            surveyVC.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
            rootVC!.present(surveyVC, animated: true, completion: nil)
        }
        else
        {
            if self.pendingSurvey
            {
                self.sendCompletedSurvey()
                LogUtil.printDebug("Not showing survey, attempting to send pending survey")
            }
            else if(UIApplication.shared.delegate?.window == nil)
            {
                LogUtil.printDebug("UIApplication.sharedApplication window is nil")
            }
            else
            {
                LogUtil.printDebug("Not showing survey: \(daysSinceLastSurvey()) days since last survey, but interval is not eligible")
            }
        }
    }
    
    //# MARK: - Server Calls
    
    // send NPS Survey to Brilliant Server
    open func sendCompletedSurvey() {
        if(completedSurvey == nil)
        {
            LogUtil.printDebug("Survey was not filled out")
            return
        }
        
        eligible = false
        
        // add user data
        self.completedSurvey!.customerUserId = self.userId
        if let acctCreationDate = self.userDate {
            self.completedSurvey!.userAccountCreation = acctCreationDate
        }
        
        self.completedSurvey!.userType = self.userType
        
        weak var weakSelf = self
        // now send data to server
        guard let userId = userId else { return }
        
        BrilliantWebClient.request(.post, appKey: self.appKey, userId: userId, uniqueIdentifier: self.uniqueIdentifier, path: "surveys", params: ["nps_survey": self.completedSurvey!.serializeForSurvey() as AnyObject, "uniqueIdentifier": self.uniqueIdentifier.uuidString as AnyObject], success: { (JSON) -> Void in
            LogUtil.printDebug("Successfully saved to server.")
            
            if !Brilliant.kDEBUG {
                weakSelf?.lastSurveyShownTime = Date()
            }
            
            weakSelf?.completedSurvey = nil
            weakSelf?.pendingSurvey = false

            },
            failure:{ (Void) -> Void in
                LogUtil.printDebug("Saving Survey failed.")
                weakSelf?.pendingSurvey = true
        })
    }
    
    fileprivate func getInitialSurveyData() {
        weak var weakSelf = self
        guard let userId = userId else { return }
        
        BrilliantWebClient.request(.get, appKey: self.appKey, userId: userId, uniqueIdentifier: self.uniqueIdentifier, path: "initWithAppKey", params: ["uniqueIdentifier": self.uniqueIdentifier.uuidString as AnyObject, "advertistingId" : "" as AnyObject], success: { (JSON) -> Void in
            weakSelf?.appName = JSON["name"] as? String
            
            if let eligible = JSON["eligible"] as? Bool {
                weakSelf?.eligible = eligible
            }
            
            LogUtil.printDebug("initialization server call success. Setting app name to: \(self.appName)")
            }, failure:  { () -> Void in
                weakSelf?.appName = Bundle.main.infoDictionary!["CFBundleName"] as? String
                LogUtil.printDebug("initialization server call failure. Setting app name to: \(self.appName)")
        })
    }
    
    //# MARK: - Network Connection
    
    func reachabilityChanged(_ note: Notification) {
        
        let reachability = note.object as! Reachability
        
        if reachability.isReachable {
            if self.pendingSurvey == true {
                self.sendCompletedSurvey()
                LogUtil.printDebug("Network reconnected, attempting to send survey.")
            }
        }
    }
    
    //# MARK: - Helpers
    
    fileprivate func daysSinceLastSurvey() -> Int {
        return (Calendar.current as NSCalendar).components(.day, from: self.lastSurveyShownTime, to: Date(), options: []).day!
    }
    
    internal static func xibBundle() -> Bundle
    {
        let podBundle = Bundle(for: Brilliant.self)
        if let bundleURL = podBundle.url(forResource: "Brilliant", withExtension: "bundle")
        {
            return Bundle(url: bundleURL)!
        }
        else{
            return podBundle
        }
    }
    
    internal static func imageBundle() -> Bundle
    {
        let bundleURL = Bundle(for: Brilliant.self).url(forResource: "Brilliant", withExtension: "bundle")
        return Bundle(url: bundleURL!)!
    }
    
    //Texts
    func positiveFeedbackText(_ number: Int) -> String
    {
        return String(format: "What is the most important reason for choosing a %d?", number)
    }
    
    func negativeFeedbackText(_ number: Int) -> String
    {
        return String(format: "What is the most important reason for choosing a %d?", number)
    }
    
    //Fonts
    func mainLabelFont() -> UIFont
    {
        
//        switch UIDevice.currentDevice().userInterfaceIdiom
//        {
//        case .Pad:
//            return UIFont.systemFontOfSize(31)
//        case .Phone:
//            return UIFont.systemFontOfSize(21)
//        case .TV:
//            return UIFont.systemFontOfSize(34)
//        default:
//            return UIFont.systemFontOfSize(34)
//        }

        if (self.customFontName == "Default") {
            switch UIDevice.current.userInterfaceIdiom
            {
            case .pad:
                return UIFont.systemFont(ofSize: 31)
            case .phone:
                return UIFont.systemFont(ofSize: 21)
            case .tv:
                return UIFont.systemFont(ofSize: 34)
            default:
                return UIFont.systemFont(ofSize: 34)
            }
        } else {
            var size : CGFloat? = 0.0
            switch UIDevice.current.userInterfaceIdiom
            {
            case .pad:
                size = 31
            case .phone:
                size = 21
            case .tv:
                size = 34
            default:
                size = 34
            }
            let font = UIFont(name: self.customFontName, size: size!)
            if  font != nil {
                return font!
            } else {
                return UIFont.systemFont(ofSize: size!)
            }
        }
    }
    
    func levelLabelFont() -> UIFont
    {
        if (self.customFontName == "Default") {
            return UIFont.systemFont(ofSize: 14)
        } else {
            let font = UIFont(name: self.customFontName, size: 14)
            if  font != nil {
                return font!
            } else {
                return UIFont.systemFont(ofSize: 14)
            }
        }
    }
    
    func commentBoxFont() -> UIFont{
        if (self.customFontName == "Default") {
            return UIFont.systemFont(ofSize: 18)
        } else {
            let font = UIFont(name: self.customFontName, size: 18)
            if  font != nil {
                return font!
            } else {
                return UIFont.systemFont(ofSize: 18)
            }
        }
    }
    
    func submitButtonFont() -> UIFont
    {
        if (self.customFontName == "Default") {
            return UIFont.systemFont(ofSize: 18)
        } else {
            let font = UIFont(name: self.customFontName, size: 18)
            if  font != nil {
                return font!
            } else {
                return UIFont.systemFont(ofSize: 18)
            }
        }
    }
    
    func npsButtonFont() -> UIFont
    {
        if (self.customFontName == "Default") {
            switch UIDevice.current.userInterfaceIdiom
            {
            case .pad:
                return UIFont.systemFont(ofSize: 31)
            case .phone:
                return UIFont.systemFont(ofSize: 21)
            case .tv:
                return UIFont.systemFont(ofSize: 34)
            default:
                return UIFont.systemFont(ofSize: 34)
            }
        } else {
            var size : CGFloat? = 0.0
            switch UIDevice.current.userInterfaceIdiom
            {
            case .pad:
                size = 31
            case .phone:
                size = 21
            case .tv:
                size = 34
            default:
                size = 34
            }
            let font = UIFont(name: self.customFontName, size: size!)
            if  font != nil {
                return font!
            } else {
                return UIFont.systemFont(ofSize: size!)
            }
        }
    }
    
    //Style Button
    func styleButton(_ button: UIButton)
    {
        button.layer.cornerRadius = 4
        button.tintColor = UIColor.white
        button.backgroundColor = Brilliant.sharedInstance().submitCommentsColor()
    }
    
}
