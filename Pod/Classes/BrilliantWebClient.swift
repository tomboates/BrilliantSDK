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
        
        var encoding = URLEncoding.default
        if (method == .post) {
            encoding = .default
        }
        
        // now send data to server
     
        if #available(iOS 9.0, *) {
            Alamofire.request("\(kBaseURL)" + path, method: method, parameters: params, encoding: encoding, headers: headers)
                .responseJSON { response in
                    switch(response.result){
                    case .success:
                        // no need to listen for internet connection change anymore
                        let reachability = Reachability()!
                        reachability.stopNotifier()
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
                        let reachability = Reachability()!
                        
                        NotificationCenter.default.addObserver(self,    selector: "reachabilityChanged:",
                                                                         name: ReachabilityChangedNotification,
                                                                         object: reachability)
                        do {
                            try reachability.startNotifier()
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
    }
    
    func reachabilityChanged(note: NSNotification) {
        
        let reachability = note.object as! Reachability
        
        if reachability.isReachable {
            if reachability.isReachableViaWiFi {
                print("Reachable via WiFi")
            } else {
                print("Reachable via Cellular")
            }
        } else {
            print("Network not reachable")
        }
    }
}
