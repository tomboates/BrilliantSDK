//
//  NegativeFeedbackCompleteViewController.swift
//  Pods
//
//  Created by Phillip Connaughton on 1/24/16.
//
//

import Foundation

protocol NegativeFeedbackCompleteViewControllerDelegate: class{
    
    func closePressed(_ state: SurveyViewControllerState)
    func doneWithFeedbackPressed()
    func autoDismissFeedbackComplete()
}

class NegativeFeedbackCompleteViewController: UIViewController
{
    @IBOutlet var closeButton: UIButton!
    @IBOutlet var explanationLabel: UILabel!
    @IBOutlet var doneButton: UIButton!
    
    internal weak var delegate : NegativeFeedbackCompleteViewControllerDelegate?
    
    override func viewDidLoad() {
        
        let image = UIImage(named: "brilliant-icon-close", in:Brilliant.imageBundle(), compatibleWith: nil)
        let commentImage = UIImage(named: "commentBubble", in: Brilliant.imageBundle(), compatibleWith: nil)
        self.closeButton.setImage(image, for: UIControlState())
        self.closeButton.imageEdgeInsets = UIEdgeInsets(top: 15, left: 15, bottom: 25, right: 25)
        
        self.explanationLabel.font = Brilliant.sharedInstance().mainLabelFont()
        self.explanationLabel.textColor = Brilliant.sharedInstance().mainLabelColor()
        
        self.doneButton.tintColor = Brilliant.sharedInstance().npsDoneColor()
        
        self.doneButton.titleLabel?.font = Brilliant.sharedInstance().submitButtonFont()
    }
    
    override func viewDidAppear(_ animated: Bool) {
//        let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(3 * Double(NSEC_PER_SEC)))
//        dispatch_after(delayTime, dispatch_get_main_queue()) {
//            self.delegate?.autoDismissFeedbackComplete()
//        }
    }
    
    @IBAction func closePressed(_ sender: AnyObject) {
        self.delegate?.closePressed(.feedbackScreen)
    }
    
    @IBAction func donePressed(_ sender: AnyObject) {
        self.delegate?.doneWithFeedbackPressed()
    }
}
