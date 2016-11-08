//
//  SurveyViewController.swift
//  Pods
//
//  Created by Paul Berry on 9/22/15.
//
//

import Foundation
import UIKit
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

fileprivate func >= <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l >= r
  default:
    return !(lhs < rhs)
  }
}


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
        self.state = .ratingScreen
        super.init(coder: aDecoder)
    }
    
    override init(nibName nibNameOrNil: String!, bundle: Bundle!) {
        self.state = .ratingScreen
        super.init(nibName: nibNameOrNil, bundle: bundle)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //only apply the blur if the user hasn't disabled transparency effects
        if !UIAccessibilityIsReduceTransparencyEnabled() {
            showBlurredWindowImage()
        } else {
            self.view.backgroundColor = .black
        }
        
        Brilliant.sharedInstance().completedSurvey?.triggerTimestamp = Date()
        
        self.npsScoreVC = NPSScoreViewController(nibName: "NPSScoreViewController", bundle: Brilliant.xibBundle())
        self.npsScoreVC?.delegate = self
        self.addFullScreenSubViewController(npsScoreVC!)
    }
    
    lazy var blurredBackgroundImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.addSubview(self.blurVisualEffectView)
        return imageView
    }()
    let blurVisualEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
    
    fileprivate func showBlurredWindowImage() {
        guard let keyWindow = UIApplication.shared.keyWindow else { return }
        
        if let windowImage = getWindowImage() {
            blurredBackgroundImageView.backgroundColor = .red
            view.addSubview(blurredBackgroundImageView)
            blurredBackgroundImageView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
            blurredBackgroundImageView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
            blurredBackgroundImageView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
            blurredBackgroundImageView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
            blurredBackgroundImageView.image = windowImage
            
            blurVisualEffectView.frame = keyWindow.frame
        } else {
            self.view.backgroundColor = .black
        }
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        guard let keyWindow = UIApplication.shared.keyWindow else { return }
        let orientation = UIDevice.current.orientation
        if orientation == .portrait || orientation == .portraitUpsideDown {
            blurVisualEffectView.frame = CGRect(x: 0, y: 0, width: keyWindow.frame.height, height: keyWindow.frame.width)
        } else {
            blurVisualEffectView.frame = CGRect(x: 0, y: 0, width: keyWindow.frame.height, height: keyWindow.frame.height)
        }
    }
    
    fileprivate func getWindowImage() -> UIImage? {
        if let keyWindow = UIApplication.shared.keyWindow {
            UIGraphicsBeginImageContextWithOptions(keyWindow.frame.size, keyWindow.isOpaque, 0)
            keyWindow.layer.render(in: UIGraphicsGetCurrentContext()!)
            let image = UIGraphicsGetImageFromCurrentImageContext()
            return image
        }
        return nil
    }
    
    func addFullScreenSubViewController(_ subViewController: UIViewController)
    {
        self.addChildViewController(subViewController)
        self.view.addSubview(subViewController.view)
        subViewController.view.translatesAutoresizingMaskIntoConstraints = false
        
        let hConstraints = NSLayoutConstraint.constraints(withVisualFormat: "H:|[subViewController]|", options: NSLayoutFormatOptions(), metrics: nil, views: ["subViewController" : subViewController.view])
        let vConstraints = NSLayoutConstraint.constraints(withVisualFormat: "V:|[subViewController]|", options: NSLayoutFormatOptions(), metrics: nil, views: ["subViewController" : subViewController.view])
        self.view.addConstraints(hConstraints)
        self.view.addConstraints(vConstraints)
    }
    
    func viewControllerTransition(_ oldVC: UIViewController?, newVC: UIViewController)
    {
        UIView.animate(withDuration: 0.3, animations: { () -> Void in
            oldVC?.view.alpha = 0
            newVC.view.alpha = 1
            }, completion: { (success) -> Void in
                oldVC?.removeFromParentViewController()
                oldVC?.view.removeFromSuperview()
        }) 
    }
    
    //NPSScoreViewControllerDelegate
    func closePressed(_ state: SurveyViewControllerState)
    {
        switch state
        {
        case .ratingScreen: // rating screen
            Brilliant.sharedInstance().completedSurvey!.dismissAction = "x_npsscreen"
            break
        case .commentScreen: // comment screen
            Brilliant.sharedInstance().completedSurvey!.dismissAction = "x_comments"
            break
        case .feedbackScreen: // feedback screen
            Brilliant.sharedInstance().completedSurvey!.dismissAction = "x_feedback"
            break
        case .rateAppScreen: // rate the app screen
            Brilliant.sharedInstance().completedSurvey!.dismissAction = "x_rateapp"
            break
        }
        
        close()
    }
    
    func close()
    {
        UIView.animate(withDuration: 0.2, delay: 0.0, options: UIViewAnimationOptions.curveEaseIn, animations: {
            
            self.blurEffectView?.alpha = 0
            self.npsScoreVC?.view.alpha = 0
            self.commentsVC?.view.alpha = 0
            self.rateAppVC?.view.alpha = 0
            self.negativeFeedbackVC?.view.alpha = 0
            
            }, completion: {_ in
                UIView.animate(withDuration: 0.3, delay: 0.5, options: UIViewAnimationOptions.curveEaseIn, animations: {
                    self.dismiss(animated: true, completion: nil)
                    
                    }, completion: {_ in
                        // SEND SURVEY DATA
                        Brilliant.sharedInstance().completedSurvey!.completedTimestamp = Date()
                        Brilliant.sharedInstance().sendCompletedSurvey()
                })
        })
    }

    func npsScorePressed(_ npsScore: Int)
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
        if let appStoreId = Brilliant.sharedInstance().appStoreId {
            let url = "itms-apps://itunes.apple.com/app/id\(appStoreId)"
            //        let url = "http://itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?id=\(Brilliant.sharedInstance().appStoreId)&pageNumber=0&sortOrdering=2&type=Purple+Software&mt=8"
            //        let url = "https://itunes.apple.com/us/app/apple-store/id\(Brilliant.sharedInstance().appStoreId)?mt=8"
            UIApplication.shared.openURL(URL(string: url)!)
            
            Brilliant.sharedInstance().completedSurvey!.dismissAction =  "sure_rateapp"
            self.close()
        } else {
        }
        
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
