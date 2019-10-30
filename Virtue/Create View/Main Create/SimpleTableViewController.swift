//
//  SimpleTableViewController.swift
//  Virtue
//
//  Created by Ruohan Ding on 7/22/17.
//  Copyright © 2017 Ding. All rights reserved.
//

import UIKit
import FirebaseStorage
import FirebaseDatabase
import FirebaseAuth

class SimpleTableViewController: UITableViewController {
    
    
    @IBOutlet weak var startDateTextField: UITextField!
    @IBOutlet weak var endDateTextField: UITextField!
    @IBOutlet weak var eventNameTextField: UITextField!
    @IBOutlet weak var eventDescriptionTextView: UITextView!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var eventImageView: UIImageView!
    @IBOutlet weak var eventAvailability: UITextField!
    
    var startDatePickerDisplayed: Bool!
    var endDatePickerDisplayed: Bool!
    var dateFormatter = DateFormatter()
    var startDatePicker:UIDatePicker = UIDatePicker()
    var endDatePicker: UIDatePicker = UIDatePicker()
    var startDate : Date!
    var endDate : Date!
    var trialDate = Date()
    var eventLocation = ""
    var allJobsDictionaryArray = [String: JobInfo]()
    var eventData = [String: Any]()
    var dataRef : DatabaseReference!
    var activityIndicator = UIActivityIndicatorView()
    var eventType = ""
    var userInfo : UserInfo!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        userInfo = UserInfo.shared
        // adds a new events to all the events
        
        // adds a gesture so that when the user is done editing something they can just tap out
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(SimpleTableViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        
        self.tableView.addGestureRecognizer(tap)
        
        eventDescriptionTextView.textColor = UIColor.lightGray
        dataRef = Database.database().reference()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        userInfo = UserInfo.shared
    }
    
    @IBAction func cancelNavigationItemClicked(_ sender: UIBarButtonItem) {
        // cancels this view
        dismiss(animated: true, completion: nil)
        
    }
    @IBAction func createDoneButtonClicked(_ sender: UIButton) {
        
        self.writeEventDataToDatabase()
    }
    
    @IBAction func imageViewButtonClicked(_ sender: UIButton) {
        
        let eventImagePickerController = UIImagePickerController()
        
        eventImagePickerController.delegate = self
        eventImagePickerController.sourceType = .photoLibrary
        eventImagePickerController.allowsEditing = false
        
        self.present(eventImagePickerController, animated: true, completion: nil)
    }
    @IBAction func startDateTextEditing(_ sender: UITextField) {
        // sets the keyboard to a datePicker
        startDatePicker.datePickerMode = .dateAndTime
        startDatePicker.minuteInterval = 15
        startDatePicker.minimumDate = Date()
        sender.inputView = startDatePicker
        startDatePicker.addTarget(self, action: #selector(SimpleTableViewController.startDatePickerValueChanged), for: .valueChanged)
    }
    @IBAction func endDateTextEditing(_ sender: UITextField) {
        
        endDatePicker.datePickerMode = .dateAndTime
        endDatePicker.minuteInterval = 15
        
        // we want the minimum date to be 30 minutes added to the start date.
        if startDateTextField == nil {
            endDatePicker.minimumDate = Date()
        } else {
            endDatePicker.minimumDate = startDatePicker.date.addingTimeInterval(30.0 * 60.0)
        }
        
        sender.inputView = endDatePicker
        endDatePicker.addTarget(self, action: #selector(SimpleTableViewController.endDatePickerValueChanged), for: .valueChanged)
        
    }
    
    func createAlert(title: String, message: String) {
        // creates an alert from given info
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        // creates the alert buttons
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action) in
            alert.dismiss(animated: true, completion: nil)
        }))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func writeEventDataToDatabase() {
        // writes everything insie of this event to the database, oh boy
        self.startLoading()
        // uses the user id to create its own data child and the child is set a name and a userType
        if let eventImage = self.eventImageView.image, let imageData = UIImageJPEGRepresentation(eventImage, 0.1) {
            // creats a specific id to use
            let photoID = NSUUID().uuidString
            let storageRef = Storage.storage().reference(forURL: Config.SOTRAGE_REF).child("event_image").child(photoID)
            
            storageRef.putData(imageData, metadata: nil, completion: { (metadata, error) in
                
                if error != nil {
                    print(error?.localizedDescription as Any)
                    
                    return
                }
                
                let eventImageURL = metadata?.downloadURL()?.absoluteString
                // creates a unique auto id for each event
                let allEventReference = self.dataRef.child("allEvents")
                let newEventID = allEventReference.childByAutoId().key
                let eventReference = allEventReference.child(newEventID)
                // writes the autoid for the event inside the user data so it can be referenced later.
                let userID = Auth.auth().currentUser!.uid
                let childUpdates = ["/users/\(userID)/userCreatedEvents/\(newEventID)/" : self.eventNameTextField.text!]
                self.dataRef.updateChildValues(childUpdates)
                
                // saves all the event Data
                self.eventData = ["eventCreatorUID": Auth.auth().currentUser!.uid,
                                  "eventID": newEventID,
                                  "eventImageURL": eventImageURL!,
                                  "eventImageID": photoID,
                                  "eventName": self.eventNameTextField.text!,
                                  "eventDescription": self.eventDescriptionTextView.text!,
                                  "eventStartDate": self.startDate.timeIntervalSince1970,
                                  "eventEndDate": self.endDate.timeIntervalSince1970,
                                  "eventLocation": self.eventLocation,
                                  "eventType": self.eventType,
                                  "eventAvilability": self.eventAvailability.text!,
                                  "active": true]
                
                // this way the whole event gets updated once so that the .childadded observer works well
                eventReference.setValue(self.eventData, withCompletionBlock: { (error, ref) in
                    self.endLoading()
                    if error != nil {
                        print(error!.localizedDescription)
                        return
                    }
                })
                self.dismiss(animated: true, completion: nil)
                
            })
        } else {
            
            self.endLoading()
        }
    }
    
    func formatNumberName(num: Int) -> String {
        // formats the numberName because we have to do it so much
        let spellOutNumberFormatter = NumberFormatter()
        spellOutNumberFormatter.numberStyle = .spellOut
        
        var formatedNumber = spellOutNumberFormatter.string(from: NSNumber(value: num))
        formatedNumber = formatedNumber!.capitalized
        formatedNumber = formatedNumber?.trimmingCharacters(in: .whitespaces)
        
        return formatedNumber!
        
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
    
    @objc func startDatePickerValueChanged(sender:UIDatePicker) {
        // formats the date for the label
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EE, MM/dd/yy, h:mm a"
        dateFormatter.amSymbol = "AM"
        dateFormatter.pmSymbol = "PM"
        
        startDateTextField.text = dateFormatter.string(from: sender.date)
        startDate = sender.date
        
        if endDateTextField != nil && (startDatePicker.date >= endDatePicker.date) {
            
            endDateTextField.textColor = UIColor.red
        }
    }
    
    @objc func endDatePickerValueChanged(sender:UIDatePicker) {
        // formats the date for the label
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EE, MM/dd/yy, h:mm a"
        dateFormatter.amSymbol = "AM"
        dateFormatter.pmSymbol = "PM"
        
        // the color might be red if the date was set wrong
        if endDateTextField.textColor == UIColor.red {
            
            endDateTextField.textColor = UIColor.black
        }
        
        endDateTextField.text = dateFormatter.string(from: sender.date)
        endDate = sender.date
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        if segue.identifier == "simpleLocationSelectorSegue" {
            
            let nextController = segue.destination as! LocationSearchTableViewController
            nextController.eventType = self.eventType
        }
    }
    
    @objc func dismissKeyboard() {
        // makes everything in the view resignFirstResponder which in turn dismisses all the keyboards
        self.view.endEditing(true)
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

/*extension SimpleTableViewController {
 
 override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
 
 // the jobs is selected
 if indexPath.section == 3 {
 
 let addJobTable = self.storyboard?.instantiateViewController(withIdentifier: "JobsTableViewController")
 
 }
 }
 }*/

extension SimpleTableViewController: UITextViewDelegate {
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        
        // since textview does not have a placeholder property, we programtically added one
        if textView.textColor == UIColor.lightGray {
            
            textView.text = nil
            textView.textColor = UIColor.black
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        
        // set the correct placeholder for the correct view
        if textView.text.isEmpty {
            
            textView.text = "Event description"
            textView.textColor = UIColor.lightGray
        }
    }
}

extension SimpleTableViewController: UINavigationControllerDelegate ,UIImagePickerControllerDelegate {
    
    // when the user is done picking their image, it is set as the official event image
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            
            eventImageView.image = image
        } else {
            
            
        }
        
        self.dismiss(animated: true, completion: nil)
    }
}

