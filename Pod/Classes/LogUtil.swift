//
//  LogUtil.swift
//  Pods
//
//  Created by Phillip Connaughton on 1/24/16.
//
//

import Foundation


class LogUtil
{
    // only print if debug flag is set
    internal static func printDebug(string: String) {
        if Brilliant.kDEBUG {
            print(string)
        }
    }
}