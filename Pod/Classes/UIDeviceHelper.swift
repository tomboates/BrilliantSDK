//
//  UIDeviceHelper.swift
//  Pods
//
//  Created by Phillip Connaughton on 3/9/16.
//
//

import Foundation
import UIKit

class UIDeviceHelper
{
    static func deviceWidth() -> ScreenSize
    {
        let width = UIScreen.mainScreen().bounds.width
        
        if width <= 375
        {
            return .Small
        }
        else if width <= 414
        {
            return .Medium
        }
        else
        {
            return .Large
        }
    }
}