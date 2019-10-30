//
//  EventViewController.swift
//  Virtue
//
//  Created by Ruohan Ding on 1/6/18.
//  Copyright © 2018 Ding. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth
import FirebaseStorage

class EventViewController: UIViewController {
    
    @IBOutlet weak var eventName: UILabel!
    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var friendsScrollView: UIScrollView!
    @IBOutlet weak var profileName: UILabel!
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var eventImage: UIImageView!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var availableLabel: UILabel!
    @IBOutlet weak var descriptionText: UITextView!
    @IBOutlet weak var locationLabel: UILabel!
    
    var creatorInfo: UserInfo!
    var eventInfo: EventInfo!
    var dataRef : DatabaseReference!
    var storageRef: StorageReference!
    var storage: Storage!
    var allUsersArray = [UserInfo]()
    let dateFormatter = DateFormatter()
    let timeFormatter = DateFormatter()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let profileImageUrl = creatorInfo.userProfilePicURL!
        let eventImageUrl = eventInfo.eventImageURL!
        
        storage = Storage.storage()
        dataRef = Database.database().reference()
        
        eventName.text = eventInfo.eventName
        profileName.text = creatorInfo.userName!
        profileImage.layer.borderWidth = 1
        profileImage.layer.masksToBounds = false
        profileImage.layer.cornerRadius = profileImage.frame.height/2
        profileImage.clipsToBounds = true
        eventImage.layer.cornerRadius = 8
        
        // temp fix for location, need to mind how to format location
        locationLabel.text = eventInfo.eventLocation.replacingOccurrences(of: ", United States", with: "")
        
        dateFormatter.dateFormat = "E, MMM d"
        timeFormatter.dateFormat = "h:mm a"
        timeFormatter.amSymbol = "AM"
        timeFormatter.pmSymbol = "PM"
        
        // sets up profile image
        self.storage.reference(forURL: profileImageUrl).getData(maxSize: 1 * 1024 * 1024) { (data, error) in
            if let error = error {
                print(error)
            } else {
                self.profileImage.image = UIImage(data: data!)
            }
        }
        
        // sets up event image
        self.storage.reference(forURL: eventImageUrl).getData(maxSize: 1 * 1024 * 1024) { (data, error) in
            if let error = error {
                print(error)
            } else {
                self.eventImage.image = UIImage(data: data!)
            }
        }
        
        // sets up the availablility
        availableLabel.text = "\(eventInfo.eventAvailability!) Spots Available"
        
//        // sets up time
//        dateFormatter.dateFormat = "E, MMM d"
//        let startDate = Date(timeIntervalSince1970: eventInfo.eventStartDate)
//        let endDate = Date(timeIntervalSince1970: eventInfo.eventEndDate)
//        let formatStartDate = dateFormatter.string(from: startDate)
//        let formatEndDate = dateFormatter.string(from: endDate)
//        timeLabel.text = "\(formatStartDate) \(formatEndDate)"
        
        // sets up date and time
        let startDate = Date(timeIntervalSince1970: eventInfo.eventStartDate)
        let endDate = Date(timeIntervalSince1970: eventInfo.eventEndDate)
        let startTimeString = timeFormatter.string(from: startDate)
        let endTimeString = timeFormatter.string(from: endDate)
        
        dateLabel.text = dateFormatter.string(from: startDate)
        if startTimeString.suffix(2) == endTimeString.suffix(2){
            timeLabel.text = "\(startTimeString.dropLast(2))- \(endTimeString)"
        } else {
            timeLabel.text = "\(startTimeString) - \(endTimeString)"
        }
        
        // sets up event descrption
        descriptionText.text = eventInfo.eventDescription!
        descriptionText.sizeToFit()
        
        signUpButton.layer.cornerRadius = 6
        cancelButton.layer.cornerRadius = 6
        cancelButton.isHidden = true
        
        // tests to see if the event is created by the current user
        var eventKey = false
        for (_, value) in UserInfo.shared.userCreatedEventNames {
            if value == eventInfo.eventName {
                eventKey = true
            }
        }
        
        if eventKey {
            // created by current user
            signUpButton.isEnabled = false
            signUpButton.backgroundColor = UIColor.gray
            self.signUpButton.isHidden = false
            self.cancelButton.isHidden = true
        } else {
            // not created by current user
            // tests to see if the user has already signed up for this shift
            let userID = Auth.auth().currentUser!.uid
            let eventID = eventInfo.eventID!
            
            let eventDataRef = dataRef.child("/users/\(userID)/userSignedUpEvents/\(eventID)/")
            
            eventDataRef.observeSingleEvent(of: .value, with: { (snapshot) in
                
                if let value = snapshot.value as? String {
                    
                    if value == self.eventInfo.eventName {
                        // signed up
                        self.signUpButton.isEnabled = false
                        self.signUpButton.backgroundColor = UIColor.gray
                        self.signUpButton.isHidden = true
                        // set up cancel
                        self.cancelButton.isHidden = false
                    } else {
                        
                        self.signUpButton.isEnabled = true
                        self.signUpButton.backgroundColor = UIColor.black
                        self.signUpButton.isHidden = false
                        self.cancelButton.isHidden = true
                    }
                } else {
                    self.signUpButton.isEnabled = true
                    self.signUpButton.backgroundColor = UIColor.black
                    self.signUpButton.isHidden = false
                    self.cancelButton.isHidden = true
                }
            })
        }
        
        self.refreshFriends()
    }

    @IBAction func signUpClicked(_ sender: UIButton) {
        
        let userID = Auth.auth().currentUser!.uid
        let eventID = eventInfo.eventID!
        
        eventInfo.eventAvailability! -= 1
        availableLabel.text = "\(eventInfo.eventAvailability!) Spots Available"
        
        let userChildUpdates = ["/users/\(userID)/userSignedUpEvents/\(eventID)/" : eventInfo.eventName!]
        let eventChildUpdates = ["/allEvents/\(eventID)/allUserSignedUP/\(userID)/": UserInfo.shared.userName!]
        let availabilityChildUpdate = ["/allEvents/\(eventID)/eventAvilability/": "\(eventInfo.eventAvailability!)"]
        self.dataRef.updateChildValues(userChildUpdates)
        self.dataRef.updateChildValues(eventChildUpdates)
        self.dataRef.updateChildValues(availabilityChildUpdate)
        
        signUpButton.isEnabled = false
        signUpButton.backgroundColor = UIColor.gray
        self.signUpButton.isHidden = true
        self.cancelButton.isHidden = false
    }
    
    @IBAction func cancelClicked(_ sender: Any) {
        let userID = Auth.auth().currentUser!.uid
        let eventID = eventInfo.eventID!
        
        eventInfo.eventAvailability! += 1
        availableLabel.text = "\(eventInfo.eventAvailability!) Spots Available"
        
        self.dataRef.child("/users/\(userID)/userSignedUpEvents/\(eventID)/").removeValue()
        self.dataRef.child("/allEvents/\(eventID)/allUserSignedUP/\(userID)/").removeValue()
        let availabilityChildUpdate = ["/allEvents/\(eventID)/eventAvilability/": "\(eventInfo.eventAvailability!)"]
        self.dataRef.updateChildValues(availabilityChildUpdate)
        
        self.signUpButton.isEnabled = true
        self.signUpButton.backgroundColor = UIColor.black
        self.signUpButton.isHidden = false
        self.cancelButton.isHidden = true
    }
    
    func refreshFriends(){
        
        // reads all the users that have signed up
        let signedUpUsersRef = dataRef.child("/allEvents/\(eventInfo.eventID!)/allUserSignedUP/")
        signedUpUsersRef.observeSingleEvent(of: .value, with: { (snapshot) in
            
            if let usersDict = snapshot.value as? [String: String] {
                
                // displays all the people that have signed up for this event
                let keysArray = Array(usersDict.keys)
                let i = usersDict.count - 1
                for z in 0...i {
                    
                    let scrollViewHeight = (self.friendsScrollView.frame.height) - 30
                    let friendImage = UIImageView(frame: CGRect.init(x: CGFloat((10*z)+(80*z)+10), y: 0, width: scrollViewHeight, height: scrollViewHeight))
                    // makes a circle profile pic and sets it to a placeholder
                    friendImage.layer.borderWidth = 1
                    friendImage.layer.masksToBounds = false
                    friendImage.layer.cornerRadius = friendImage.frame.height/2
                    friendImage.clipsToBounds = true
                    
                    let friendName = UILabel.init(frame: CGRect.init(x: CGFloat((10*z)+(80*z)+5), y: scrollViewHeight + 3, width: scrollViewHeight + 15, height: 20))
                    friendName.textAlignment = .center
                    friendName.font = UIFont.systemFont(ofSize: 13.0)
                    friendName.lineBreakMode = .byCharWrapping
                    
                    self.friendsScrollView.addSubview(friendImage)
                    self.friendsScrollView.addSubview(friendName)
                    
                    self.dataRef.child("users").child(keysArray[z]).observeSingleEvent(of: .value, with: { (snapshot) in
                        
                        let values = snapshot.value as? NSDictionary
                        
                        let userType = values?["userType"] as? String ?? ""
                        let userName = values?["name"] as? String ?? ""
                        let imageURL = values?["profileImageURL"] as? String ?? ""
                        let userCreatedEvents = values?["userCreatedEvents"] as? [String: String] ?? ["":""]
                        let userSignedUpEvents = values?["userSignedUpEvents"] as? [String: String] ?? ["":""]
                        
                        self.storage.reference(forURL: imageURL).getData(maxSize: 1 * 1024 * 1024) { (data, error) in
                            if let error = error {
                                print(error)
                            } else {
                                friendImage.image = UIImage(data: data!)
                            }
                        }
                        let nameArray = userName.split(separator: " ")
                        friendName.text = String(nameArray[0])
                        
                        let userInfo = UserInfo(type: userType, name: userName, profileURL: imageURL, userEvents: userCreatedEvents, signedUp: userSignedUpEvents)
                        self.allUsersArray.append(userInfo)
                    })
                }
                
                self.friendsScrollView.contentSize = CGSize(width: (90*i), height: 80)
            }
        })
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

