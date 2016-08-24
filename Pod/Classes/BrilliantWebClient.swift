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
    static fileprivate let kBaseURL = "https://www.brilliantapp.com/api/"
    //  private let kBaseURL = "http://localhost:3000/api/"
    
    static func request(_ method: Alamofire.HTTPMethod, appKey: String, uniqueIdentifier: UUID, path: String, params: [String: AnyObject]?, success: @escaping (AnyObject) -> Void, failure: @escaping (Void) -> Void)
    {
        let appVersion = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as! String
        // set headers for auth and JSON content-type
        let headers = [
            "X-App-Key": appKey,
            "X-App-Version": appVersion,
            "Content-Type": "application/json",
        ]
        
        var encoding = ParameterEncoding.url
        if (method == .post) {
            encoding = .url
        }
        
        // now send data to server
     
        if #available(iOS 9.0, *) {
            Alamofire.request("\(kBaseURL)" + path, withMethod: method, parameters: params, encoding: encoding, headers: headers)
                .responseJSON { response in
                    switch(response.result){
                    case .success:
                        // no need to listen for internet connection change anymore
                        let reachability = Reachability.init()
                        NotificationCenter.default.removeObserver(self,   name: ReachabilityChangedNotification,
                                                                            object: reachability)
                        success(response.result.value as AnyObject)
                        break
                    case .failure:
                        
                        if(response.result.value != nil)
                        {
                            LogUtil.printDebug("BrilliantWebClient error " + (response.result.value! as AnyObject).description)
                        }
                        
                        // start listening for internet connection changes
                        let reachability = Reachability.init()
                        
                        NotificationCenter.default.addObserver(self,
                                                                         selector: "reachabilityChanged:",
                                                                         name: ReachabilityChangedNotification,
                                                                         object: reachability)
                        do {
                            try reachability!.startNotifier()
                        } catch {
                            print("Unable to start notifier")
                        }
                        
                        LogUtil.printDebug("listening for network change")
                        failure()
                        break
                    }

            }
        } else {
            // Fallback on earlier versions
        }
//        Alamofire.request(method, "\(kBaseURL)" + path, headers: headers, parameters: params, encoding: encoding)
     /*       .responseJSON(completionHandler: { (request, ResponseSerializer, result) -> Void in
                
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
                case .Failure(let data, _):
                    
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
*/
    }
}
