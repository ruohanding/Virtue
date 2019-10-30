//
//  SetUserTypeViewController.swift
//  Virtue
//
//  Created by Ruohan Ding on 8/9/17.
//  Copyright © 2017 Ding. All rights reserved.
//

//
//  CreateAccountPasswordViewController.swift
//  Virtue
//
//  Created by Ruohan Ding on 7/20/17.
//  Copyright © 2017 Ding. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase

class SetUserTypeViewController: UIViewController {
    
    //@IBOutlet weak var doneButton: UIButton!
    //@IBOutlet weak var userTypeTextField: UITextField!
    
    //var typePicker: UIPickerView = UIPickerView()
    //let userTypes = ["Volunteer", "Creator"]
    
    @IBOutlet weak var volunteerButton: UIButton!
    @IBOutlet weak var createButton: UIButton!
    
    var dataRef : DatabaseReference!
    var activityIndicator = UIActivityIndicatorView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //typePicker.delegate = self
        //typePicker.dataSource = self
        
        volunteerButton.layer.cornerRadius = 6
        createButton.layer.cornerRadius = 6
        
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(CreateAccountNameViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        
        self.view.addGestureRecognizer(tap)
        
        self.navigationItem.hidesBackButton = true
        
        // sets the database reference
        dataRef = Database.database().reference()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        
        UIApplication.shared.statusBarStyle = .default
        self.endLoading()
    }
    
    /*@IBAction func finishedCreateAccount(_ sender: UIButton) {
        
        self.dismissKeyboard()
        self.startLoading()
        self.resetDatabaseDataWith(userType: self.userTypeTextField.text!)
        
        UserDefaults.standard.set(false, forKey: "userTypeDeltWith")
        self.dismiss(animated: true, completion: nil)
    }*/
    
    @IBAction func volunteerPressed(_ sender: Any) {
        
        self.startLoading()
        self.resetDatabaseDataWith(userType: "Volunteer")
        
        UserDefaults.standard.set(false, forKey: "userTypeDeltWith")
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func createPressed(_ sender: Any) {
        
        self.startLoading()
        self.resetDatabaseDataWith(userType: "Creator")
        
        UserDefaults.standard.set(false, forKey: "userTypeDeltWith")
        self.dismiss(animated: true, completion: nil)
    }
    
    func resetDatabaseDataWith(userType: String) {
        
        // uses the user id to create its own data child and the child is set a name and a userType
        if let userID = Auth.auth().currentUser?.uid {
            
            self.dataRef.child("users").child(userID).observeSingleEvent(of:.value, with: { (snapshot) in
                
                self.endLoading()
                let values = snapshot.value as? NSDictionary
                let userName = values?["name"] as? String ?? ""
                let userProfile = values?["profileImageURL"] as? String ?? ""
                
                let profileValues = ["name": userName, "userType": userType, "profileImageURL": userProfile]
                
                self.dataRef.child("users").child(userID).updateChildValues(profileValues, withCompletionBlock: { (error, ref) in
                    
                    if error != nil {
                        print(error!.localizedDescription)
                    }
                })
                
            }) { (error) in
                self.endLoading()
                print(error.localizedDescription)
            }
        }
    }
    
    func startLoading() {
        // creats an activity indicator and sets it to the middle of the screen and makes it grey
        activityIndicator.center = self.view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.activityIndicatorViewStyle = .gray
        activityIndicator.backgroundColor = UIColor.black
        view.addSubview(activityIndicator)
        
        activityIndicator.startAnimating()
        // ignores all evens
        UIApplication.shared.beginIgnoringInteractionEvents()
    }
    
    func endLoading() {
        
        activityIndicator.stopAnimating()
        UIApplication.shared.endIgnoringInteractionEvents()
    }
    
    /*@IBAction func userTypeTextEditing(_ sender: UITextField) {
        
        sender.inputView = typePicker
        
        if sender.text == "" {
            doneButton.isEnabled = false
        } else {
            doneButton.isEnabled = true
        }
    }*/
    
    @objc func dismissKeyboard() {
        // makes everything in the view resignFirstResponder which in turn dismisses all the keyboards
        self.view.endEditing(true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

/*extension SetUserTypeViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return userTypes.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        return userTypes[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        // sets whatever row the user selected to be the user type
        userTypeTextField.text = userTypes[row]
        doneButton.isEnabled = true
    }
}*/
