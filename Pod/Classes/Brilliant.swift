//
//  Brilliant.swift
//  Pods
//
//  Created by Paul Berry on 9/20/15.
//
//

import Foundation

public class Brilliant {
  
  public static let sharedInstance = Brilliant()
  
  public var appKey:String = ""
  
  
  private init() {}
  
  public func initWithAppKey(key:String) {
    self.appKey = key
    print("function initialized with app key: \(appKey)")
  }
  
}
