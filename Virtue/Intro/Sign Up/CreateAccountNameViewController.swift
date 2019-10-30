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
import FirebaseStorage

class CreateAccountNameViewController: UIViewController {
    
    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var fullNameTextField: UITextField!
    //@IBOutlet weak var userTypeTextField: UITextField!
    @IBOutlet weak var profilePic: UIImageView!
    @IBOutlet weak var lineButton: UIButton!
    
    //var typePicker: UIPickerView = UIPickerView()
    //let userTypes = ["Volunteer", "Creator"]
    var dataRef : DatabaseReference!
    var storageRef: StorageReference!
    var activityIndicator = UIActivityIndicatorView()
    var imageChanged = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //typePicker.delegate = self
        //typePicker.dataSource = self
        
        lineButton.layer.cornerRadius = 6
        doneButton.layer.cornerRadius = 6
        doneButton.isEnabled = false
        doneButton.backgroundColor = UIColor.gray
        
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(CreateAccountNameViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        
        self.view.addGestureRecognizer(tap)
        
        self.navigationItem.hidesBackButton = true
        
        // sets the database reference
        dataRef = Database.database().reference()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        UIApplication.shared.statusBarStyle = .default
    }
    
    @IBAction func finishedCreateAccount(_ sender: UIButton) {
        
        self.dismissKeyboard()
        self.saveProifleDataToDatabase()
    }
    
    func saveProifleDataToDatabase() {
        self.startLoading()
        // uses the user id to create its own data child and the child is set a name and a userType
        if let userID = Auth.auth().currentUser?.uid {
            var profileImageData : Data!
            self.storageRef = Storage.storage().reference(forURL: Config.SOTRAGE_REF).child("profile_image").child(userID)
            
            if imageChanged{
                profileImageData = UIImageJPEGRepresentation(profilePic.image!, 0.1)
            } else {
                profileImageData = UIImageJPEGRepresentation(UIImage.init(named: "Profile-1")!, 0.1)
            }
            
            self.storageRef.putData(profileImageData!, metadata: nil, completion: { (metadata, error) in
                self.endLoading()
                if error != nil {
                    print(error?.localizedDescription as Any)
                    
                    return
                }
                
                let profileImageURL = metadata?.downloadURL()?.absoluteString
                //let profileValues = ["name": self.fullNameTextField.text, "userType": self.userTypeTextField.text, "profileImageURL": profileImageURL]
                let profileValues = ["name": self.fullNameTextField.text, "profileImageURL": profileImageURL]
                
                self.dataRef.child("users").child(userID).setValue(profileValues)
                
                //UserDefaults.standard.set(false, forKey: "userTypeDeltWith")
                //self.dismiss(animated: true, completion: nil)
                self.performSegue(withIdentifier: "createUserTypeSegue", sender: self)
            })
        } else {
            
            self.endLoading()
        }
    }

    @IBAction func addProfilePicButton(_ sender: UIButton) {
        
        self.startLoading()
        let profileImagePickerController = UIImagePickerController()
        
        profileImagePickerController.delegate = self
        profileImagePickerController.sourceType = .photoLibrary
        profileImagePickerController.allowsEditing = false
        
        self.present(profileImagePickerController, animated: true) {
            self.endLoading()
        }
    }
    
    @IBAction func nameTextFieldEditing(_ sender: Any) {
        
        if fullNameTextField.text == "" {
            doneButton.isEnabled = false
            doneButton.backgroundColor = UIColor.gray
        } else {
            doneButton.isEnabled = true
            doneButton.backgroundColor = UIColor.black
        }
    }
    @IBAction func nameTextPrimaryActionTriggered(_ sender: Any) {
        
        finishedCreateAccount(doneButton)
    }
    
    /*@IBAction func userTypeTextEditing(_ sender: UITextField) {
        
        sender.inputView = typePicker
        
        if sender.text == "" {
            doneButton.isEnabled = false
        } else {
            doneButton.isEnabled = true
        }
    }*/
    
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

/*extension CreateAccountNameViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    
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

extension CreateAccountNameViewController: UINavigationControllerDelegate ,UIImagePickerControllerDelegate {
    
    // when the user is done picking their image, it is set as the official event image
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            
            imageChanged = true
            profilePic.image = image
            profilePic.contentMode = .scaleAspectFill
            // makes a circle profile pic and sets it to a placeholder
            self.profilePic.layer.borderWidth = 1
            self.profilePic.layer.masksToBounds = false
            self.profilePic.layer.cornerRadius = profilePic.frame.height/2
            self.profilePic.clipsToBounds = true
        } else {
            print("Profile Photo Picking Error")
        }
        
        self.dismiss(animated: true, completion: nil)
    }
}
