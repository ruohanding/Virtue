//
//  ProfileTableViewController.swift
//  
//
//  Created by Ruohan Ding on 1/27/18.
//

import UIKit
import FirebaseStorage
import FirebaseDatabase
import FirebaseAuth

class ProfileTableViewController: UITableViewController {
    
    var localEventInfoArray = [EventInfo]()
    var createdEvents = [String]()
    var signedUpEvents = [String]()
    var databaseRef: DatabaseReference!
    var databaseHandle: DatabaseHandle!
    var storageRef: StorageReference!
    var userInfo : UserInfo!
    var activityIndicator = UIActivityIndicatorView()
    var dataType = ""
    var eventInfoArray : EventInfoArray!
    var parentView : FifthViewController!
    let dateFormatter = DateFormatter()
    let timeFormatter = DateFormatter()
    
    typealias completionHandler = (_ success:Bool) -> Void
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        databaseRef = Database.database().reference()
        storageRef = Storage.storage().reference()
        userInfo = UserInfo.shared
        eventInfoArray = EventInfoArray.shared
        parentView = storyboard?.instantiateViewController(withIdentifier: "FifthViewController") as! FifthViewController
        
        let tableImageView = FirstTableImageView.instanceFromNib()
        tableView.backgroundView = tableImageView
        tableView.separatorStyle = .none
        tableView.backgroundView?.isHidden = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        userInfo = UserInfo.shared
        eventInfoArray = EventInfoArray.shared
        
        signedUpEvents = Array(userInfo.userSignedUpEvents.keys)
        createdEvents = Array(userInfo.userCreatedEventNames.keys)
        
        dateFormatter.dateFormat = "E, MMM d"
        timeFormatter.dateFormat = "h:mm a"
        timeFormatter.amSymbol = "AM"
        timeFormatter.pmSymbol = "PM"
        
        self.getCorrectEvents(Completion: { (success) -> Void in
            if success {
                self.tableView.reloadData()
                if self.localEventInfoArray.isEmpty{
                    self.tableView.backgroundView?.isHidden = false
                }
            }
        })
    }
    
    func getCorrectEvents(Completion: @escaping completionHandler) {
        
        localEventInfoArray = [EventInfo]()
        
        for event in eventInfoArray.allEventsArray {
            if dataType == "active"{
                // only adds the event if the user is signed up to the event and its active it
                if (signedUpEvents.contains(event.eventID)) && (event.eventActive) {
                    localEventInfoArray.append(event)
                }
            } else if dataType == "completed"{
                // only adds the event if the user is signed up to the event and it isn't it
                if (signedUpEvents.contains(event.eventID)) && !(event.eventActive) {
                    localEventInfoArray.append(event)
                }
            } else if dataType == "created"{
                // only adds the event if the user created it
                if createdEvents.contains(event.eventID){
                    localEventInfoArray.append(event)
                }
            } else {
                print("Error in dataType (ProfileTableViewController")
            }
            
        }
        Completion(true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension ProfileTableViewController {
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        
        if localEventInfoArray.count <= 0 {
            
            return 0
        }
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return localEventInfoArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "profileViewCell") as! OpportunityTableViewCell
        
        // sets all the necessary infomation for the opportunity cell
        let eventInfo = localEventInfoArray[indexPath.row]
        
        self.setEventPic(cell: cell, eventInfo: eventInfo)
        self.setCreatorInfo(cell: cell, eventInfo: eventInfo)
        
        let startDate = Date(timeIntervalSince1970: eventInfo.eventStartDate)
        let endDate = Date(timeIntervalSince1970: eventInfo.eventEndDate)
        
        cell.eventInfo = eventInfo
        cell.eventName.text = eventInfo.eventName!
        cell.eventDay.text = dateFormatter.string(from: startDate)
        //cell.eventLocation.text = eventInfo.eventLocation!
        cell.eventAvailability.text = "\(eventInfo.eventAvailability!) spots available"
        
        let startTimeString = timeFormatter.string(from: startDate)
        let endTimeString = timeFormatter.string(from: endDate)
        
        if startTimeString.suffix(2) == endTimeString.suffix(2){
            cell.eventTime.text = "\(startTimeString.dropLast(2))- \(endTimeString)"
        } else {
            cell.eventTime.text = "\(startTimeString) - \(endTimeString)"
        }
        
        return cell
    }
    
    func setEventPic(cell: OpportunityTableViewCell, eventInfo: EventInfo) {
        
        // sets the eventImage
        let eventImageID = eventInfo.eventImageID!
        let eventImageRef = storageRef.child("event_image/\(eventImageID)")
        
        eventImageRef.getData(maxSize: 1 * 1024 * 1024) { data, error in
            if let error = error {
                
                print(error)
            } else {
                
                cell.contentPic.image = UIImage(data: data!)
            }
        }
    }
    
    func setCreatorInfo(cell: OpportunityTableViewCell, eventInfo: EventInfo) {
        
        let creatorUID = eventInfo.eventCreator
        let userRef = databaseRef.child("users").child(creatorUID!)
        let profileImageRef = storageRef.child("profile_image/\(creatorUID!)")
        
        profileImageRef.getData(maxSize: 1 * 1024 * 1024) { data, error in
            if let error = error {
                
                print(error)
            } else {
                cell.profilePic.image = UIImage(data: data!)
            }
        }
        
        userRef.observeSingleEvent(of: .value, with: { (snapshot) in
            let values = snapshot.value as? NSDictionary
            
            let userType = values?["userType"] as? String ?? ""
            let userName = values?["name"] as? String ?? ""
            let profileImageURL = values?["profileImageURL"] as? String ?? ""
            let userCreatedEvents = values?["userCreatedEvents"] as? [String: String] ?? ["":""]
            let userSignedUpEvents = values?["userSignedUpEvents"] as? [String: String] ?? ["":""]
            
            cell.creatorInfo = UserInfo(type: userType, name: userName, profileURL: profileImageURL, userEvents: userCreatedEvents, signedUp: userSignedUpEvents)
            cell.profileName.text = userName
        }) { (error) in
            print(error.localizedDescription)
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return 280.0
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! OpportunityTableViewCell
        
        // gives the correct view dependign on the event type
        let eventType = cell.eventInfo.eventType
        
        if(eventType == "simple"){
            
            let simpleEventInfoViewController = self.storyboard?.instantiateViewController(withIdentifier: "SimpleEventInfoViewController") as! SimpleEventInfoViewController
            simpleEventInfoViewController.eventInfo = cell.eventInfo
            simpleEventInfoViewController.creatorInfo = cell.creatorInfo
            self.navigationController?.pushViewController(simpleEventInfoViewController, animated: true)
        } else {
            
            let eventInfoViewController = self.storyboard?.instantiateViewController(withIdentifier: "EventInfoViewController") as! EventInfoViewController
            
            eventInfoViewController.eventInfo = cell.eventInfo
            self.navigationController?.pushViewController(eventInfoViewController, animated: true)
        }
    }
}
