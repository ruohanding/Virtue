//
//  EmailCreateViewController.swift
//  Virtue
//
//  Created by Ruohan Ding on 12/21/17.
//  Copyright © 2017 Ding. All rights reserved.
//

import UIKit
import FirebaseAuth

class EmailCreateViewController: UIViewController {
    
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var problemLabel: UILabel!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var lineButton: UIButton!
    
    var activityIndicator = UIActivityIndicatorView()
    
    override func viewDidLoad() {
        
        // adds a gesture so that when the user is done editing something they can just tap out
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(EmailCreateViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tap)
        
        // hides the nextButton
        nextButton.isEnabled = false
        nextButton.backgroundColor = UIColor.gray
        
        nextButton.layer.cornerRadius = 6
        lineButton.layer.cornerRadius = 6
        passwordTextField.layer.cornerRadius = 6
        emailTextField.layer.cornerRadius = 6
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        UIApplication.shared.statusBarStyle = .lightContent
    }
    
    @IBAction func emailTextFieldEditingChanged(_ sender: UITextField) {
        
        emailTextField.layer.borderWidth = 0.0
        passwordTextField.layer.borderWidth = 0.0
        problemLabel.isHidden = true
        
        // enables the nextButton if there is text in emailtextfield
        if emailTextField.text == "" || passwordTextField.text == "" {
            nextButton.isEnabled = false
            nextButton.backgroundColor = UIColor.gray
        } else {
            nextButton.isEnabled = true
            nextButton.backgroundColor = UIColor.black
        }
        
    }
    
    @IBAction func passwordTextFieldEditingChanged(_ sender: UITextField) {
        
        emailTextField.layer.borderWidth = 0.0
        passwordTextField.layer.borderWidth = 0.0
        problemLabel.isHidden = true
        
        // enables the nextButton if there is text in emailtextfield
        if passwordTextField.text == "" || emailTextField.text == "" {
            nextButton.isEnabled = false
            nextButton.backgroundColor = UIColor.gray
        } else {
            nextButton.isEnabled = true
            nextButton.backgroundColor = UIColor.black
        }
    }
    
    @IBAction func emailFieldPrimaryActionTriggered(_ sender: Any) {
        
        emailTextField.resignFirstResponder()
        passwordTextField.becomeFirstResponder()
    }
    
    @IBAction func passwordFieldPrimaryActionTriggered(_ sender: Any) {
        
        nextButtonClicked(nextButton)
    }
    
    @IBAction func nextButtonClicked(_ sender: UIButton) {
        
        self.startLoading()
        self.view.endEditing(true)
        // checks to see if the user is already signed in or not
        if Auth.auth().currentUser == nil{
            Auth.auth().createUser(withEmail: emailTextField.text!, password: passwordTextField.text!) { (user, error) in
                self.endLoading()
                if user != nil {
                    let credential = EmailAuthProvider.credential(withEmail: self.emailTextField.text!, password: self.passwordTextField.text!)
                    user!.link(with: credential, completion: { (user, error) in
                        
                        self.performSegue(withIdentifier: "phoneToNameSegue", sender: self)
                    })
                } else {
                    
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
        } else {
            let credential = EmailAuthProvider.credential(withEmail: self.emailTextField.text!, password: self.passwordTextField.text!)
            Auth.auth().currentUser!.link(with: credential, completion: { (user, error) in
                self.endLoading()
                if let error = error {
                    self.emailTextField.layer.borderWidth = 1.0
                    self.emailTextField.layer.borderColor = UIColor.red.cgColor
                    self.passwordTextField.layer.borderWidth = 1.0
                    self.passwordTextField.layer.borderColor = UIColor.red.cgColor
                    
                    self.problemLabel.isHidden = false
                    self.problemLabel.text = "\(error.localizedDescription)"
                    return
                }
                self.performSegue(withIdentifier: "phoneToNameSegue", sender: self)
            })
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

