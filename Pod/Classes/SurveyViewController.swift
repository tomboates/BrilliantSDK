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
    
    
    func submitComments(sender: UIButton!) {
//        Brilliant.sharedInstance().completedSurvey!.comment = self.comments.text        
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
        self.npsScoreVC?.removeFromParentViewController()
        self.npsScoreVC?.view.removeFromSuperview()
        
        self.commentsVC = CommentsViewController(nibName: "CommentsViewController", bundle: Brilliant.xibBundle())
        self.commentsVC!.delegate = self
        self.addFullScreenSubViewController(self.commentsVC!)
    }
    
    //CommentsViewControllerDelegate
    func submitFeedbackPressed()
    {
        self.commentsVC?.removeFromParentViewController()
        self.commentsVC?.view.removeFromSuperview()
        
        if(Brilliant.sharedInstance().completedSurvey!.npsRating >= 7)
        {
            self.rateAppVC = RateAppViewController(nibName: "RateAppViewController", bundle: Brilliant.xibBundle())
            self.rateAppVC?.delegate = self
            self.addFullScreenSubViewController(self.rateAppVC!)
        }
        else
        {
            self.negativeFeedbackVC = NegativeFeedbackCompleteViewController(nibName: "NegativeFeedbackCompleteViewController", bundle: Brilliant.xibBundle())
            self.negativeFeedbackVC!.delegate = self
            self.addFullScreenSubViewController(self.negativeFeedbackVC!)
        }
    }
    
    func doNotSubmitFeedbackPressed()
    {
        //TODO: Log the write stuff to the survey
        self.close()
    }
    
    
    //RateAppViewControllerDelegate
    func rateAppPressed()
    {
        let url = "itms-apps://itunes.apple.com/app/id\(Brilliant.sharedInstance().appStoreId)"
        UIApplication.sharedApplication().openURL(NSURL(string: url)!)

        self.close()
    }
    
    func doNotRateAppPressed()
    {
        //TODO: Log the write stuff to the survey
        self.close()
    }
    
    //NegativeFeedbackCompleteViewControllerDelegate
    func doneWithFeedbackPressed()
    {
        self.close()
    }
}
