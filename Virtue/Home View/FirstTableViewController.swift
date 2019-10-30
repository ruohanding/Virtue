//
//  FirstViewController.swift
//  Virtue(Placeholder)
//
//  Created by Ruohan Ding on 4/12/17.
//  Copyright © 2017 Ding. All rights reserved.
//

import UIKit
import FirebaseStorage
import FirebaseDatabase
import FirebaseAuth

class FirstTableViewController: UITableViewController{
    // This view is basically the "home page", it shows all the opportunities that poeple can sign up for
    
    var localEventInfoArray = [EventInfo]()
    var databaseRef: DatabaseReference!
    var databaseHandle: DatabaseHandle!
    var availabilityHandle: DatabaseHandle!
    var storageRef: StorageReference!
    var userInfo = UserInfo.shared
    var eventInfoArray = EventInfoArray.shared
    var sortType = "soonestFirst"
    var activityIndicator = UIActivityIndicatorView()
    let dateFormatter = DateFormatter()
    let timeFormatter = DateFormatter()
    
    typealias completionHandler = (_ success:Bool) -> Void
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // sets up nav bar
        self.navigationController?.navigationBar.shadowImage = UIColor.groupTableViewBackground.imageFromColor()
        // back button
        self.navigationController?.navigationBar.backIndicatorImage = UIImage(named: "Back-Black")?.withRenderingMode(.alwaysOriginal)
        self.navigationController?.navigationBar.backIndicatorTransitionMaskImage = UIImage(named: "Back")?.withRenderingMode(.alwaysOriginal)
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        
        let tableImageView = FirstTableImageView.instanceFromNib()
        tableView.backgroundView = tableImageView
        tableView.separatorStyle = .none
        tableView.backgroundView?.isHidden = true
        
        dateFormatter.dateFormat = "E, MMM d"
        timeFormatter.dateFormat = "h:mm a"
        timeFormatter.amSymbol = "AM"
        timeFormatter.pmSymbol = "PM"
        
        databaseRef = Database.database().reference()
        storageRef = Storage.storage().reference()
        
        //let button = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(FirstTableViewController.sortPressed))
        
        let sortButton = UIButton.init(type: .custom)
        sortButton.setImage(UIImage(named: "FirstSortOutline"), for: .normal)
        sortButton.addTarget(self, action: #selector(FirstTableViewController.sortPressed), for: .touchUpInside)
        sortButton.adjustsImageWhenHighlighted = false
        sortButton.frame = CGRect(x: 0, y: 0, width: 28, height: 28)
        
        let leftBarButton = UIBarButtonItem(customView: sortButton)
        self.navigationItem.leftBarButtonItem = leftBarButton
        
        let logoView = UIImageView(frame: CGRect(x: 0, y: 0, width: 38, height: 28))
        logoView.contentMode = .scaleAspectFit
        logoView.image = UIImage(named: "Logo-Invert")
        
        self.navigationItem.titleView = logoView
        
//        self.getAllEvents(Completion: { (success) -> Void in
//            if success {
//
//                self.sort()
//                self.endLoading()
//                self.tableView.backgroundView?.isHidden = true
//            }
//        })
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        self.navigationController?.navigationBar.setBackgroundImage(UIColor.white.imageFromColor(), for: .default)
        UIApplication.shared.statusBarStyle = .default
        if eventInfoArray.allEventsArray.count <= 0 {
            self.getAllEvents(Completion: { (success) -> Void in
                if success {
                    
                    self.sort()
                    self.endLoading()
                    self.tableView.backgroundView?.isHidden = true
                }
            })
        }
        
        for i in 0..<localEventInfoArray.count {
            let availRef = databaseRef.child("/allEvents/\(localEventInfoArray[i].eventID)/eventAvilability/")
            availabilityHandle = availRef.observe(.childChanged, with: { (snapshot) in
                let availNumber = snapshot.value as! Int
                self.localEventInfoArray[i].eventAvailability = availNumber
            })
        }
        tableView.reloadData()
    }
    
    @objc func sortPressed(){
        
        let sortViewController = self.storyboard?.instantiateViewController(withIdentifier: "SortPopoverViewController") as! SortPopoverViewController
        
        self.present(sortViewController, animated: true, completion: nil)
    }
    
    func sort() {
        
        switch self.sortType {
        case "soonestFirst":
            self.soonestFirst()
            break
        case "latestFirst":
            self.latestFirst()
            break
        case "longestFirst":
            self.longestFirst()
            break
        case "shortestFirst":
            self.shortestFirst()
            break
        default:
            print("Something went wrong")
            break
        }
    }
    
    func getAllEvents(Completion: @escaping completionHandler) {
        
        self.startLoading()
        self.localEventInfoArray = [EventInfo]()
        self.eventInfoArray.allEventsArray = [EventInfo]()
        let eventRef = databaseRef.child("allEvents")
        // .childAdded means that it gets called for every individual child already inside of this child and any future ones that are added
        
        databaseRef.observeSingleEvent(of: .value, with: { (snapshot) in
            
            if !snapshot.hasChild("allEvents"){
                
                self.tableView.backgroundView?.isHidden = false
                self.endLoading()
            }
        })
        
        databaseHandle = eventRef.observe(.childAdded, with: { (snapshot) in
            // creates an dictionary of all the values in allEvents
            if let eventDict = snapshot.value as? [String: Any] {
                
                // getting all the event values
                let eventCreator = eventDict["eventCreatorUID"] as! String
                let eventID = eventDict["eventID"] as! String
                let eventName = eventDict["eventName"] as! String
                let eventDescription = eventDict["eventDescription"] as! String
                let eventEndDate = eventDict["eventEndDate"] as! Double
                let eventStartDate = eventDict["eventStartDate"] as! Double
                let eventLocation = eventDict["eventLocation"] as! String
                let eventImageURL = eventDict["eventImageURL"] as! String
                let eventImageID = eventDict["eventImageID"] as! String
                let eventType = eventDict["eventType"] as! String
                let eventActive = eventDict["active"] as! Bool
                var eventAvailiability = 0
                
                if eventType == "complex" {
                    // getting all the jobs values
                    var shortestInterval: TimeInterval = 0
                    var longestInterval: TimeInterval = 0
                    let allJobsOfEventDict = eventDict["allJobsOfEvent"] as! [String: Any]
                    let allShiftsOfEventDict = eventDict["allShiftsOfEvent"] as! [String: Any]
                    var jobInfoDictWithJobName = [String: JobInfo]()
                    
                    for (jobNumber, singleJobDataAny) in allJobsOfEventDict{
                        
                        let singleJobDataDict = singleJobDataAny as! [String: Any]
                        
                        let jobInfo = JobInfo()
                        
                        let jobDescription = singleJobDataDict["jobDescription"] as! String
                        let jobMultShifts = singleJobDataDict["jobMultipleShiftsAllowed"] as! Bool
                        let jobName = singleJobDataDict["jobName"] as! String
                        
                        jobInfo.jobName = jobName
                        jobInfo.jobDescription = jobDescription
                        jobInfo.multipleShiftsAllowed = jobMultShifts
                        
                        jobInfoDictWithJobName[jobNumber] = jobInfo
                    }
                    
                    // getting all the shift values
                    var shiftInfoArrayDictWithJobName = [String:[ShiftInfo]]()
                
                    for (jobNumber,allShiftsOfJobAny) in allShiftsOfEventDict{
                        
                        var shiftInfoArray = [ShiftInfo]()
                        let allShiftsOfJobDict = allShiftsOfJobAny as! [String: Any]
                        for(_, singleShiftDataAny) in allShiftsOfJobDict {
                            
                            let singleShiftDataDict = singleShiftDataAny as! [String: Any]
                            
                            let shiftEndTime = singleShiftDataDict["shiftEndTime"] as! Double
                            let shiftStartTime = singleShiftDataDict["shiftStartTime"] as! Double
                            let startDate = Date(timeIntervalSince1970: shiftStartTime)
                            let endDate = Date(timeIntervalSince1970: shiftEndTime)
                            let shiftInterval = endDate.timeIntervalSince(startDate)
                            let shiftPeopleNum = Int(singleShiftDataDict["shiftPeopleNum"] as! String)
                            eventAvailiability += shiftPeopleNum!
                            
                            if (shortestInterval == 0) {
                                shortestInterval = shiftInterval
                            } else if (shiftInterval < shortestInterval){
                                shortestInterval = shiftInterval
                            }
                            
                            if (longestInterval == 0){
                                longestInterval = shiftInterval
                            } else if (shiftInterval > longestInterval){
                                longestInterval = shiftInterval
                            }
                         
                            let shiftInfo = ShiftInfo(startDate: shiftStartTime, endDate: shiftEndTime, interval: shiftInterval,  peopleNum: shiftPeopleNum!)
                            shiftInfoArray.append(shiftInfo)
                        }
                        
                        shiftInfoArrayDictWithJobName[jobNumber] = shiftInfoArray
                    }
                    // setting all the job shifts
                    var jobInfoArray = [JobInfo]()
                    for (jobNumber, _) in allJobsOfEventDict{
                        
                        let jobInfoForJobNumber = jobInfoDictWithJobName[jobNumber]
                        jobInfoForJobNumber?.shiftArray = shiftInfoArrayDictWithJobName[jobNumber]
                        
                        jobInfoArray.append(jobInfoForJobNumber!)
                    }
                
                    // setting all the event data
                    let eventInfo = EventInfo(creator: eventCreator, ID: eventID, name: eventName, imageURL: eventImageURL, imageID: eventImageID,description: eventDescription, startDate: eventStartDate, endDate: eventEndDate, longest: longestInterval, shortest: shortestInterval, location: eventLocation, availability: eventAvailiability, type: eventType, active: eventActive, jobs: jobInfoArray)
                    // the shared array needs them all but the local one only needs the active ones
                    if eventActive{
                        self.localEventInfoArray.append(eventInfo)
                    }
                    self.eventInfoArray.allEventsArray.append(eventInfo)
                } else {
                    
                    eventAvailiability = Int(eventDict["eventAvilability"] as! String)!
                    let startDate = Date(timeIntervalSince1970: eventStartDate)
                    let endDate = Date(timeIntervalSince1970: eventEndDate)
                    let interval = endDate.timeIntervalSince(startDate)
                    
                    let eventInfo = EventInfo(creator: eventCreator, ID: eventID, name: eventName, imageURL: eventImageURL, imageID: eventImageID,description: eventDescription, startDate: eventStartDate, endDate: eventEndDate, longest: interval, shortest: interval, location: eventLocation, availability: eventAvailiability, type: eventType, active: eventActive)
                    
                    if eventActive{
                        self.localEventInfoArray.append(eventInfo)
                    }
                    self.eventInfoArray.allEventsArray.append(eventInfo)
                }
            }
            Completion(true)
        }) { (error) in
            
            self.endLoading()
            print(error.localizedDescription)
        }
    }
    
    func soonestFirst(){
        
        // this shit sorts the the array by date
        localEventInfoArray = localEventInfoArray.sorted (by: { $0.eventStartDate < $1.eventStartDate })
        let sharedArray = eventInfoArray.allEventsArray!
        eventInfoArray.allEventsArray = sharedArray.sorted (by: { $0.eventStartDate < $1.eventStartDate })
        
        self.tableView.reloadData()
    }
    
    func latestFirst(){
        
        // this shit sorts the the array by date
        localEventInfoArray = localEventInfoArray.sorted (by: { $1.eventStartDate < $0.eventStartDate })
        
        self.tableView.reloadData()
    }
    
    func shortestFirst(){
        localEventInfoArray = localEventInfoArray.sorted (by: { $0.eventShortest < $1.eventShortest })
        
        self.tableView.reloadData()
    }
    
    func longestFirst(){
        localEventInfoArray = localEventInfoArray.sorted (by: { $0.eventLongest > $1.eventLongest })
        
        self.tableView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func startLoading() {
        // creats an activity indicator and sets it to the middle of the screen and makes it grey
        activityIndicator.center = self.view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.activityIndicatorViewStyle = .gray
        view.addSubview(activityIndicator)
        self.view.bringSubview(toFront: activityIndicator)
        
        activityIndicator.startAnimating()
        // ignores all evens
        UIApplication.shared.beginIgnoringInteractionEvents()
    }
    
    func endLoading() {
        
        activityIndicator.stopAnimating()
        UIApplication.shared.endIgnoringInteractionEvents()
    }
}

extension FirstTableViewController {
    
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "firstViewCell") as! OpportunityTableViewCell
        
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

class FirstTableImageView: UIView {
    
    class func instanceFromNib() -> UIView {
        return UINib(nibName: "FirstTableImageView", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! UIView
    }
}
/*@IBAction func goBackButton(_ sender: UIButton) {
 This is a temp button made for edititng faster, all it does is push the intro view controller on top, delete later
 let storyboard = UIStoryboard(name: "Main", bundle: nil)
 let introViewController = storyboard.instantiateViewController(withIdentifier: "IntroNavigationViewController") as! IntroNavigationViewController
 self.present(introViewController, animated: true, completion: nil)
 } */
