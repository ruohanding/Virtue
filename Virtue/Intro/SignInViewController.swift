//
//  SignInViewController.swift
//  Virtue
//
//  Created by Ruohan Ding on 5/20/17.
//  Copyright © 2017 Ding. All rights reserved.
//

import UIKit
import FirebaseAuth

class SignInViewController: UIViewController{
    
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var problemLabel: UILabel!
    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var lineButton: UIButton!
    
    var activityIndicator = UIActivityIndicatorView()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        UIApplication.shared.statusBarStyle = .lightContent
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    override func viewDidLoad() {
        
        // adds a gesture so that when the user is done editing something they can just tap out
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(SignInViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tap)
        
        lineButton.layer.cornerRadius = 6
        
        // hides the nextButton
        doneButton.isEnabled = false
        doneButton.backgroundColor = UIColor.gray
        doneButton.layer.cornerRadius = 6
    }
    
    @IBAction func emailFieldPrimaryActionTriggered(_ sender: Any) {
        emailTextField.resignFirstResponder()
        passwordTextField.becomeFirstResponder()
    }
    
    @IBAction func passwordFieldPrimaryActionTriggered(_ sender: Any) {
        doneButtonClicked(doneButton)
    }
    
    @IBAction func emailTextFieldEditingChanged(_ sender: UITextField) {
        
        emailTextField.layer.borderWidth = 0.0
        passwordTextField.layer.borderWidth = 0.0
        problemLabel.isHidden = true
        
        // enables the nextButton if there is text in emailtextfield
        if emailTextField.text == "" || passwordTextField.text == "" {
            doneButton.isEnabled = false
            doneButton.backgroundColor = UIColor.gray
        } else {
            doneButton.isEnabled = true
            doneButton.backgroundColor = UIColor.black
        }
        
    }
    
    @IBAction func passwordTextFieldEditingChanged(_ sender: UITextField) {
        
        emailTextField.layer.borderWidth = 0.0
        passwordTextField.layer.borderWidth = 0.0
        problemLabel.isHidden = true
        
        // enables the nextButton if there is text in emailtextfield
        if passwordTextField.text == "" || emailTextField.text == "" {
            doneButton.isEnabled = false
            doneButton.backgroundColor = UIColor.gray
        } else {
            doneButton.isEnabled = true
            doneButton.backgroundColor = UIColor.black
        }
    }
    @IBAction func doneButtonClicked(_ sender: UIButton) {
        
        self.startLoading()
        self.view.endEditing(true)
        Auth.auth().signIn(withEmail: emailTextField.text!, password: passwordTextField.text!) { (user, error) in
            
            if user != nil {
                
                self.endLoading()
                self.dismiss(animated: true, completion: nil)
            } else {
                
                self.endLoading()
                if let accountError = error?.localizedDescription {
                    
                    self.emailTextField.layer.borderWidth = 1.0
                    self.emailTextField.layer.borderColor = UIColor.red.cgColor
                    
                    self.passwordTextField.layer.borderWidth = 1.0
                    self.passwordTextField.layer.borderColor = UIColor.red.cgColor
                    
                    self.problemLabel.isHidden = false
                    self.problemLabel.text = "\(accountError)"
                } else {
                    
                    print("Unknown create account error")
                }
            }
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
    
    @objc func dismissKeyboard() {
        // makes everything in the view resignFirstResponder which in turn dismisses all the keyboards
        self.view.endEditing(true)
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
