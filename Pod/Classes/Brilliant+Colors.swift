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
    //Colors
    
    public func configureCustomColors(npsButtonColor: UIColor?, noThanksButtonColor: UIColor?, submitCommentsColor: UIColor?, npsReviewColor: UIColor?, npsDoneColor: UIColor?, shadowColor: UIColor?, mainLabelColor: UIColor?)
    {
        if(npsButtonColor != nil)
        {
            self.npsButtonColorCustom = npsButtonColor!
        }
        
        if(noThanksButtonColor != nil)
        {
            self.noThanksButtonColorCustom = noThanksButtonColor!
        }
        
        if(submitCommentsColor != nil)
        {
            self.submitCommentsColorCustom = submitCommentsColor!
        }
        
        if(npsReviewColor != nil)
        {
            self.npsReviewColorCustom = npsReviewColor!
        }
        
        if(npsDoneColor != nil)
        {
            self.npsDoneColorCustom = npsDoneColor!
        }
        
        if(shadowColor != nil)
        {
            self.shadowColorCustom = shadowColor!
        }
        
        if(mainLabelColor != nil)
        {
            self.mainLabelColorCustom = mainLabelColor!
        }
    }
    
    internal func npsButtonColor() -> UIColor
    {
        return UIColor(red: 0.313, green: 0.854, blue: 0.451, alpha: 1)
    }
    
    internal func noThanksButtonColor() -> UIColor
    {
        return UIColor(red: 0.313, green: 0.854, blue: 0.451, alpha: 1)
    }
    
    internal func submitCommentsColor() -> UIColor
    {
        return UIColor(red: 0.313, green: 0.854, blue: 0.451, alpha: 1)
    }
    
    internal func npsReviewColor() -> UIColor
    {
        return UIColor(red: 0.313, green: 0.854, blue: 0.451, alpha: 1)
    }
    internal func npsDoneColor() -> UIColor
    {
        return UIColor(red: 0.313, green: 0.854, blue: 0.451, alpha: 1)
    }
    
    internal func shadowColor() -> UIColor
    {
        return UIColor(red: 0.211, green: 0.660, blue: 0.324, alpha: 1)
    }
    
    internal func mainLabelColor() -> UIColor
    {
        return UIColor.whiteColor()
    }
}