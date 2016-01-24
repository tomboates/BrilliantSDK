//
//  RateAppViewController.swift
//  Pods
//
//  Created by Phillip Connaughton on 1/24/16.
//
//

import Foundation

protocol RateAppViewControllerDelegate: class{
    
    func closePressed(state: SurveyViewControllerState)
    func rateAppPressed()
    func doNotRateAppPressed()
}

class RateAppViewController: UIViewController
{
    @IBOutlet var closeButton: UIButton!
    @IBOutlet var rateLabel: UILabel!
    @IBOutlet var confirmButton: UIButton!
    @IBOutlet var denyButton: UIButton!
    @IBOutlet var ratingStars: UIImageView!
    
    internal weak var delegate : RateAppViewControllerDelegate?
    
    override func viewDidLoad() {
        
        let image = UIImage(named: "brilliant-icon-close", inBundle:Brilliant.imageBundle(), compatibleWithTraitCollection: nil)
        self.closeButton.setImage(image, forState: .Normal)
        
        let ratingStarsImage = UIImage(named: "ratingStars", inBundle:Brilliant.imageBundle(), compatibleWithTraitCollection: nil)
        self.ratingStars.image = ratingStarsImage
        
        self.rateLabel.font = Brilliant.sharedInstance().mainLabelFont()
        self.rateLabel.textColor = Brilliant.sharedInstance().mainLabelColor()
        
        Brilliant.sharedInstance().styleButton(self.confirmButton)
        
        self.denyButton.tintColor = Brilliant.sharedInstance().npsDoneColor()
    }
    
    @IBAction func closePressed(sender: AnyObject) {
        self.delegate?.closePressed(.RateAppScreen)
    }
    
    @IBAction func denyPressed(sender: AnyObject) {
        self.delegate?.doNotRateAppPressed()
    }
    
    @IBAction func confirmPressed(sender: AnyObject) {
        self.delegate?.rateAppPressed()
    }
}