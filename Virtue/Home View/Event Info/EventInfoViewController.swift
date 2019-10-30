//
//  EventInfoViewController.swift
//  Virtue
//
//  Created by Ruohan Ding on 9/3/17.
//  Copyright © 2017 Ding. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth

class EventInfoViewController: UIViewController {

    @IBOutlet weak var eventName: UILabel!
    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var friendsScrollView: UIScrollView!
    @IBOutlet weak var jobsTableView: UITableView!
    
    var eventInfo: EventInfo!
    var dataRef : DatabaseReference!
    var allUsersArray = [UserInfo]()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        jobsTableView.frame = CGRect(x: jobsTableView.frame.origin.x, y: jobsTableView.frame.origin.y, width:                               jobsTableView.frame.size.width, height: jobsTableView.contentSize.height)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        eventName.text = eventInfo.eventName
        
        dataRef = Database.database().reference()
        
        self.createdByUser()
        self.alreadySignedUp()
        self.setUpFriends()
        self.setUpSignUps()
    }
    
    @IBAction func signUpClicked(_ sender: UIButton) {
        
        let userID = Auth.auth().currentUser!.uid
        let eventID = eventInfo.eventID!
        
        let userChildUpdates = ["/users/\(userID)/userSignedUpEvents/\(eventID)/" : eventInfo.eventName!]
        self.dataRef.updateChildValues(userChildUpdates)
        
        let eventChildUpdates = ["/allEvents/\(eventID)/allUserSignedUP/\(userID)/": UserInfo.shared.userName!]
        self.dataRef.updateChildValues(eventChildUpdates)
        signUpButton.isEnabled = false
    }
    
    func createdByUser() {
        // tests to see if the event is created by the current user
        var eventKey = ""
        for (key, value) in UserInfo.shared.userCreatedEventNames {
            if value == eventInfo.eventName {
                eventKey = key
            }
        }
        
        if eventKey != "" {
            // created by current user
            signUpButton.isHidden = true
        } else {
            // not created by current user
            signUpButton.isHidden = false
        }
    }
    
    func alreadySignedUp() {
        // tests to see if the user has already signed up for this shift
        let userID = Auth.auth().currentUser!.uid
        let eventID = eventInfo.eventID!
        
        let eventDataRef = dataRef.child("/users/\(userID)/userSignedUpEvents/\(eventID)/")
        
        eventDataRef.observeSingleEvent(of: .value, with: { (snapshot) in
            
            if let value = snapshot.value as? String {
                
                if value == self.eventInfo.eventName {
                    
                    self.signUpButton.isEnabled = false
                } else {
                    
                    self.signUpButton.isEnabled = true
                }
            } else {
                self.signUpButton.isEnabled = true
            }
        })
    }

    func setUpFriends(){
        
        // reads all the users that have signed up
        let signedUpUsersRef = dataRef.child("/allEvents/\(eventInfo.eventID!)/allUserSignedUP/")
        signedUpUsersRef.observeSingleEvent(of: .value, with: { (snapshot) in
            
            if let usersDict = snapshot.value as? [String: String] {
                
                // displays all the people that have signed up for this event
                let keysArray = Array(usersDict.keys)
                let i = usersDict.count - 1
                for z in 0...i {
                    
                    let scrollViewHeight = self.friendsScrollView.frame.height
                    let imageOne = UIImageView(frame: CGRect.init(x: CGFloat((10*z)+(80*z)), y: 0, width: scrollViewHeight, height: scrollViewHeight))
                    // makes a circle profile pic and sets it to a placeholder
                    imageOne.layer.borderWidth = 1
                    imageOne.layer.masksToBounds = false
                    imageOne.layer.cornerRadius = imageOne.frame.height/2
                    imageOne.clipsToBounds = true
                    imageOne.image = UIImage(named: "1")
                    
                    self.friendsScrollView.addSubview(imageOne)
                    
                    self.dataRef.child("users").child(keysArray[z]).observeSingleEvent(of: .value, with: { (snapshot) in
                        
                        let values = snapshot.value as? NSDictionary
                        
                        let userType = values?["userType"] as? String ?? ""
                        let userName = values?["name"] as? String ?? ""
                        let profileImageURL = values?["profileImageURL"] as? String ?? ""
                        let userCreatedEvents = values?["userCreatedEvents"] as? [String: String] ?? ["":""]
                        let userSignedUpEvents = values?["userSignedUpEvents"] as? [String: String] ?? ["":""]
                        
                        let userInfo = UserInfo(type: userType, name: userName, profileURL: profileImageURL, userEvents: userCreatedEvents, signedUp: userSignedUpEvents)
                        self.allUsersArray.append(userInfo)
                    })
                }
                
                self.friendsScrollView.contentSize = CGSize(width: (90*i), height: 80)
            }
        })
    }
    
    func setUpSignUps(){
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

extension EventInfoViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = jobsTableView.dequeueReusableCell(withIdentifier: "signUpJobCell")!
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        let jobInfo = eventInfo.jobsArray[section]
        return jobInfo.shiftArray.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        return eventInfo.jobsArray.count
    }
    
    override func viewDidLayoutSubviews(){
        jobsTableView.frame = CGRect(x: jobsTableView.frame.origin.x, y: jobsTableView.frame.origin.y, width:                               jobsTableView.frame.size.width, height: jobsTableView.contentSize.height)
        jobsTableView.reloadData()
    }
}
