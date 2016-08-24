//
//  Survey.swift
//  Pods
//
//  Created by Phillip Connaughton on 12/5/15.
//
//

import Foundation

class Survey: NSObject
{
    var surveyId: UUID!
    
    var dismissAction: String?
    var userAccountCreation: Date?
    var triggerTimestamp : Date?
    var event: String?
    var comment: String?
    var customerUserId: String?
    var userType: String?
    var completedTimestamp: Date?
    var npsRating: Int?
    
    static let triggerTimestampKey = "trigger_timestamp"
    static let dismissActionKey = "dismiss_action"
    static let completedTimestampKey = "completed_timestamp"
    static let npsRatingKey = "nps_rating"
    static let commentsKey = "comments"
    static let userAccountCreationKey = "user_account_creation"
    static let eventKey = "event"
    static let customerUserIdKey = "customer_user_id"
    static let userTypeKey = "user_type"
    static let surveyIdKey = "survey_id"
    
    init(surveyId: UUID){
        self.surveyId = surveyId
    }
    
    init(map:[String: AnyObject])
    {
        self.triggerTimestamp = map[Survey.triggerTimestampKey] as? Date
        self.dismissAction = map[Survey.dismissActionKey] as? String
        self.completedTimestamp = map[Survey.completedTimestampKey] as? Date
        self.npsRating = map[Survey.npsRatingKey] as? Int
        self.comment = map[Survey.commentsKey] as? String
        self.userAccountCreation = map[Survey.userAccountCreationKey] as? Date
        self.event = map[Survey.eventKey] as? String
        self.customerUserId = map[Survey.customerUserIdKey] as? String
        self.userType = map[Survey.userTypeKey] as? String
        self.surveyId = UUID(uuidString: map[Survey.surveyIdKey] as! String)
    }
    
    func serialize() -> [String: AnyObject]
    {
        var map = [String: AnyObject]()
        
        map[Survey.triggerTimestampKey] = self.triggerTimestamp as AnyObject!
        map[Survey.dismissActionKey] = self.dismissAction as AnyObject!
        map[Survey.completedTimestampKey] = self.completedTimestamp as AnyObject!
        map[Survey.npsRatingKey] = self.npsRating as AnyObject!
        map[Survey.commentsKey] = self.comment as AnyObject!
        map[Survey.userAccountCreationKey] = self.userAccountCreation as AnyObject!
        map[Survey.eventKey] = self.event as AnyObject!
        map[Survey.customerUserIdKey] = self.customerUserId as AnyObject!
        map[Survey.userTypeKey] = self.userType as AnyObject!
        map[Survey.surveyIdKey] = self.surveyId.uuidString as AnyObject!
        
        return map
    }
    
    func serializeForSurvey() -> [String: String]
    {
        var map = [String: String]()
        
        if(self.triggerTimestamp != nil)
        {
            map[Survey.triggerTimestampKey] = String(self.triggerTimestamp!.timeIntervalSince1970)
        }
        
        map[Survey.dismissActionKey] = self.dismissAction
        
        if(self.completedTimestamp != nil)
        {
            map[Survey.completedTimestampKey] = String(self.completedTimestamp!.timeIntervalSince1970)
        }
        
        if(self.npsRating != nil)
        {
            map[Survey.npsRatingKey] = String(self.npsRating!)
        }
        
        map[Survey.commentsKey] = self.comment
        
        if(self.userAccountCreation == nil)
        {
            map[Survey.userAccountCreationKey] = String(self.userAccountCreation!.timeIntervalSince1970)
        }
        
        map[Survey.eventKey] = self.event
        map[Survey.customerUserIdKey] = self.customerUserId
        map[Survey.userTypeKey] = self.userType
        map[Survey.surveyIdKey] = self.surveyId.uuidString
        
        return map
    }
}
