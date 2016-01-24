//
//  NegativeFeedbackCompleteViewController.swift
//  Pods
//
//  Created by Phillip Connaughton on 1/24/16.
//
//

import Foundation

protocol NegativeFeedbackCompleteViewControllerDelegate: class{
    
    func closePressed(state: SurveyViewControllerState)
    func doneWithFeedbackPressed()
}

class NegativeFeedbackCompleteViewController: UIViewController
{
    @IBOutlet var closeButton: UIButton!
    @IBOutlet var commentImage: UIImageView!
    @IBOutlet var explanationLabel: UILabel!
    @IBOutlet var doneButton: UIButton!
    
    internal weak var delegate : NegativeFeedbackCompleteViewControllerDelegate?
    
    override func viewDidLoad() {
        
        let image = UIImage(named: "brilliant-icon-close", inBundle:Brilliant.imageBundle(), compatibleWithTraitCollection: nil)
        let commentImage = UIImage(named: "commentBubble", inBundle: Brilliant.imageBundle(), compatibleWithTraitCollection: nil)
        self.closeButton.setImage(image, forState: .Normal)
        self.commentImage.image = commentImage
        
        self.explanationLabel.font = Brilliant.sharedInstance().mainLabelFont()
        self.explanationLabel.textColor = Brilliant.sharedInstance().mainLabelColor()
        
        self.doneButton.tintColor = Brilliant.sharedInstance().npsDoneColor()
    }
    
    @IBAction func closePressed(sender: AnyObject) {
        self.delegate?.closePressed(.FeedbackScreen)
    }
    
    @IBAction func donePressed(sender: AnyObject) {
        self.delegate?.doneWithFeedbackPressed()
    }
}