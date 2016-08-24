//
//  RateAppViewController.swift
//  Pods
//
//  Created by Phillip Connaughton on 1/24/16.
//
//

import Foundation

protocol RateAppViewControllerDelegate: class{
    
    func closePressed(_ state: SurveyViewControllerState)
    func rateAppPressed()
    func doNotRateAppPressed()
}

class RateAppViewController: UIViewController
{
    @IBOutlet var closeButton: UIButton!
    @IBOutlet var rateLabel: UILabel!
    @IBOutlet var confirmButton: UIButton!
    @IBOutlet var denyButton: UIButton!
    
    internal weak var delegate : RateAppViewControllerDelegate?
    
    override func viewDidLoad() {
        
        let image = UIImage(named: "brilliant-icon-close", in:Brilliant.imageBundle(), compatibleWith: nil)
        self.closeButton.setImage(image, for: UIControlState())
        self.closeButton.imageEdgeInsets = UIEdgeInsets(top: 15, left: 15, bottom: 25, right: 25)
        
        self.rateLabel.font = Brilliant.sharedInstance().mainLabelFont()
        self.rateLabel.textColor = Brilliant.sharedInstance().mainLabelColor()
        
        Brilliant.sharedInstance().styleButton(button: self.confirmButton)
        
        self.denyButton.tintColor = Brilliant.sharedInstance().npsDoneColor()
        
        self.confirmButton.titleLabel?.font = Brilliant.sharedInstance().submitButtonFont()
        self.denyButton.titleLabel?.font = Brilliant.sharedInstance().submitButtonFont()
    }
    
    @IBAction func closePressed(_ sender: AnyObject) {
        self.delegate?.closePressed(.rateAppScreen)
    }
    
    @IBAction func denyPressed(_ sender: AnyObject) {
        self.delegate?.doNotRateAppPressed()
    }
    
    @IBAction func starsPressed(_ sender: AnyObject) {
        self.delegate?.rateAppPressed()
    }
    
    @IBAction func confirmPressed(_ sender: AnyObject) {
        self.delegate?.rateAppPressed()
    }
}
