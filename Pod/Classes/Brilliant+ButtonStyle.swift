//
//  Brilliant+Colors.swift
//  Pods
//
//  Created by Phillip Connaughton on 1/30/16.
//
//

import Foundation

extension Brilliant
{
    //Custom color for the buttons
    
    public func configureButtonColors(color: UIColor?) {
        if (color != nil)
        {
            self.npsButtonColorCustom = color!
            self.noThanksButtonColorCustom = color!
            self.npsReviewColorCustom = color!
            self.submitCommentsColorCustom = color!
            self.npsDoneColorCustom = color!
        }
    }
    
    public func configureFontName(name: String?) {
        if (name != nil) {
            self.customFontName = name!
        }
    }
    
    internal func npsButtonColor() -> UIColor
    {
        return self.npsButtonColorCustom
    }
    
    internal func noThanksButtonColor() -> UIColor
    {
        return self.noThanksButtonColorCustom
    }
    
    internal func submitCommentsColor() -> UIColor
    {
        return self.submitCommentsColorCustom
    }
    
    internal func npsReviewColor() -> UIColor
    {
        return self.npsReviewColorCustom
    }
    internal func npsDoneColor() -> UIColor
    {
        return self.npsDoneColorCustom
    }
    
    internal func mainLabelColor() -> UIColor
    {
        return UIColor.whiteColor()
    }
}