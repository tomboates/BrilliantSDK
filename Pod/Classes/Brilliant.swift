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
    private static let uniqueIdentifierKey = "uniqueIdentifier"
    
    //  public static let sharedInstance = Brilliant()
    private static var instanceVar: Brilliant?
//    private static var onceToken: dispatch_once_t = 0
    
    public let appKey: String
    public let appStoreId: String?
    public let userId: String?
    public let userType: String?
    private let uniqueIdentifier: NSUUID
    
    public let userDate: NSDate?
    
    internal var npsButtonColorCustom = UIColor(red: 0.313, green: 0.854, blue: 0.451, alpha: 1)
    internal var noThanksButtonColorCustom = UIColor(red: 0.313, green: 0.854, blue: 0.451, alpha: 1)
    internal var submitCommentsColorCustom = UIColor(red: 0.313, green: 0.854, blue: 0.451, alpha: 1)
    internal var npsReviewColorCustom = UIColor(red: 0.313, green: 0.854, blue: 0.451, alpha: 1)
    internal var npsDoneColorCustom = UIColor(red: 0.313, green: 0.854, blue: 0.451, alpha: 1)
    internal var shadowColorCustom = UIColor(red: 0.211, green: 0.660, blue: 0.324, alpha: 1)
    internal var mainLabelColorCustom = UIColor.white
    
    internal var customFontName = "Default"
    
    //These variables are sent down from the server
    public var appName: String?
    
    private var eligible: Bool = false
    private var npsCompletion: ((_ success: Bool) -> Void)?
    
    private var lastSurveyShownTime: Date {
        
        willSet(date) {
            UserDefaults.standard.set(date, forKey: Brilliant.lastSurveyShownTimeKey)
        }
    }
    
    // is there a survey that needs to be sent to server?
    private var pendingSurvey = false
    
    // survey data to be sent to server or saved to disk
    internal var completedSurvey: Survey? {
        willSet(survey) {
            //TODO: Load out as map and convert to Survey object
            UserDefaults.standard.set(survey?.serialize(), forKey: Brilliant.completedSurveyKey)
        }
    }
    
    #if DEBUG
    static var kDEBUG: Bool = true
    #else
    static var kDEBUG: Bool = false
    #endif
    
    public static func sharedInstance() -> Brilliant
    {
        return instanceVar!
    }
    
    public static func createInstance(key: String!, appStoreId: String?, userId: String?, userType: String?, userDate: NSDate?)
    {
//        dispatch_once(&onceToken) { () -> Void in
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
//        }
    }
    
    private init(key: String, appStoreId: String?, userId: String?, userType: String?, userDate: NSDate?) {
        self.appKey = key
        self.appStoreId = appStoreId
        self.userId = userId
        self.userType = userType
        self.userDate = userDate
        
        let uniqueIdentifierStr = UserDefaults.standard.string(forKey: Brilliant.uniqueIdentifierKey)
        
        if(uniqueIdentifierStr == nil)
        {
            self.uniqueIdentifier = NSUUID()
            UserDefaults.standard.set(self.uniqueIdentifier.uuidString, forKey: Brilliant.uniqueIdentifierKey)
        }
        else
        {
            self.uniqueIdentifier = NSUUID(uuidString: uniqueIdentifierStr!)!
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
    public func showNpsSurvey(event: String, completed: (Bool) -> Void)
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
    public func sendCompletedSurvey() {
        if(completedSurvey == nil)
        {
            LogUtil.printDebug("Survey was not filled out")
            return
        }        
        
        // add user data
        self.completedSurvey!.customerUserId = self.userId
        if let acctCreationDate = self.userDate {
            self.completedSurvey!.userAccountCreation = acctCreationDate as Date
        }
        
        self.completedSurvey!.userType = self.userType
        
        weak var weakSelf = self
        // now send data to server
        BrilliantWebClient.request(.post, appKey: self.appKey, uniqueIdentifier: self.uniqueIdentifier as UUID, path: "surveys", params: ["nps_survey": self.completedSurvey!.serializeForSurvey() as AnyObject, "uniqueIdentifier": self.uniqueIdentifier.uuidString as AnyObject], success: { (JSON) -> Void in
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
    
    private func getInitialSurveyData() {
        weak var weakSelf = self
        BrilliantWebClient.request(.get, appKey: self.appKey, uniqueIdentifier: self.uniqueIdentifier as UUID, path: "initWithAppKey", params: ["uniqueIdentifier": self.uniqueIdentifier.uuidString as AnyObject, "advertistingId" : "" as AnyObject], success: { (JSON) -> Void in
            if let jsonResult = JSON as? Dictionary<String, AnyObject> {
                weakSelf?.appName = jsonResult["name"] as? String
                
                if let eligible = jsonResult["eligible"] as? Bool {
                    weakSelf?.eligible = eligible
                }
            }
            LogUtil.printDebug("initialization server call success. Setting app name to: \(self.appName)")
            }, failure:  { () -> Void in
                weakSelf?.appName = Bundle.main.infoDictionary!["CFBundleName"] as? String
                LogUtil.printDebug("initialization server call failure. Setting app name to: \(self.appName)")
        })
    }
    
    //# MARK: - Network Connection
    
    func reachabilityChanged(note: NSNotification) {
        
        let reachability = note.object as! Reachability
        
        if reachability.isReachable {
            if self.pendingSurvey == true {
                self.sendCompletedSurvey()
                LogUtil.printDebug("Network reconnected, attempting to send survey.")
            }
        }
    }
    
    private func daysSinceLastSurvey() -> Int {
        let unitFlags = Set<Calendar.Component>([.hour, .year, .minute])
        return Calendar.current.dateComponents(unitFlags, from: self.lastSurveyShownTime, to: Date()).day!
    }
    
    open static func xibBundle() -> Bundle
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
    
    open static func imageBundle() -> Bundle
    {
        let bundleURL = Bundle(for: Brilliant.self).url(forResource: "Brilliant", withExtension: "bundle")
        return Bundle(url: bundleURL!)!
    }
    
    //Texts
    func positiveFeedbackText(number: Int) -> String
    {
        return String(format: "What is the most important reason for choosing a %d?", number)
    }
    
    func negativeFeedbackText(number: Int) -> String
    {
        return String(format: "What is the most important reason for choosing a %d?", number)
    }
    
    //Fonts
    func mainLabelFont() -> UIFont
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
    
    func levelLabelFont() -> UIFont
    {
        if (self.customFontName == "Default") {
            return UIFont.systemFont(ofSize:14)
        } else {
            let font = UIFont(name: self.customFontName, size: 14)
            if  font != nil {
                return font!
            } else {
                return UIFont.systemFont(ofSize:14)
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
    func styleButton(button: UIButton)
    {
        button.layer.cornerRadius = 4
        button.tintColor = UIColor.white
        button.backgroundColor = Brilliant.sharedInstance().submitCommentsColor()
    }
    
}
