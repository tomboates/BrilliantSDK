//
//  SurveyViewController.swift
//  Pods
//
//  Created by Paul Berry on 9/22/15.
//
//

import Foundation
import UIKit

class SurveyViewController: UIViewController, UITextViewDelegate {
  
  var blurEffect = UIBlurEffect();
  var blurEffectView = UIVisualEffectView();
  var npsView = UIScrollView();
  
  var originalOffset = CGPoint();
  
  var npsNumbersView = UIView();
  var npsCommentsView = UIView();
  var npsThanksView = UIView();
  var npsRatingView = UIView();
  var npsButtonView = UIView();
  var npsCommentsButtonView = UIView();
  var npsNumber = Int()
  
  let npsLabel: UILabel = UILabel()
  var closeImage: UIImage!
  let closeButton   = UIButton(type: UIButtonType.System);
  
  let submitNPS = UIButton(type: UIButtonType.System);
  let valueLabel: UILabel = UILabel()
  let npsValue: UILabel = UILabel()
  
  var comments: UITextView = UITextView()
  let noThanks = UIButton(type: UIButtonType.System);
  let submitComments = UIButton(type: UIButtonType.System);
  
  let npsDone = UIButton(type: UIButtonType.System);
  
  var commentsImage: UIImage!
  var ratingsImage: UIImage!
  
  var commentBubble = UIImageView()
  var ratingStar = UIButton(type: UIButtonType.System);
  
  var npsButton = UIButton(type: UIButtonType.System);
  
  var npsButtonsDictionary = Dictionary<String, AnyObject>()
  
  let npsReview = UIButton(type: UIButtonType.System);
  
  let shadowColor = UIColor(red: 0.211, green: 0.660, blue: 0.324, alpha: 1)
  
  var state: Int! // keep track of what screen is showing for analytics
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.state = 0
    let bundleURL = NSBundle(forClass: Brilliant.self).URLForResource("Brilliant", withExtension: "bundle")
    let bundle = NSBundle(URL: bundleURL!)
    closeImage = UIImage(named: "brilliant-icon-close", inBundle: bundle, compatibleWithTraitCollection: nil)
    commentsImage = UIImage(named: "commentBubble", inBundle: bundle, compatibleWithTraitCollection: nil)
    ratingsImage = UIImage(named: "ratingStars", inBundle: bundle, compatibleWithTraitCollection: nil)
    
    Brilliant.sharedInstance.completedSurvey!["triggerTimestamp"] = String(NSDate().timeIntervalSince1970)
    
    comments.delegate = self
    
    NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWasShown:"), name:UIKeyboardWillShowNotification, object: nil);
    NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillBeHidden:"), name:UIKeyboardWillHideNotification, object: nil);
    
    //only apply the blur if the user hasn't disabled transparency effects
    if !UIAccessibilityIsReduceTransparencyEnabled() {
      self.view.backgroundColor = UIColor.clearColor()
      
      blurEffect = UIBlurEffect(style: UIBlurEffectStyle.Dark);
      blurEffectView = UIVisualEffectView(effect: blurEffect);
      
      blurEffectView.frame = CGRectMake(0, 0, 2732, 2732)
      blurEffectView.alpha = 0
      
      self.view.addSubview(blurEffectView)
      
      self.view.addSubview(npsView)
      
      UIView.animateWithDuration(0.3, delay: 0.0, options: UIViewAnimationOptions.CurveEaseIn, animations: {
        self.blurEffectView.alpha = 1
        self.npsView.alpha = 1
        }, completion: nil)
      
      self.npsView.addSubview(npsNumbersView)
      npsNumbersView.alpha = 1
      
      closeButton.frame = CGRectMake(13, 27, 20, 20)
      closeButton.setImage(closeImage, forState: .Normal)
      closeButton.tintColor = UIColor.whiteColor()
      closeButton.addTarget(self, action: "closeBlurView:", forControlEvents:.TouchUpInside)
      self.npsView.addSubview(closeButton)
      
      npsLabel.textColor = UIColor.whiteColor()
      npsLabel.textAlignment = NSTextAlignment.Center
      npsLabel.numberOfLines = 0
      if UIDevice.currentDevice().userInterfaceIdiom == .Pad {
        npsLabel.font = UIFont(name: npsLabel.font.fontName, size: 34)
      }
      if UIDevice.currentDevice().userInterfaceIdiom == .Phone {
        npsLabel.font = UIFont(name: npsLabel.font.fontName, size: 23)
      }
      var appName = "this app"
      if (Brilliant.sharedInstance.appName != nil) {
        appName = Brilliant.sharedInstance.appName!
      }
      
      npsLabel.text = "How likely are you to recommend \(appName) to a friend or colleague?"
      self.npsNumbersView.addSubview(npsLabel)
      
      self.npsNumbersView.addSubview(npsButtonView)
      npsButtonView.alpha = 1
      
      for var i = 0; i < 11; i++ {
        
        npsButton = UIButton(type: UIButtonType.System);
        npsButton.alpha = 1
        npsButton.tag = i
        let tagNumber = String(i)
        let x = CGFloat(i * 28)
        npsButton.frame = CGRectMake(x, 150, 28, 28)
        npsButton.contentHorizontalAlignment = UIControlContentHorizontalAlignment.Center
        npsButton.tintColor = UIColor(red: 0.313, green: 0.854, blue: 0.451, alpha: 1)
        if UIDevice.currentDevice().userInterfaceIdiom == .Pad {
          npsButton.titleLabel!.font =  UIFont(name: npsLabel.font.fontName, size: 40)
        }
        if UIDevice.currentDevice().userInterfaceIdiom == .Phone {
          if (view.frame.width <= 500) {
            let fontSize = (view.frame.width / 320) * 21
            npsButton.titleLabel!.font =  UIFont(name: npsLabel.font.fontName, size: fontSize)
          } else {
            npsButton.titleLabel!.font =  UIFont(name: npsLabel.font.fontName, size: 28)
          }
        }
        npsButton.setTitle(tagNumber, forState: UIControlState.Normal)
        npsButton.addTarget(self, action: "submitNPS:", forControlEvents:.TouchUpInside)
        self.npsButtonView.addSubview(npsButton)
        
        npsButton.translatesAutoresizingMaskIntoConstraints = false
        
        npsButtonsDictionary["npsButton" + String(i)] = npsButton
        
      }
      
      NSNotificationCenter.defaultCenter().addObserver(
        self,
        selector: "textFieldValue:",
        name: UITextViewTextDidEndEditingNotification,
        object: nil)
      
    }
    else {
      self.view.backgroundColor = UIColor.blackColor()
    }
    
    let npsViewDictionary: [String: AnyObject] = [
      "topLayoutGuide":       topLayoutGuide,
      "bottomLayoutGuide":    bottomLayoutGuide,
      "blurEffectView":       blurEffectView,
      "closeButton":          closeButton,
      "npsView":              npsView,
      "npsNumbersView":       npsNumbersView,
      "npsLabel":             npsLabel,
      "npsButtonView":        npsButtonView
    ]
    
    view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[blurEffectView]|", options: [], metrics: nil, views: npsViewDictionary))
    view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[blurEffectView]|", options: [], metrics: nil, views: npsViewDictionary))
    view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[topLayoutGuide][npsView]|", options: [], metrics: nil, views: npsViewDictionary))
    view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[npsView]|", options: [], metrics: nil, views: npsViewDictionary))
    
    closeButton.translatesAutoresizingMaskIntoConstraints = false
    npsView.translatesAutoresizingMaskIntoConstraints = false
    npsNumbersView.translatesAutoresizingMaskIntoConstraints = false
    npsLabel.translatesAutoresizingMaskIntoConstraints = false
    npsButtonView.translatesAutoresizingMaskIntoConstraints = false
    
    if UIDevice.currentDevice().userInterfaceIdiom == .Pad {
      
      npsView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-(==15)-[closeButton(==20)]-[npsNumbersView(==600)]", options: [], metrics: nil, views: npsViewDictionary))
      npsView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-(==15)-[closeButton(==20)]", options: [], metrics: nil, views: npsViewDictionary))
      npsView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:[npsNumbersView(==600)]", options: [], metrics: nil, views: npsViewDictionary))
      
      npsNumbersView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[npsLabel(==240)]-[npsButtonView(==70)]", options: [], metrics: nil, views: npsViewDictionary))
      
      npsNumbersView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-50-[npsLabel(==500)]-50-|", options: [], metrics: nil, views: npsViewDictionary))
      npsNumbersView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[npsButtonView]|", options: [], metrics: nil, views: npsViewDictionary))
      
    }
    
    if UIDevice.currentDevice().userInterfaceIdiom == .Phone {
      
      npsView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-15-[closeButton(==20)]-(==40)-[npsNumbersView]|", options: [], metrics: nil, views: npsViewDictionary))
      npsView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-15-[closeButton(==20)]", options: [], metrics: nil, views: npsViewDictionary))
      npsView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[npsNumbersView]|", options: [], metrics: nil, views: npsViewDictionary))
      
      npsNumbersView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-[npsLabel(<=160,>=60)]-20-[npsButtonView(==40)]", options: [], metrics: nil, views: npsViewDictionary))
      
      npsNumbersView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-20-[npsLabel]-20-|", options: [], metrics: nil, views: npsViewDictionary))
      npsNumbersView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-(>=10)-[npsButtonView(<=600)]-(>=10)-|", options: [], metrics: nil, views: npsViewDictionary))
      
    }
    
    let npsNumbersViewCenter = NSLayoutConstraint(item: self.npsNumbersView,
      attribute: NSLayoutAttribute.CenterX,
      relatedBy: NSLayoutRelation.Equal,
      toItem: self.npsView,
      attribute: NSLayoutAttribute.CenterX,
      multiplier: 1,
      constant: 0)
    self.npsView.addConstraint(npsNumbersViewCenter)
    
    let npsNumbersViewMiddle = NSLayoutConstraint(item: self.npsNumbersView,
      attribute: NSLayoutAttribute.CenterY,
      relatedBy: NSLayoutRelation.Equal,
      toItem: self.npsView,
      attribute: NSLayoutAttribute.CenterY,
      multiplier: 1,
      constant: 0)
    self.npsView.addConstraint(npsNumbersViewMiddle)
    
    let npsLabelCenter = NSLayoutConstraint(item: self.npsLabel,
      attribute: NSLayoutAttribute.CenterX,
      relatedBy: NSLayoutRelation.Equal,
      toItem: self.npsNumbersView,
      attribute: NSLayoutAttribute.CenterX,
      multiplier: 1,
      constant: 0)
    self.npsNumbersView.addConstraint(npsLabelCenter)
    
    let npsButtonViewCenter = NSLayoutConstraint(item: self.npsButtonView,
      attribute: NSLayoutAttribute.CenterX,
      relatedBy: NSLayoutRelation.Equal,
      toItem: self.npsNumbersView,
      attribute: NSLayoutAttribute.CenterX,
      multiplier: 1,
      constant: 0)
    self.npsNumbersView.addConstraint(npsButtonViewCenter)
    
    npsButtonView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[npsButton0(>=27,<=70)]|", options: [], metrics: nil, views: npsButtonsDictionary))
    npsButtonView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[npsButton1(npsButton0)]|", options: [], metrics: nil, views: npsButtonsDictionary))
    npsButtonView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[npsButton2(npsButton0)]|", options: [], metrics: nil, views: npsButtonsDictionary))
    npsButtonView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[npsButton3(npsButton0)]|", options: [], metrics: nil, views: npsButtonsDictionary))
    npsButtonView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[npsButton4(npsButton0)]|", options: [], metrics: nil, views: npsButtonsDictionary))
    npsButtonView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[npsButton5(npsButton0)]|", options: [], metrics: nil, views: npsButtonsDictionary))
    npsButtonView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[npsButton6(npsButton0)]|", options: [], metrics: nil, views: npsButtonsDictionary))
    npsButtonView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[npsButton7(npsButton0)]|", options: [], metrics: nil, views: npsButtonsDictionary))
    npsButtonView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[npsButton8(npsButton0)]|", options: [], metrics: nil, views: npsButtonsDictionary))
    npsButtonView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[npsButton9(npsButton0)]|", options: [], metrics: nil, views: npsButtonsDictionary))
    npsButtonView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[npsButton10(npsButton0)]|", options: [], metrics: nil, views: npsButtonsDictionary))
    
    npsButtonView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[npsButton0(>=27@20,<=70@40)][npsButton1(npsButton0)][npsButton2(npsButton0)][npsButton3(npsButton0)][npsButton4(npsButton0)][npsButton5(npsButton0)][npsButton6(npsButton0)][npsButton7(npsButton0)][npsButton8(npsButton0)][npsButton9(npsButton0)][npsButton10(npsButton0)]|", options: [], metrics: nil, views: npsButtonsDictionary))
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  func closeBlurView(sender: UIButton!) {
    // determine dismissAction NOTE: this would be much easier if each view was in it's own viewcontroller
    var dismissAction: String!
    switch (self.state) {
    case (0): // rating screen
      dismissAction = "x_npsscreen"
    case (1): // comment screen
      if (sender == self.closeButton) {
        dismissAction = "x_comments"
      }else {
        dismissAction = "nothanks_comments"
      }
    case (2): // feedback screen
      if (sender == self.closeButton) {
        dismissAction = "x_feedback"
      } else {
        dismissAction = "done_feedback"
      }
    case (3): // rate the app screen
      if (sender == self.closeButton) {
      dismissAction = "x_rateapp"
      } else if (sender == self.npsReview) {
        dismissAction = "sure_rateapp"
      } else {
      dismissAction = "nothanks_rateapp"
      }
    default:
      dismissAction = "other_action"
    }
    Brilliant.sharedInstance.completedSurvey!["dismissAction"] = dismissAction
    
    comments.text = nil
    
    UIView.animateWithDuration(0.2, delay: 0.0, options: UIViewAnimationOptions.CurveEaseIn, animations: {
      
      self.blurEffectView.alpha = 0
      self.npsView.alpha = 0
      
      }, completion: {_ in
        UIView.animateWithDuration(0.3, delay: 0.5, options: UIViewAnimationOptions.CurveEaseIn, animations: {
          
          self.npsNumbersView.removeFromSuperview()
          self.npsCommentsView.removeFromSuperview()
          self.npsThanksView.removeFromSuperview()
          self.npsRatingView.removeFromSuperview()
          self.npsButtonView.removeFromSuperview()
          self.npsView.removeFromSuperview()
          self.dismissViewControllerAnimated(true, completion: nil)
          
          }, completion: {_ in
            // SEND SURVEY DATA
            Brilliant.sharedInstance.completedSurvey!["completedTimestamp"] = String(NSDate().timeIntervalSince1970)
            Brilliant.sharedInstance.sendCompletedSurvey()
        })
    })
    
  }
  
  func submitNPS(sender: UIButton!) {
    
    npsNumber = sender.tag
    Brilliant.sharedInstance.completedSurvey!["npsRating"] = String(npsNumber)
    
    UIView.animateWithDuration(0.2, delay: 0.0, options: UIViewAnimationOptions.CurveEaseIn, animations: {
      self.npsNumbersView.alpha = 0
      
      }, completion: {(finished:Bool) in
        self.state = 1
        self.npsView.addSubview(self.npsCommentsView)
        self.npsCommentsView.alpha = 0
        
        self.npsCommentsView.addSubview(self.npsLabel)
        
        self.npsCommentsView.addSubview(self.npsCommentsButtonView)
        self.npsCommentsButtonView.alpha = 1
        
        self.comments.font = UIFont.systemFontOfSize(16)
        self.comments.textAlignment = NSTextAlignment.Left
        self.comments.layer.cornerRadius = 4
        self.comments.returnKeyType = .Done
        
        self.npsCommentsView.addSubview(self.comments)
        
        self.noThanks.alpha = 1
        self.noThanks.setTitle("No Thanks", forState: UIControlState.Normal)
        self.noThanks.tintColor = UIColor(red: 0.313, green: 0.854, blue: 0.451, alpha: 1)
        self.noThanks.addTarget(self, action: "closeBlurView:", forControlEvents:.TouchUpInside)
        if UIDevice.currentDevice().userInterfaceIdiom == .Pad {
          self.noThanks.titleLabel!.font =  UIFont(name: self.npsLabel.font.fontName, size: 26)
        }
        if UIDevice.currentDevice().userInterfaceIdiom == .Phone {
          self.noThanks.titleLabel!.font =  UIFont(name: self.npsLabel.font.fontName, size: 18)
        }
        self.npsCommentsButtonView.addSubview(self.noThanks)
        
        self.submitComments.alpha = 0
        self.submitComments.layer.cornerRadius = 4
        self.submitComments.tintColor = UIColor.whiteColor()
        self.submitComments.layer.shadowColor = self.shadowColor.CGColor
        self.submitComments.layer.shadowOffset = CGSizeMake(0, 2)
        self.submitComments.layer.shadowRadius = 0
        self.submitComments.layer.shadowOpacity = 1.0
        self.submitComments.backgroundColor = UIColor(red: 0.313, green: 0.854, blue: 0.451, alpha: 1)
        if UIDevice.currentDevice().userInterfaceIdiom == .Pad {
          self.submitComments.titleLabel!.font =  UIFont(name: self.npsLabel.font.fontName, size: 26)
        }
        if UIDevice.currentDevice().userInterfaceIdiom == .Phone {
          self.submitComments.titleLabel!.font =  UIFont(name: self.npsLabel.font.fontName, size: 18)
        }
        self.submitComments.setTitle("Submit", forState: UIControlState.Normal)
        self.submitComments.addTarget(self, action: "submitComments:", forControlEvents:.TouchUpInside)
        self.npsCommentsButtonView.addSubview(self.submitComments)
        
        self.npsCommentsView.translatesAutoresizingMaskIntoConstraints = false
        self.comments.translatesAutoresizingMaskIntoConstraints = false
        self.npsCommentsButtonView.translatesAutoresizingMaskIntoConstraints = false
        self.noThanks.translatesAutoresizingMaskIntoConstraints = false
        self.submitComments.translatesAutoresizingMaskIntoConstraints = false
        
        let npsCommentsViewDictionary = ["closeButton": self.closeButton, "npsCommentsView": self.npsCommentsView, "npsCommentsButtonView": self.npsCommentsButtonView, "npsLabel": self.npsLabel, "comments": self.comments, "noThanks": self.noThanks, "submitComments": self.submitComments]
        
        if UIDevice.currentDevice().userInterfaceIdiom == .Pad {
          
          self.npsView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:[npsCommentsView(==600)]", options: [], metrics: nil, views: npsCommentsViewDictionary))
          self.npsView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:[npsCommentsView(==600)]", options: [], metrics: nil, views: npsCommentsViewDictionary))
          
          self.npsCommentsView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[npsLabel(==200)]-[comments(==150)]-20@999-[npsCommentsButtonView(==70)]-20@998-|", options: [], metrics: nil, views: npsCommentsViewDictionary))
          
          self.npsCommentsView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-50-[npsLabel(==500)]-50-|", options: [], metrics: nil, views: npsCommentsViewDictionary))
          self.npsCommentsView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-80-[comments(==440)]-80-|", options: [], metrics: nil, views: npsCommentsViewDictionary))
          self.npsCommentsView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-80-[npsCommentsButtonView(==440)]-80-|", options: [], metrics: nil, views: npsCommentsViewDictionary))
          
        }
        
        let npsCommentsViewCenter = NSLayoutConstraint(item: self.npsCommentsView,
          attribute: NSLayoutAttribute.CenterX,
          relatedBy: NSLayoutRelation.Equal,
          toItem: self.npsView,
          attribute: NSLayoutAttribute.CenterX,
          multiplier: 1,
          constant: 0)
        self.npsView.addConstraint(npsCommentsViewCenter)
        
        let npsCommentsViewMiddle = NSLayoutConstraint(item: self.npsCommentsView,
          attribute: NSLayoutAttribute.CenterY,
          relatedBy: NSLayoutRelation.Equal,
          toItem: self.npsView,
          attribute: NSLayoutAttribute.CenterY,
          multiplier: 1,
          constant: 0)
        self.npsView.addConstraint(npsCommentsViewMiddle)
        
        if UIDevice.currentDevice().userInterfaceIdiom == .Phone {
          
          self.npsView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-(==40)-[npsCommentsView]|", options: [], metrics: nil, views: npsCommentsViewDictionary))
          self.npsView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[npsCommentsView]|", options: [], metrics: nil, views: npsCommentsViewDictionary))
          
          self.npsCommentsView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[npsLabel(<=160,>=60)]-[comments(<=160,>=60)]-20@999-[npsCommentsButtonView(==50)]-20-|", options: [], metrics: nil, views: npsCommentsViewDictionary))
          
          self.npsCommentsView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-20-[npsLabel]-20-|", options: [], metrics: nil, views: npsCommentsViewDictionary))
          self.npsCommentsView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-20-[comments]-20-|", options: [], metrics: nil, views: npsCommentsViewDictionary))
          self.npsCommentsView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-20-[npsCommentsButtonView]-20-|", options: [], metrics: nil, views: npsCommentsViewDictionary))
          
        }
        
        self.npsCommentsButtonView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[noThanks]|", options: [], metrics: nil, views: npsCommentsViewDictionary))
        self.npsCommentsButtonView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[noThanks]|", options: [], metrics: nil, views: npsCommentsViewDictionary))
        
        self.npsCommentsButtonView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[submitComments]|", options: [], metrics: nil, views: npsCommentsViewDictionary))
        self.npsCommentsButtonView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[submitComments]|", options: [], metrics: nil, views: npsCommentsViewDictionary))
        
        UIView.animateWithDuration(0.2, delay: 0.0, options: UIViewAnimationOptions.CurveEaseIn, animations: {
          
          self.npsCommentsView.alpha = 1
          
          if self.npsNumber == 9 || self.npsNumber == 10{
            
            self.npsLabel.text = "Great! Can you tell us why you chose a \(self.npsNumber)?"
            
          } else if self.npsNumber == 7 || self.npsNumber == 8 {
            
            self.npsLabel.text = "Thanks! Can you tell us why you chose a \(self.npsNumber)?"
            
          } else {
            
            self.npsLabel.text = "Bummer! Can you tell us why you chose a \(self.npsNumber)?"
            
          }
          
          }, completion: nil)
    })
    
  }
  
  
  func submitComments(sender: UIButton!) {
    Brilliant.sharedInstance.completedSurvey!["comments"] = self.comments.text
    
    if self.npsNumber == 9 || self.npsNumber == 10 {
      
      UIView.animateWithDuration(0.3, delay: 0.0, options: UIViewAnimationOptions.CurveEaseIn, animations: {
        
        self.npsCommentsView.alpha = 0
        
        }, completion: {(finished:Bool) in
          self.state = 3
          self.npsView.addSubview(self.npsRatingView)
          self.npsRatingView.alpha = 0
          
          self.npsRatingView.addSubview(self.npsLabel)
          
          self.npsLabel.text = "Thanks! We would love it if you could rate us in the app store."
          
          self.npsReview.layer.cornerRadius = 4
          self.npsReview.tintColor = UIColor.whiteColor()
          self.npsReview.layer.shadowColor = self.shadowColor.CGColor
          self.npsReview.layer.shadowOffset = CGSizeMake(0, 2)
          self.npsReview.layer.shadowRadius = 0
          self.npsReview.layer.shadowOpacity = 1.0
          self.npsReview.backgroundColor = UIColor(red: 0.313, green: 0.854, blue: 0.451, alpha: 1)
          if UIDevice.currentDevice().userInterfaceIdiom == .Pad {
            self.npsReview.titleLabel!.font =  UIFont(name: self.npsLabel.font.fontName, size: 26)
          }
          if UIDevice.currentDevice().userInterfaceIdiom == .Phone {
            self.npsReview.titleLabel!.font =  UIFont(name: self.npsLabel.font.fontName, size: 18)
          }
          self.npsReview.setTitle("Sure", forState: UIControlState.Normal)
          self.npsReview.addTarget(self, action: "npsReview:", forControlEvents:.TouchUpInside)
          self.npsRatingView.addSubview(self.npsReview)
          
          self.ratingStar.setImage(self.ratingsImage, forState: .Normal)
          self.ratingStar.contentMode = .ScaleAspectFill
          self.ratingStar.tintColor = UIColor.whiteColor()
          self.ratingStar.addTarget(self, action: "npsReview:", forControlEvents:.TouchUpInside)
          
          self.noThanks.alpha = 1
          
          self.npsRatingView.addSubview(self.noThanks)
          self.npsRatingView.addSubview(self.ratingStar)
          
          self.npsRatingView.translatesAutoresizingMaskIntoConstraints = false
          self.ratingStar.translatesAutoresizingMaskIntoConstraints = false
          self.npsReview.translatesAutoresizingMaskIntoConstraints = false
          
          let npsRatingViewDictionary = ["closeButton": self.closeButton, "npsRatingView": self.npsRatingView, "npsReview": self.npsReview, "npsLabel": self.npsLabel, "ratingStar": self.ratingStar, "noThanks": self.noThanks]
          
          if UIDevice.currentDevice().userInterfaceIdiom == .Pad {
            
            self.npsView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:[npsRatingView(==600)]", options: [], metrics: nil, views: npsRatingViewDictionary))
            self.npsView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:[npsRatingView(==600)]", options: [], metrics: nil, views: npsRatingViewDictionary))
            
            self.npsRatingView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-(==50)-[ratingStar(==60)]-20-[npsLabel(==240)]-70-[npsReview(==70)]-20-[noThanks(==70)]-20-|", options: [], metrics: nil, views: npsRatingViewDictionary))
            
            self.npsRatingView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-95-[ratingStar(==410)]-95-|", options: [], metrics: nil, views: npsRatingViewDictionary))
            self.npsRatingView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-20-[npsLabel]-20-|", options: [], metrics: nil, views: npsRatingViewDictionary))
            self.npsRatingView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-80-[npsReview(==440)]-80-|", options: [], metrics: nil, views: npsRatingViewDictionary))
            self.npsRatingView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-80-[noThanks(==440)]-80-|", options: [], metrics: nil, views: npsRatingViewDictionary))
            
          }
          
          let npsRatingViewCenter = NSLayoutConstraint(item: self.npsRatingView,
            attribute: NSLayoutAttribute.CenterX,
            relatedBy: NSLayoutRelation.Equal,
            toItem: self.npsView,
            attribute: NSLayoutAttribute.CenterX,
            multiplier: 1,
            constant: 0)
          self.npsView.addConstraint(npsRatingViewCenter)
          
          let npsRatingViewMiddle = NSLayoutConstraint(item: self.npsRatingView,
            attribute: NSLayoutAttribute.CenterY,
            relatedBy: NSLayoutRelation.Equal,
            toItem: self.npsView,
            attribute: NSLayoutAttribute.CenterY,
            multiplier: 1,
            constant: 0)
          self.npsView.addConstraint(npsRatingViewMiddle)
          
          if UIDevice.currentDevice().userInterfaceIdiom == .Phone {
            
            self.npsView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-(==40)-[npsRatingView]|", options: [], metrics: nil, views: npsRatingViewDictionary))
            self.npsView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[npsRatingView]|", options: [], metrics: nil, views: npsRatingViewDictionary))
            
            self.npsRatingView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-20-[ratingStar(==36)]-(<=20)-[npsLabel(<=160,>=60)]-10@900-[npsReview(==50)]-(<=20@999)-[noThanks(==50)]-20-|", options: [], metrics: nil, views: npsRatingViewDictionary))
            
            self.npsRatingView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[ratingStar]|", options: [], metrics: nil, views: npsRatingViewDictionary))
            self.npsRatingView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-20-[npsLabel]-20-|", options: [], metrics: nil, views: npsRatingViewDictionary))
            self.npsRatingView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-20-[npsReview]-20-|", options: [], metrics: nil, views: npsRatingViewDictionary))
            self.npsRatingView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-20-[noThanks]-20-|", options: [], metrics: nil, views: npsRatingViewDictionary))
            
          }
          
          UIView.animateWithDuration(0.2, delay: 0.0, options: UIViewAnimationOptions.CurveEaseIn, animations: {
            
            self.npsRatingView.alpha = 1
            
            }, completion: nil)
      })
      
    } else {
      
      UIView.animateWithDuration(0.3, delay: 0.0, options: UIViewAnimationOptions.CurveEaseIn, animations: {
        
        self.npsCommentsView.alpha = 0
        
        }, completion: {(finished:Bool) in
          self.state = 2
          self.commentBubble = UIImageView(image: self.commentsImage)
          
          self.npsView.addSubview(self.npsThanksView)
          self.npsThanksView.alpha = 0
          
          self.npsThanksView.addSubview(self.npsLabel)
          
          self.npsDone.layer.cornerRadius = 4
          self.npsDone.tintColor = UIColor.whiteColor()
          self.npsDone.layer.shadowColor = self.shadowColor.CGColor
          self.npsDone.layer.shadowOffset = CGSizeMake(0, 2)
          self.npsDone.layer.shadowRadius = 0
          self.npsDone.layer.shadowOpacity = 1.0
          self.npsDone.backgroundColor = UIColor(red: 0.313, green: 0.854, blue: 0.451, alpha: 1)
          self.npsDone.titleLabel!.font =  UIFont.boldSystemFontOfSize(22)
          self.npsDone.setTitle("Done", forState: UIControlState.Normal)
          self.npsDone.addTarget(self, action: "closeBlurView:", forControlEvents:.TouchUpInside)
          self.npsThanksView.addSubview(self.npsDone)
          
          self.npsThanksView.addSubview(self.commentBubble)
          
          self.npsThanksView.translatesAutoresizingMaskIntoConstraints = false
          self.commentBubble.translatesAutoresizingMaskIntoConstraints = false
          self.npsDone.translatesAutoresizingMaskIntoConstraints = false
          
          let npsThanksDictionary = ["closeButton": self.closeButton, "npsThanksView": self.npsThanksView, "npsDone": self.npsDone, "commentBubble": self.commentBubble, "npsLabel": self.npsLabel]
          
          if UIDevice.currentDevice().userInterfaceIdiom == .Pad {
            
            self.npsView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:[npsThanksView(==600)]", options: [], metrics: nil, views: npsThanksDictionary))
            self.npsView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:[npsThanksView(==600)]", options: [], metrics: nil, views: npsThanksDictionary))
            
            self.npsThanksView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-30-[commentBubble(==89)]-20-[npsLabel(==240)]-131-[npsDone(==70)]-20-|", options: [], metrics: nil, views: npsThanksDictionary))
            
            self.npsThanksView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-252-[commentBubble(==96)]-252-|", options: [], metrics: nil, views: npsThanksDictionary))
            self.npsThanksView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-20-[npsLabel]-20-|", options: [], metrics: nil, views: npsThanksDictionary))
            self.npsThanksView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-80-[npsDone(==440)]-80-|", options: [], metrics: nil, views: npsThanksDictionary))
            
          }
          
          let npsThanksViewCenter = NSLayoutConstraint(item: self.npsThanksView,
            attribute: NSLayoutAttribute.CenterX,
            relatedBy: NSLayoutRelation.Equal,
            toItem: self.npsView,
            attribute: NSLayoutAttribute.CenterX,
            multiplier: 1,
            constant: 0)
          self.npsView.addConstraint(npsThanksViewCenter)
          
          let npsThanksViewMiddle = NSLayoutConstraint(item: self.npsThanksView,
            attribute: NSLayoutAttribute.CenterY,
            relatedBy: NSLayoutRelation.Equal,
            toItem: self.npsView,
            attribute: NSLayoutAttribute.CenterY,
            multiplier: 1,
            constant: 0)
          self.npsView.addConstraint(npsThanksViewMiddle)
          
          let npsCommentsBubbleCenter = NSLayoutConstraint(item: self.commentBubble,
            attribute: NSLayoutAttribute.CenterX,
            relatedBy: NSLayoutRelation.Equal,
            toItem: self.npsThanksView,
            attribute: NSLayoutAttribute.CenterX,
            multiplier: 1,
            constant: 0)
          self.npsThanksView.addConstraint(npsCommentsBubbleCenter)
          
          if UIDevice.currentDevice().userInterfaceIdiom == .Phone {
            
            self.npsView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-(==40)-[npsThanksView]|", options: [], metrics: nil, views: npsThanksDictionary))
            self.npsView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[npsThanksView]|", options: [], metrics: nil, views: npsThanksDictionary))
            
            self.npsThanksView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-20-[commentBubble(<=89)]-20-[npsLabel(<=160,>=60)]-10@900-[npsDone(==50)]-20-|", options: [], metrics: nil, views: npsThanksDictionary))
            
            self.npsThanksView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:[commentBubble(==96)]", options: [], metrics: nil, views: npsThanksDictionary))
            self.npsThanksView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-20-[npsLabel]-20-|", options: [], metrics: nil, views: npsThanksDictionary))
            self.npsThanksView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-20-[npsDone]-20-|", options: [], metrics: nil, views: npsThanksDictionary))
            
          }
          
          UIView.animateWithDuration(0.2, delay: 0.0, options: UIViewAnimationOptions.CurveEaseIn, animations: {
            
            self.npsThanksView.alpha = 1
            
            if self.npsNumber == 7 || self.npsNumber == 8 {
              
              self.npsLabel.text = "Thanks so much! We really appreciate your feedback."
              
            } else {
              
              self.npsLabel.text = "Thanks for your feedback! We will reach out about your experience soon."
              
            }
            
            }, completion: nil)
      })
      
    }
    
  }
  
  func npsReview(sender: UIButton!) {
    
    UIApplication.sharedApplication().openURL(NSURL(string: "itms://itunes.apple.com/us/app/apple-store/id300235330?mt=8")!)
    
   self.closeBlurView(self.npsReview)
    
  }
  
  func textFieldValue(notification: NSNotification){
    if comments.text.isEmpty {
      UIView.animateWithDuration(0.3, delay: 0.0, options: UIViewAnimationOptions.CurveEaseIn, animations: {
        self.noThanks.alpha = 1
        self.submitComments.alpha = 0
        }, completion: nil)
    } else {
      UIView.animateWithDuration(0.3, delay: 0.0, options: UIViewAnimationOptions.CurveEaseIn, animations: {
        self.noThanks.alpha = 0
        self.submitComments.alpha = 1
        }, completion: nil)
    }
  }
  
  func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
    if(text == "\n") {
      
      if comments.text.isEmpty {
        
        textView.resignFirstResponder()
        
        UIView.animateWithDuration(0.3, delay: 0.0, options: UIViewAnimationOptions.CurveEaseIn, animations: {
          self.noThanks.alpha = 1
          self.submitComments.alpha = 0
          }, completion: nil)
        
        return false
        
      } else {
        UIView.animateWithDuration(0.3, delay: 0.0, options: UIViewAnimationOptions.CurveEaseIn, animations: {
          self.noThanks.alpha = 0
          self.submitComments.alpha = 1
          }, completion: nil)
      }
      textView.resignFirstResponder()
      return false
    }
    return true
  }
  
  func textFieldDidReturn(textField: UITextField!) {
    textField.resignFirstResponder()
    // Execute additional code
  }
  
  override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
    
    self.view.endEditing(true)
    
  }
  
  func keyboardWasShown(notification: NSNotification)
  {
    //Need to calculate keyboard exact size due to Apple suggestions
    npsView.scrollEnabled = true
    let info : NSDictionary = notification.userInfo!
    var keyboardSize : CGRect = ((info[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.CGRectValue())!
    keyboardSize = comments.convertRect(keyboardSize, toView: nil)
    let contentInsets : UIEdgeInsets = UIEdgeInsetsMake(0.0, 0.0, keyboardSize.height, 0.0)
    
    npsView.contentInset = contentInsets
    npsView.scrollIndicatorInsets = contentInsets
    
    var aRect : CGRect = self.view.frame
    aRect.size.height -= (keyboardSize.height + 100)
    var fieldOrigin : CGPoint = comments.frame.origin;
    fieldOrigin.y -= npsView.contentOffset.y;
    fieldOrigin = comments.convertPoint(fieldOrigin, toView: self.view.superview)
    originalOffset = npsView.contentOffset;
    
    if (!CGRectContainsPoint(aRect, fieldOrigin))
    {
      npsView.scrollRectToVisible(comments.frame, animated: true)
    }
    
  }
  
  func keyboardWillBeHidden(notification: NSNotification)
  {
    //Once keyboard disappears, restore original positions
    let info : NSDictionary = notification.userInfo!
    let keyboardSize = (info[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.CGRectValue().size
    let contentInsets : UIEdgeInsets = UIEdgeInsetsMake(0.0, 0.0, -keyboardSize!.height, 0.0)
    npsView.contentInset = contentInsets
    npsView.scrollIndicatorInsets = contentInsets
    npsView.setContentOffset(originalOffset, animated: true)
    self.view.endEditing(true)
    npsView.scrollEnabled = false
    
  }
  
}
