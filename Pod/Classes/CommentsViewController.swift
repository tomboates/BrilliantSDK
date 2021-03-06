//
//  CommentsViewController.swift
//  Pods
//
//  Created by Phillip Connaughton on 1/24/16.
//
//

import Foundation

protocol CommentsViewControllerDelegate: class{
    
    func closePressed(_ state: SurveyViewControllerState)
    func submitFeedbackPressed()
    func doNotSubmitFeedbackPressed()
}

class CommentsViewController: UIViewController
{
    @IBOutlet var closeButton: UIButton!
    @IBOutlet var comments: UITextView!
    @IBOutlet var noThanksButton: UIButton!
    @IBOutlet var submitButton: UIButton!
    @IBOutlet var commentDescriptionLabel: UILabel!
    @IBOutlet var doneButton: UIBarButtonItem!
    @IBOutlet var keyboardToolbar: UIToolbar!
    @IBOutlet weak var topConstraint: NSLayoutConstraint!
    
    internal weak var delegate : CommentsViewControllerDelegate?
    
    override func viewDidLoad() {
        let image = UIImage(named: "brilliant-icon-close", in:Brilliant.imageBundle(), compatibleWith: nil)
        self.closeButton.setImage(image, for: UIControlState())
        self.closeButton.imageEdgeInsets = UIEdgeInsets(top: 15, left: 15, bottom: 25, right: 25)
        
        self.commentDescriptionLabel.textColor = Brilliant.sharedInstance().mainLabelColor()
        self.commentDescriptionLabel.font = Brilliant.sharedInstance().mainLabelFont()
        
        self.comments.layer.cornerRadius = 4;
        self.comments.inputAccessoryView = self.keyboardToolbar
        
        self.comments.font = Brilliant.sharedInstance().commentBoxFont()
        
        let npsNumber: Int! = Brilliant.sharedInstance().completedSurvey?.npsRating!
        if(npsNumber >= 7)
        {
            self.commentDescriptionLabel.text = Brilliant.sharedInstance().positiveFeedbackText(npsNumber)
        }
        else
        {
            self.commentDescriptionLabel.text = Brilliant.sharedInstance().negativeFeedbackText(npsNumber)
        }
        
        Brilliant.sharedInstance().styleButton(self.submitButton)
        
        self.noThanksButton.tintColor = Brilliant.sharedInstance().noThanksButtonColor()
        self.submitButton.titleLabel?.font = Brilliant.sharedInstance().submitButtonFont()
        self.noThanksButton.titleLabel?.font = Brilliant.sharedInstance().submitButtonFont()
        
        NotificationCenter.default.addObserver(self, selector: #selector(adjustForKeyboard), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(adjustForKeyboard), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    func adjustForKeyboard(_ notification: Notification) {
        var userInfo = (notification as NSNotification).userInfo!
        
        let keyboardScreenEndFrame:CGRect = (userInfo[UIKeyboardFrameBeginUserInfoKey] as! NSValue).cgRectValue
        let keyboardViewEndFrame = view.convert(keyboardScreenEndFrame, to: view.window)
        
        self.view.translatesAutoresizingMaskIntoConstraints = true
        
        let screenHeight = UIScreen.main.bounds.height
        let height = self.comments.frame.height + self.comments.frame.origin.y
        let diffHeight = CGFloat(screenHeight) - height
    
        var moveHeight : CGFloat? = 0
        
        if (diffHeight < keyboardViewEndFrame.height) {
            moveHeight = diffHeight - keyboardViewEndFrame.height
        }
        
        var offset : CGFloat? = 0
        
        if comments.frame.origin.y < abs(moveHeight!) {
            offset = abs(moveHeight!) - comments.frame.origin.y - 5
        }
        
        if notification.name == NSNotification.Name.UIKeyboardWillHide {
            UIView.animate(withDuration: 1.0, animations: {
                self.view.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height)
            })
        } else {
            UIView.animate(withDuration: 1.0, animations: {
                self.view.frame = CGRect(x: 0, y: moveHeight! + offset! - 5, width: self.view.frame.width, height: self.view.frame.height)
            })
        }
    }
    
    func textFieldValue(_ notification: Notification){
        if comments.text.isEmpty {
            UIView.animate(withDuration: 0.3, delay: 0.0, options: UIViewAnimationOptions.curveEaseIn, animations: {
                self.noThanksButton.alpha = 1
                self.submitButton.alpha = 0
                }, completion: nil)
        } else {
            UIView.animate(withDuration: 0.3, delay: 0.0, options: UIViewAnimationOptions.curveEaseIn, animations: {
                self.noThanksButton.alpha = 0
                self.submitButton.alpha = 1
                }, completion: nil)
        }
    }
    
    func textView(_ textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        if(text == "\n") {
            
            if comments.text.isEmpty {
                
                textView.resignFirstResponder()
                
                UIView.animate(withDuration: 0.3, delay: 0.0, options: UIViewAnimationOptions.curveEaseIn, animations: {
                    self.noThanksButton.alpha = 1
                    self.submitButton.alpha = 0
                    }, completion: nil)
                
                return false
                
            } else {
                UIView.animate(withDuration: 0.3, delay: 0.0, options: UIViewAnimationOptions.curveEaseIn, animations: {
                    self.noThanksButton.alpha = 0
                    self.submitButton.alpha = 1
                    }, completion: nil)
            }
            textView.resignFirstResponder()
            return false
        }
        return true
    }
    
    func textFieldDidReturn(_ textField: UITextField!) {
        textField.resignFirstResponder()
        // Execute additional code
    }
    
    
    func keyboardWasShown(_ notification: Notification)
    {
        //Need to calculate keyboard exact size due to Apple suggestions
//        npsView.scrollEnabled = true
//        let info : NSDictionary = notification.userInfo!
//        var keyboardSize : CGRect = ((info[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.CGRectValue())!
//        keyboardSize = comments.convertRect(keyboardSize, toView: nil)
//        let contentInsets : UIEdgeInsets = UIEdgeInsetsMake(0.0, 0.0, keyboardSize.height, 0.0)
//        
//        npsView.contentInset = contentInsets
//        npsView.scrollIndicatorInsets = contentInsets
//        
//        var aRect : CGRect = self.view.frame
//        aRect.size.height -= (keyboardSize.height + 100)
//        var fieldOrigin : CGPoint = comments.frame.origin;
//        fieldOrigin.y -= npsView.contentOffset.y;
//        fieldOrigin = comments.convertPoint(fieldOrigin, toView: self.view.superview)
//        originalOffset = npsView.contentOffset;
//        
//        if (!CGRectContainsPoint(aRect, fieldOrigin))
//        {
//            npsView.scrollRectToVisible(comments.frame, animated: true)
//        }
        
    }
    
    func keyboardWillBeHidden(_ notification: Notification)
    {
        //Once keyboard disappears, restore original positions
//        let info : NSDictionary = notification.userInfo!
//        let keyboardSize = (info[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.CGRectValue().size
//        let contentInsets : UIEdgeInsets = UIEdgeInsetsMake(0.0, 0.0, -keyboardSize!.height, 0.0)
//        npsView.contentInset = contentInsets
//        npsView.scrollIndicatorInsets = contentInsets
//        npsView.setContentOffset(originalOffset, animated: true)
//        self.view.endEditing(true)
//        npsView.scrollEnabled = false
        
    }
    
    @IBAction func submitPressed(_ sender: AnyObject) {
        Brilliant.sharedInstance().completedSurvey!.comment = self.comments.text
        self.delegate?.submitFeedbackPressed()
    }
    
    @IBAction func noThanksPressed(_ sender: AnyObject) {
        self.delegate?.doNotSubmitFeedbackPressed()
    }
    
    @IBAction func closePressed(_ sender: AnyObject) {
        self.delegate?.closePressed(.commentScreen)
    }
    
    @IBAction func keyboardDoneClicked(_ sender: AnyObject) {
        self.comments.resignFirstResponder()
    }
}
