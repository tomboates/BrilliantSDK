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
    var surveyId: NSUUID!
    
    var dismissAction: String?
    var userAccountCreation: NSDate?
    var triggerTimestamp : NSDate?
    var event: String?
    var comment: String?
    var userEmail: String?
    var userType: String?
    var completedTimestamp: NSDate?
    var npsRating: Int?
    
    static let triggerTimestampKey = "triggerTimestamp"
    static let dismissActionKey = "dismissAction"
    static let completedTimestampKey = "completedTimestamp"
    static let npsRatingKey = "npsRating"
    static let commentsKey = "comments"
    static let userAccountCreationKey = "userAcctCreation"
    static let eventKey = "event"
    static let userEmailKey = "userEmail"
    static let userTypeKey = "userType"
    static let surveyIdKey = "survey_id"
    
    init(surveyId: NSUUID){
        self.surveyId = surveyId
    }
    
    init(map:[String: AnyObject])
    {
        self.triggerTimestamp = map[Survey.triggerTimestampKey] as? NSDate
        self.dismissAction = map[Survey.dismissActionKey] as? String
        self.completedTimestamp = map[Survey.completedTimestampKey] as? NSDate
        self.npsRating = map[Survey.npsRatingKey] as? Int
        self.comment = map[Survey.commentsKey] as? String
        self.userAccountCreation = map[Survey.userAccountCreationKey] as? NSDate
        self.event = map[Survey.eventKey] as? String
        self.userEmail = map[Survey.userEmailKey] as? String
        self.userType = map[Survey.userTypeKey] as? String
        self.surveyId = NSUUID(UUIDString: map[Survey.surveyIdKey] as! String)
    }
    
    func serialize() -> [String: AnyObject]
    {
        var map = [String: AnyObject]()
        
        map[Survey.triggerTimestampKey] = self.triggerTimestamp
        map[Survey.dismissActionKey] = self.dismissAction
        map[Survey.completedTimestampKey] = self.completedTimestamp
        map[Survey.npsRatingKey] = self.npsRating
        map[Survey.commentsKey] = self.comment
        map[Survey.userAccountCreationKey] = self.userAccountCreation
        map[Survey.eventKey] = self.event
        map[Survey.userEmailKey] = self.userEmail
        map[Survey.userTypeKey] = self.userType
        map[Survey.surveyIdKey] = self.surveyId.UUIDString
        
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
        map[Survey.userEmailKey] = self.userEmail
        map[Survey.userTypeKey] = self.userType
        map[Survey.surveyIdKey] = self.surveyId.UUIDString
        
        return map
    }
}