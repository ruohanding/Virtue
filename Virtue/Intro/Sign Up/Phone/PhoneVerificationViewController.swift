//
//  PhoneVerificationViewController.swift
//  Virtue
//
//  Created by Ruohan Ding on 10/24/17.
//  Copyright © 2017 Ding. All rights reserved.
//

import UIKit
import FirebaseAuth

class PhoneVerificationViewController: UIViewController {

    @IBOutlet weak var v1TextField: UITextField!
    @IBOutlet weak var v2TextField: UITextField!
    @IBOutlet weak var v3TextField: UITextField!
    @IBOutlet weak var v4TextField: UITextField!
    @IBOutlet weak var v5TextField: UITextField!
    @IBOutlet weak var v6TextField: UITextField!
    
    @IBOutlet weak var problemLabel: UILabel!
    @IBOutlet weak var nextButton: UIButton!
    
    let verificationID = UserDefaults.standard.string(forKey: "authVerificationID")
    var verificationCode = ""
    var activityIndicator = UIActivityIndicatorView()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        // changes the status color
        UIApplication.shared.statusBarStyle = .default
        
        v1TextField.becomeFirstResponder()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // adds a gesture so that when the user is done editing something they can just tap out
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(PhoneVerificationViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tap)
        
        // hides the nextButton
        nextButton.isEnabled = false
        nextButton.layer.cornerRadius = 6
        nextButton.backgroundColor = UIColor.gray
    }
    
    @IBAction func v1EditingChanged(_ sender: Any) {
        if (v1TextField.text?.count == 1) && (v2TextField.text?.count == 1) && (v3TextField.text?.count == 1) && (v4TextField.text?.count == 1) && (v5TextField.text?.count == 1) && (v6TextField.text?.count == 1) {
            nextButton.isEnabled = true
            nextButton.backgroundColor = UIColor.black
            
        } else if v1TextField.text?.count == 1 {
            v2TextField.becomeFirstResponder()
        } else if v1TextField.text?.count != 0{
            var tempText = v1TextField.text
            tempText?.removeLast()
            v1TextField.text = tempText
        }
    }

    @IBAction func v2EditingChanged(_ sender: Any) {
        if (v1TextField.text?.count == 1) && (v2TextField.text?.count == 1) && (v3TextField.text?.count == 1) && (v4TextField.text?.count == 1) && (v5TextField.text?.count == 1) && (v6TextField.text?.count == 1) {
            nextButton.isEnabled = true
            nextButton.backgroundColor = UIColor.black
            
        } else if v2TextField.text?.count == 1 {
            v3TextField.becomeFirstResponder()
        } else if v2TextField.text?.count != 0{
            var tempText = v2TextField.text
            tempText?.removeLast()
            v2TextField.text = tempText
        }
    }
    
    @IBAction func v3EditingChanged(_ sender: Any) {
        if (v1TextField.text?.count == 1) && (v2TextField.text?.count == 1) && (v3TextField.text?.count == 1) && (v4TextField.text?.count == 1) && (v5TextField.text?.count == 1) && (v6TextField.text?.count == 1) {
            nextButton.isEnabled = true
            nextButton.backgroundColor = UIColor.black
            
        } else if v3TextField.text?.count == 1 {
            v4TextField.becomeFirstResponder()
        } else if v3TextField.text?.count != 0{
            var tempText = v3TextField.text
            tempText?.removeLast()
            v3TextField.text = tempText
        }
    }
    
    @IBAction func v4EditingChanged(_ sender: Any) {
        if (v1TextField.text?.count == 1) && (v2TextField.text?.count == 1) && (v3TextField.text?.count == 1) && (v4TextField.text?.count == 1) && (v5TextField.text?.count == 1) && (v6TextField.text?.count == 1) {
            nextButton.isEnabled = true
            nextButton.backgroundColor = UIColor.black
            
        } else if v4TextField.text?.count == 1 {
            v5TextField.becomeFirstResponder()
        } else if v4TextField.text?.count != 0{
            var tempText = v4TextField.text
            tempText?.removeLast()
            v4TextField.text = tempText
        }
    }
    
    @IBAction func v5EditingChanged(_ sender: Any) {
        if (v1TextField.text?.count == 1) && (v2TextField.text?.count == 1) && (v3TextField.text?.count == 1) && (v4TextField.text?.count == 1) && (v5TextField.text?.count == 1) && (v6TextField.text?.count == 1) {
            nextButton.isEnabled = true
            nextButton.backgroundColor = UIColor.black
            
        } else if v5TextField.text?.count == 1 {
            v6TextField.becomeFirstResponder()
        } else if v5TextField.text?.count != 0{
            var tempText = v5TextField.text
            tempText?.removeLast()
            v5TextField.text = tempText
        }
    }
    
    @IBAction func v6EditingChanged(_ sender: Any) {
        if (v1TextField.text?.count == 1) && (v2TextField.text?.count == 1) && (v3TextField.text?.count == 1) && (v4TextField.text?.count == 1) && (v5TextField.text?.count == 1) && (v6TextField.text?.count == 1) {
            nextButton.isEnabled = true
            nextButton.backgroundColor = UIColor.black
        }
        
        if v5TextField.text?.count == 1 {
            v6TextField.resignFirstResponder()
            
        } else if v6TextField.text?.count != 0{
            var tempText = v6TextField.text
            tempText?.removeLast()
            v6TextField.text = tempText
        }
    }
    
    @IBAction func nextButtonClicked(_ sender: UIButton) {
        self.startLoading()
        verificationCode = v1TextField.text!
        verificationCode += v2TextField.text!
        verificationCode += v3TextField.text!
        verificationCode += v4TextField.text!
        verificationCode += v5TextField.text!
        verificationCode += v6TextField.text!
        
        let credential = PhoneAuthProvider.provider().credential(withVerificationID: verificationID!, verificationCode: verificationCode)
        if Auth.auth().currentUser == nil {
            Auth.auth().signIn(with: credential) { (user, error) in
                self.endLoading()
                if let error = error {
                    self.v1TextField.layer.borderWidth = 1.0
                    self.v1TextField.layer.borderColor = UIColor.red.cgColor
                    self.v2TextField.layer.borderWidth = 1.0
                    self.v2TextField.layer.borderColor = UIColor.red.cgColor
                    self.v3TextField.layer.borderWidth = 1.0
                    self.v3TextField.layer.borderColor = UIColor.red.cgColor
                    self.v4TextField.layer.borderWidth = 1.0
                    self.v4TextField.layer.borderColor = UIColor.red.cgColor
                    self.v5TextField.layer.borderWidth = 1.0
                    self.v5TextField.layer.borderColor = UIColor.red.cgColor
                    self.v6TextField.layer.borderWidth = 1.0
                    self.v6TextField.layer.borderColor = UIColor.red.cgColor
                    
                    self.problemLabel.isHidden = false
                    self.problemLabel.text = "\(error.localizedDescription)"
                    self.v1TextField.becomeFirstResponder()
                    self.verificationCode = ""
                    self.v1TextField.text = ""
                    self.v2TextField.text = ""
                    self.v3TextField.text = ""
                    self.v4TextField.text = ""
                    self.v5TextField.text = ""
                    self.v6TextField.text = ""
                    return
                }
                
                self.view.endEditing(true)
                self.performSegue(withIdentifier: "emailSignInSegue", sender: self)
            }
        } else {
            Auth.auth().currentUser!.link(with: credential, completion: { (user, error) in
                self.endLoading()
                if let error = error {
                    self.v1TextField.layer.borderWidth = 1.0
                    self.v1TextField.layer.borderColor = UIColor.red.cgColor
                    self.v2TextField.layer.borderWidth = 1.0
                    self.v2TextField.layer.borderColor = UIColor.red.cgColor
                    self.v3TextField.layer.borderWidth = 1.0
                    self.v3TextField.layer.borderColor = UIColor.red.cgColor
                    self.v4TextField.layer.borderWidth = 1.0
                    self.v4TextField.layer.borderColor = UIColor.red.cgColor
                    self.v5TextField.layer.borderWidth = 1.0
                    self.v5TextField.layer.borderColor = UIColor.red.cgColor
                    self.v6TextField.layer.borderWidth = 1.0
                    self.v6TextField.layer.borderColor = UIColor.red.cgColor
                    
                    self.problemLabel.isHidden = false
                    self.problemLabel.text = "\(error.localizedDescription)"
                    self.v1TextField.becomeFirstResponder()
                    self.verificationCode = ""
                    self.v1TextField.text = ""
                    self.v2TextField.text = ""
                    self.v3TextField.text = ""
                    self.v4TextField.text = ""
                    self.v5TextField.text = ""
                    self.v6TextField.text = ""
                    return
                }
                self.presentingViewController?.presentingViewController?.dismiss(animated: true, completion: nil)
            })
        }
    }
    
    @objc func dismissKeyboard() {
        // makes everything in the view resignFirstResponder which in turn dismisses all the keyboards
        self.view.endEditing(true)
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
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
