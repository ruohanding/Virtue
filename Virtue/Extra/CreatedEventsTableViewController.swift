//
//  CreatedEventsTableViewController.swift
//  Virtue
//
//  Created by Ruohan Ding on 10/14/17.
//  Copyright © 2017 Ding. All rights reserved.
//

import UIKit
import FirebaseStorage
import FirebaseDatabase
import FirebaseAuth

class CreatedEventsTableViewController: UITableViewController{
    
    let eventInfoArray = EventInfoArray.shared
    var localEventInfoArray = [EventInfo]()
    var createdEvents = [String]()
    var databaseRef: DatabaseReference!
    var databaseHandle: DatabaseHandle!
    var storageRef: StorageReference!
    var userInfo : UserInfo!
    let dateFormatter = DateFormatter()
    typealias completionHandler = (_ success:Bool) -> Void
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        databaseRef = Database.database().reference()
        storageRef = Storage.storage().reference()
        userInfo = UserInfo.shared
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        userInfo = UserInfo.shared
        
        createdEvents = Array(userInfo.userSignedUpEvents.keys)
        
        self.getCorrectEvents(Completion: { (success) -> Void in
            if success {
                self.tableView.reloadData()
            }
        })
    }
    
    func getCorrectEvents(Completion: @escaping completionHandler) {
        
        for event in eventInfoArray.allEventsArray {
            // only adds the event if the user created it
            if createdEvents.contains(event.eventID){
                localEventInfoArray.append(event)
            }
        }
        
        Completion(true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension CreatedEventsTableViewController {
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return localEventInfoArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "createdViewCell") as! OpportunityTableViewCell
        
        // sets all the necessary infomation for the opportunity cell
        let eventInfo = localEventInfoArray[indexPath.row]
        
        self.setEventPic(cell: cell, eventInfo: eventInfo)
        self.setProfilePic(cell: cell, eventInfo: eventInfo)
        
        cell.eventInfo = eventInfo
        cell.eventName.text = eventInfo.eventName!
        cell.eventDay.text = "\(eventInfo.eventStartDate!) - \(eventInfo.eventEndDate!)"
        //cell.eventLocation.text = eventInfo.eventLocation!
        cell.eventAvailability.text = "\(eventInfo.eventAvailability!) spots available"
        
        return cell
    }
    
    func setEventPic(cell: OpportunityTableViewCell, eventInfo: EventInfo) {
        
        // sets the eventImage
        if let eventImageID = eventInfo.eventImageID {
            let eventImageRef = storageRef.child("event_image/\(eventImageID)")
            
            eventImageRef.getData(maxSize: 1 * 1024 * 1024) { data, error in
                if let error = error {
                    
                    print(error)
                } else {
                    
                    cell.contentPic.image = UIImage(data: data!)
                }
            }
        }
    }
    
    func setProfilePic(cell: OpportunityTableViewCell, eventInfo: EventInfo) {
        
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
            // gets the user poster's data and sets it
            if let userDict = snapshot.value as? [String: Any] {
                
                let profileName = userDict["name"]
                
                cell.profileName.text = profileName! as? String
            }
        })
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return 211.0
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! OpportunityTableViewCell
        
        // gives the correct view dependign on the event type
        let eventType = cell.eventInfo.eventType
        
        if(eventType == "simple"){
            
            let simpleEventInfoViewController = self.storyboard?.instantiateViewController(withIdentifier: "SimpleEventInfoViewController") as! SimpleEventInfoViewController
            simpleEventInfoViewController.eventInfo = cell.eventInfo
            self.navigationController?.pushViewController(simpleEventInfoViewController, animated: true)
        } else {
            
            let eventInfoViewController = self.storyboard?.instantiateViewController(withIdentifier: "EventInfoViewController") as! EventInfoViewController
            
            eventInfoViewController.eventInfo = cell.eventInfo
            self.navigationController?.pushViewController(eventInfoViewController, animated: true)
        }
    }
}
