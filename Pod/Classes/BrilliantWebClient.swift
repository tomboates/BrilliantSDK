//
//  BrilliantWebClient.swift
//  Pods
//
//  Created by Phillip Connaughton on 1/24/16.
//
//

import Foundation
import Alamofire
import ReachabilitySwift

class BrilliantWebClient
{
    //  need to use herokuapp subdomain in order have insecure POST requests (https solves this)
    static private let kBaseURL = "https://www.brilliantapp.com/api/"
    //  private let kBaseURL = "http://localhost:3000/api/"
    
    static func request(method: Alamofire.Method, appKey: String, userId: NSUUID, path: String, params: [String: AnyObject]?, success: (AnyObject) -> Void, failure: (Void) -> Void)
    {
        let appVersion = NSBundle.mainBundle().objectForInfoDictionaryKey("CFBundleVersion") as! String
        // set headers for auth and JSON content-type
        let headers = [
            "X-App-Key": appKey,
            "X-App-Version": appVersion,
            "Content-Type": "application/json",
            "X-App-UserId" : userId.UUIDString
        ]
        
        // now send data to server
        Alamofire.request(method, "\(kBaseURL)" + path, headers: headers, parameters: params, encoding: .JSON)
            .responseJSON(completionHandler: { (request, ResponseSerializer, result) -> Void in
                
                switch(result)
                {
                case .Success(let JSON):
                    // no need to listen for internet connection change anymore
                    let reachability = Reachability.reachabilityForInternetConnection()
                    NSNotificationCenter.defaultCenter().removeObserver(self,
                        name: ReachabilityChangedNotification,
                        object: reachability)
                    success(JSON)
                    break
                case .Failure(let data, let type):
                    
                    if(data != nil)
                    {
                        LogUtil.printDebug("BrilliantWebClient error " + data!.description)
                    }
                    
                    // start listening for internet connection changes
                    let reachability = Reachability.reachabilityForInternetConnection()
                    
                    NSNotificationCenter.defaultCenter().addObserver(self,
                        selector: "reachabilityChanged:",
                        name: ReachabilityChangedNotification,
                        object: reachability)
                    
                    reachability!.startNotifier()
                    LogUtil.printDebug("listening for network change")
                    failure()
                    break
                }
        })
    }
}