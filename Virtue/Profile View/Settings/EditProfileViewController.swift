//
//  EditProfileViewController.swift
//  Virtue
//
//  Created by Ruohan Ding on 3/1/18.
//  Copyright © 2018 Ding. All rights reserved.
//

import UIKit
import FirebaseStorage
import FirebaseDatabase
import FirebaseAuth

class EditProfileViewController: UIViewController {
    
    var databaseRef: DatabaseReference!
    var databaseHandle: DatabaseHandle!
    var storageRef: StorageReference!
    var userInfo : UserInfo!
    var activityIndicator = UIActivityIndicatorView()

    @IBOutlet weak var profilePic: UIImageView!
    @IBOutlet weak var nameText: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        databaseRef = Database.database().reference()
        storageRef = Storage.storage().reference()
        userInfo = UserInfo.shared
        
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(EditProfileViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        
        self.view.addGestureRecognizer(tap)
        
        nameText.layer.cornerRadius = 6
        nameText.text = userInfo.userName
        self.setProfilePic()
    }
    @IBAction func cancelClicked(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func doneClicked(_ sender: Any) {
        self.dismissKeyboard()
        self.saveProifleDataToDatabase()
        self.dismiss(animated: true, completion: nil)
    }
    
    func saveProifleDataToDatabase() {
        self.startLoading()
        // uses the user id to create its own data child and the child is set a name and a userType
        if let userID = Auth.auth().currentUser?.uid {
            
            self.storageRef = Storage.storage().reference(forURL: Config.SOTRAGE_REF).child("profile_image").child(userID)
            let profileImageData = UIImageJPEGRepresentation(profilePic.image!, 0.1)
            
            self.storageRef.putData(profileImageData!, metadata: nil, completion: { (metadata, error) in
                self.endLoading()
                if error != nil {
                    print(error?.localizedDescription as Any)
                    
                    return
                }
                
                let profileImageURL = metadata?.downloadURL()?.absoluteString
                //let profileValues = ["name": self.fullNameTextField.text, "userType": self.userTypeTextField.text, "profileImageURL": profileImageURL]
                let userNameUpdate = ["/users/\(userID)/name/" : self.nameText.text]
                let userImageUpdate = ["/users/\(userID)/profileImageURL/" : profileImageURL]
                self.databaseRef.updateChildValues(userNameUpdate)
                self.databaseRef.updateChildValues(userImageUpdate)
                
                UserInfo.shared.userName = self.nameText.text
                UserInfo.shared.userProfilePicURL = profileImageURL
            })
        } else {
            
            self.endLoading()
        }
    }
    
    @IBAction func imageEdit(_ sender: Any) {
        self.startLoading()
        let profileImagePickerController = UIImagePickerController()
        
        profileImagePickerController.delegate = self
        profileImagePickerController.sourceType = .photoLibrary
        profileImagePickerController.allowsEditing = false
        
        self.present(profileImagePickerController, animated: true){
            self.endLoading()
        }
    }
    
    func setProfilePic(){
        
        // makes a circle profile pic and sets it to a placeholder
        self.profilePic.layer.borderWidth = 1
        self.profilePic.layer.masksToBounds = false
        self.profilePic.layer.cornerRadius = profilePic.frame.height/2
        self.profilePic.clipsToBounds = true
        
        // gets the image from storage and puts it in
        let userId = Auth.auth().currentUser!.uid
        let profileImageRef = storageRef.child("profile_image/\(userId)")
        
        profileImageRef.getData(maxSize: 1 * 1024 * 1024) { data, error in
            if let error = error {
                
                print(error)
            } else {
                self.profilePic.image = UIImage(data: data!)
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

extension EditProfileViewController: UINavigationControllerDelegate ,UIImagePickerControllerDelegate {
    
    // when the user is done picking their image, it is set as the official event image
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            
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
