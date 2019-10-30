//
//  PhoneViewController.swift
//  Virtue
//
//  Created by Ruohan Ding on 10/19/17.
//  Copyright © 2017 Ding. All rights reserved.
//

import FirebaseAuth
import UIKit

class PhoneViewController: UIViewController {

    @IBOutlet weak var phoneTextField: UITextField!
    @IBOutlet weak var problemLabel: UILabel!
    @IBOutlet weak var nextButton: UIButton!
    
    var activityIndicator = UIActivityIndicatorView()
    
    override func viewDidLoad() {
        
        // adds a gesture so that when the user is done editing something they can just tap out
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(PhoneViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tap)
        
        // hides the nextButton
        nextButton.isEnabled = false
        nextButton.backgroundColor = UIColor.gray
        
        self.nextButton.layer.cornerRadius = 6
    }
    
    
    @IBAction func phoneTextFieldEditingChanged(_ sender: UITextField) {
        
        phoneTextField.layer.borderWidth = 0.0
        problemLabel.isHidden = true
        
        // enables the nextButton if there is text in emailtextfield
        if phoneTextField.text == "" {
            nextButton.isEnabled = false
            nextButton.backgroundColor = UIColor.gray
        } else {
            nextButton.isEnabled = true
            nextButton.backgroundColor = UIColor.black
        }
        
    }
    
    @IBAction func nextButtonClicked(_ sender: UIButton) {
        
        self.startLoading()
        self.view.endEditing(true)
        
        PhoneAuthProvider.provider().verifyPhoneNumber("+1" + phoneTextField.text!, uiDelegate: nil) { (verificationID, error) in
            
            self.endLoading()
            if let error = error {
                
                self.phoneTextField.layer.borderWidth = 1.0
                self.phoneTextField.layer.borderColor = UIColor.red.cgColor
                
                self.problemLabel.isHidden = false
                self.problemLabel.text = "\(error.localizedDescription)"
                return
            }
            
            UserDefaults.standard.set(verificationID, forKey: "authVerificationID")
            self.performSegue(withIdentifier: "verificationSegue", sender: self)
        }
    }
    
    func startLoading() {
        // creats an activity indicator and sets it to the middle of the screen and makes it grey
        activityIndicator.center = self.view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.activityIndicatorViewStyle = .gray
        view.addSubview(activityIndicator)
        
        activityIndicator.startAnimating()
        // ignores all evens
        UIApplication.shared.beginIgnoringInteractionEvents()
    }
    
    func endLoading() {
        
        activityIndicator.stopAnimating()
        UIApplication.shared.endIgnoringInteractionEvents()
    }
    
    @objc func dismissKeyboard() {
        // makes everything in the view resignFirstResponder which in turn dismisses all the keyboards
        self.view.endEditing(true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
