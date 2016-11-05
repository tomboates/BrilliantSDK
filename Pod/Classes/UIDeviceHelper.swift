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
        let width = UIScreen.main.bounds.width
        
        if width <= 375
        {
            return .small
        }
        else if width <= 414
        {
            return .medium
        }
        else
        {
            return .large
        }
    }
}
