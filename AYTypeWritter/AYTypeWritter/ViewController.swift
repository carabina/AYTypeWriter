//
//  ViewController.swift
//  AYTypeWritter
//
//  Created by Anson Yao on 2018-09-05.
//  Copyright © 2018 Anson Yao. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet weak var typewriterView: AYTypewriterView!
    
    let welcomeMessage = "Hello, AYTypeWriterLabel 📝"
    let primaryColor = UIColor(red: 1.0, green: 0.0, blue: 0.0, alpha: 1.0)
    let primaryFont = UIFont(name: "Ubuntu-Bold", size: 18)!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        /*
         Customization 1
        */
        //typewriterView.label.text = welcomeMessage
        //setupTextAppearance()
        
        /*
         Customization 2
         */
        typewriterView.label.attributedText = getAttributedText()
        //Both customizations will work

        typewriterView.startAnimation()
    }
    
    func setupTextAppearance() {
        typewriterView.label.textColor = primaryColor
        typewriterView.label.font = primaryFont
    }
    
    func getAttributedText() -> NSAttributedString {
        let attributedString = NSMutableAttributedString(string: welcomeMessage, attributes:
            [NSAttributedStringKey.foregroundColor: primaryColor,
             NSAttributedStringKey.font: primaryFont]
        )
        return attributedString
    }
    
    @IBAction func startButtonAction(_ sender: UIButton) {
        typewriterView.startAnimation()
    }
    
    @IBAction func finishButtonAction(_ sender: UIButton) {
        typewriterView.finishAnimation()
    }
    
    @IBAction func pauseButtonAction(_ sender: UIButton) {
        typewriterView.pauseAnimation()
    }
    
    @IBAction func resumeButtonAction(_ sender: UIButton) {
        typewriterView.resumeAnimation()
    }
    
    @IBAction func resetButtonAction(_ sender: UIButton) {
        typewriterView.clearAnimation()
    }
    
}

