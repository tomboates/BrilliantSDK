//
//  SurveyViewController.swift
//  Pods
//
//  Created by Paul Berry on 9/22/15.
//
//

import Foundation
import UIKit

class SurveyViewController: UIViewController, NPSScoreViewControllerDelegate, CommentsViewControllerDelegate, RateAppViewControllerDelegate, NegativeFeedbackCompleteViewControllerDelegate {
    
    var blurEffect: UIBlurEffect?
    var blurEffectView: UIVisualEffectView?
    
    //Phils variables
    var npsScoreVC: NPSScoreViewController?
    var commentsVC: CommentsViewController?
    var rateAppVC: RateAppViewController?
    var negativeFeedbackVC: NegativeFeedbackCompleteViewController?
    
    var state: SurveyViewControllerState // keep track of what screen is showing for analytics
    
    required init?(coder aDecoder: NSCoder) {
        self.state = .RatingScreen
        super.init(coder: aDecoder)
    }
    
    override init(nibName nibNameOrNil: String!, bundle: NSBundle!) {
        self.state = .RatingScreen
        super.init(nibName: nibNameOrNil, bundle: bundle)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //only apply the blur if the user hasn't disabled transparency effects
        if !UIAccessibilityIsReduceTransparencyEnabled() {
            self.view.backgroundColor = UIColor.clearColor()
            blurEffect = UIBlurEffect(style: UIBlurEffectStyle.Dark);
            blurEffectView = UIVisualEffectView(effect: blurEffect);
            
            blurEffectView!.frame = CGRectMake(0, 0, 2732, 2732)
            
            self.view.addSubview(blurEffectView!)
        }
        else
        {
            self.view.backgroundColor = UIColor.blackColor()
        }
        
        Brilliant.sharedInstance().completedSurvey?.triggerTimestamp = NSDate()
        
        self.npsScoreVC = NPSScoreViewController(nibName: "NPSScoreViewController", bundle: Brilliant.xibBundle())
        self.npsScoreVC!.delegate = self
        self.addFullScreenSubViewController(self.npsScoreVC!)
        
    }
    
    func addFullScreenSubViewController(subViewController: UIViewController)
    {
        self.addChildViewController(subViewController)
        self.view.addSubview(subViewController.view)
        subViewController.view.translatesAutoresizingMaskIntoConstraints = false
        
        let hConstraints = NSLayoutConstraint.constraintsWithVisualFormat("H:|-0-[subViewController]-0-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["subViewController" : subViewController.view])
        let vConstraints = NSLayoutConstraint.constraintsWithVisualFormat("V:|-0-[subViewController]-0-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["subViewController" : subViewController.view])
        self.view.addConstraints(hConstraints)
        self.view.addConstraints(vConstraints)
    }
    
    func viewControllerTransition(oldVC: UIViewController?, newVC: UIViewController)
    {
        UIView.animateWithDuration(0.3, animations: { () -> Void in
            oldVC?.view.alpha = 0
            newVC.view.alpha = 1
            }) { (success) -> Void in
                oldVC?.removeFromParentViewController()
                oldVC?.view.removeFromSuperview()
        }
    }
    
    //NPSScoreViewControllerDelegate
    func closePressed(state: SurveyViewControllerState)
    {
        switch state
        {
        case .RatingScreen: // rating screen
            Brilliant.sharedInstance().completedSurvey!.dismissAction = "x_npsscreen"
            break
        case .CommentScreen: // comment screen
            Brilliant.sharedInstance().completedSurvey!.dismissAction = "x_comments"
            break
        case .FeedbackScreen: // feedback screen
            Brilliant.sharedInstance().completedSurvey!.dismissAction = "x_feedback"
            break
        case .RateAppScreen: // rate the app screen
            Brilliant.sharedInstance().completedSurvey!.dismissAction = "x_rateapp"
            break
        }
        
        close()
    }
    
    func close()
    {
        UIView.animateWithDuration(0.2, delay: 0.0, options: UIViewAnimationOptions.CurveEaseIn, animations: {
            
            self.blurEffectView?.alpha = 0
            self.npsScoreVC?.view.alpha = 0
            self.commentsVC?.view.alpha = 0
            self.rateAppVC?.view.alpha = 0
            self.negativeFeedbackVC?.view.alpha = 0
            
            }, completion: {_ in
                UIView.animateWithDuration(0.3, delay: 0.5, options: UIViewAnimationOptions.CurveEaseIn, animations: {
                    self.dismissViewControllerAnimated(true, completion: nil)
                    
                    }, completion: {_ in
                        // SEND SURVEY DATA
                        Brilliant.sharedInstance().completedSurvey!.completedTimestamp = NSDate()
                        Brilliant.sharedInstance().sendCompletedSurvey()
                })
        })
    }

    func npsScorePressed(npsScore: Int)
    {
        self.commentsVC = CommentsViewController(nibName: "CommentsViewController", bundle: Brilliant.xibBundle())
        self.commentsVC!.delegate = self
        self.commentsVC!.view.alpha = 0
        self.addFullScreenSubViewController(self.commentsVC!)
        
        self.viewControllerTransition(self.npsScoreVC, newVC: self.commentsVC!)
    }
    
    //CommentsViewControllerDelegate
    func submitFeedbackPressed()
    {
        if(Brilliant.sharedInstance().completedSurvey!.npsRating >= 7 && Brilliant.sharedInstance().appStoreId != nil)
        {
            self.rateAppVC = RateAppViewController(nibName: "RateAppViewController", bundle: Brilliant.xibBundle())
            self.rateAppVC?.delegate = self
            self.rateAppVC!.view.alpha = 0
            self.addFullScreenSubViewController(self.rateAppVC!)
            self.viewControllerTransition(self.commentsVC, newVC: self.rateAppVC!)
        }
        else if(Brilliant.sharedInstance().completedSurvey!.npsRating >= 7 && Brilliant.sharedInstance().appStoreId != nil)
        {
            self.close()
        }
        else
        {
            self.negativeFeedbackVC = NegativeFeedbackCompleteViewController(nibName: "NegativeFeedbackCompleteViewController", bundle: Brilliant.xibBundle())
            self.negativeFeedbackVC!.delegate = self
            self.addFullScreenSubViewController(self.negativeFeedbackVC!)
            self.viewControllerTransition(self.commentsVC, newVC: self.negativeFeedbackVC!)
        }
    }
    
    func doNotSubmitFeedbackPressed()
    {
        Brilliant.sharedInstance().completedSurvey!.dismissAction =  "nothanks_comments"
        self.close()
    }
    
    
    //RateAppViewControllerDelegate
    func rateAppPressed()
    {
        let url = "itms-apps://itunes.apple.com/app/id\(Brilliant.sharedInstance().appStoreId)"
        UIApplication.sharedApplication().openURL(NSURL(string: url)!)
        
        Brilliant.sharedInstance().completedSurvey!.dismissAction =  "sure_rateapp"
        self.close()
    }
    
    func doNotRateAppPressed()
    {
        Brilliant.sharedInstance().completedSurvey!.dismissAction = "nothanks_rateapp"
        self.close()
    }
    
    //NegativeFeedbackCompleteViewControllerDelegate
    func doneWithFeedbackPressed()
    {
        Brilliant.sharedInstance().completedSurvey!.dismissAction = "done_feedback"
        self.close()
    }
    
    func autoDismissFeedbackComplete()
    {
        Brilliant.sharedInstance().completedSurvey!.dismissAction = "auto_dismiss"
        self.close()
    }
}
