//
//  SecondViewController.swift
//  Virtue(Placeholder)
//
//  Created by Ruohan Ding on 4/12/17.
//  Copyright © 2017 Ding. All rights reserved.
//

import UIKit
import FirebaseStorage
import FirebaseDatabase
import FirebaseAuth

class SecondViewController: UIViewController {
    // This will be the search
    @IBOutlet weak var placeholderView: UIView!
    @IBOutlet weak var eventButton: UIButton!
    @IBOutlet weak var locationButton: UIButton!
    @IBOutlet weak var userButton: UIButton!
    @IBOutlet weak var nameBarView: UIView!
    @IBOutlet weak var userBarView: UIView!
    @IBOutlet weak var locationBarView: UIView!
    
    let dateFormatter = DateFormatter()
    let timeFormatter = DateFormatter()
    var allEvents = [EventInfo]()
    var allUsers = [UserInfo]()
    var filteredAllEvents = [Any]()
    var searchBar: UISearchBar!
    var searchController = UISearchController(searchResultsController: nil)
    var spvc: UIPageViewController!
    var eventViewController: UITableViewController!
    var locationViewController: UITableViewController!
    var userViewController: UITableViewController!
    var tableViewControllerArray: [UITableViewController]!
    var currentViewController: UITableViewController!
    var databaseRef: DatabaseReference!
    var databaseHandle: DatabaseHandle!
    var storageRef: StorageReference!
    var storage: Storage!
//    var eventDataArray = [String]()
//    var filteredEventDataArray = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        databaseRef = Database.database().reference()
        storageRef = Storage.storage().reference()
        storage = Storage.storage()
        
        allEvents = EventInfoArray.shared.allEventsArray
        
        dateFormatter.dateFormat = "E, MMM d"
        timeFormatter.dateFormat = "h:mm a"
        timeFormatter.amSymbol = "AM"
        timeFormatter.pmSymbol = "PM"
        
        // sets up nav bar
        self.navigationController?.navigationBar.shadowImage = UIColor.groupTableViewBackground.imageFromColor()
        // back button
        self.navigationController?.navigationBar.backIndicatorImage = UIImage(named: "Back-Black")?.withRenderingMode(.alwaysOriginal)
        self.navigationController?.navigationBar.backIndicatorTransitionMaskImage = UIImage(named: "Back")?.withRenderingMode(.alwaysOriginal)
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        
        //adds SearchPageViewController as a subview
        spvc = self.storyboard?.instantiateViewController(withIdentifier: "SearchPageViewController") as! UIPageViewController
        eventViewController = self.storyboard?.instantiateViewController(withIdentifier: "SearchByNameTableViewController") as! UITableViewController
        locationViewController = self.storyboard?.instantiateViewController(withIdentifier: "SearchByLocationTableViewController") as! UITableViewController
        userViewController = self.storyboard?.instantiateViewController(withIdentifier:"SearchForUserTableViewController") as! UITableViewController
        
        // sets the tableview's delegates and datasources to this view controller
        eventViewController.tableView.delegate = self
        eventViewController.tableView.dataSource = self
        eventViewController.tableView.tableFooterView = UIView()
        locationViewController.tableView.delegate = self
        locationViewController.tableView.dataSource = self
        locationViewController.tableView.tableFooterView = UIView()
        userViewController.tableView.delegate = self
        userViewController.tableView.dataSource = self
        userViewController.tableView.tableFooterView = UIView()
        
        // sets the pageViewController
        spvc.dataSource = self
        spvc.delegate = self
        spvc.view.frame = placeholderView.frame
        tableViewControllerArray = [eventViewController, userViewController, locationViewController]
        
        spvc.setViewControllers([eventViewController],
                                direction: .forward,
                                animated: true,
                                completion: nil)
        
        self.addChildViewController(spvc)
        self.view.addSubview(spvc.view)
        spvc.didMove(toParentViewController: self)
        
        currentViewController = eventViewController
        eventButton.isEnabled = false
        locationButton.isEnabled = true
        userButton.isEnabled = true
        locationBarView.isHidden = true
        userBarView.isHidden = true
        nameBarView.isHidden = false
        eventButton.titleLabel!.font = UIFont.boldSystemFont(ofSize: 15.0)
        
        // all of the initial search bar settings are set for eventName because that is the first view on
        // adds a search bar
        //These are just some setting tweks
        searchController.searchResultsUpdater = self
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.dimsBackgroundDuringPresentation = false
        definesPresentationContext = true
        
        searchBar = searchController.searchBar
        searchBar.sizeToFit()
        searchBar.placeholder = "Search for a event name"
        searchBar.searchBarStyle = .default
        
        // changes the search bar's text field's background color
        let textFieldInsideSearchBar = searchBar.value(forKey: "searchField") as? UITextField
        textFieldInsideSearchBar!.backgroundColor = UIColor.groupTableViewBackground
        
        navigationItem.titleView = searchController.searchBar
        
        //self.getAllEvent(type: "eventName")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        searchController.searchBar.becomeFirstResponder()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        // since search bar is bigger, black bar appears under nav bar. This basically refreshes the nav bar thus getting rid of black bar                                                                                                      
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    @IBAction func eventButtonClicked(_ sender: UIButton) {
        
        spvc.setViewControllers([eventViewController], direction: .reverse, animated: true, completion: nil)
        // sets the view to the right search controller
        currentViewController = eventViewController
        
        filteredAllEvents = []
        eventViewController.tableView.reloadData()
        // clears the data in the tableveiw and the data array
        
        searchBar.placeholder = "Search for a event name"
        // resets the dataarray with the corresponding type of data
        //self.getAllEvent(type: "eventName")
        
        eventButton.isEnabled = false
        locationButton.isEnabled = true
        userButton.isEnabled = true
        locationBarView.isHidden = true
        userBarView.isHidden = true
        nameBarView.isHidden = false
        eventButton.titleLabel!.font = UIFont.boldSystemFont(ofSize: 15.0)
        userButton.titleLabel!.font = UIFont.systemFont(ofSize: 15.0)
        locationButton.titleLabel!.font = UIFont.systemFont(ofSize: 15.0)
    }

    @IBAction func locationButtonClicked(_ sender: UIButton) {
        spvc.setViewControllers([locationViewController], direction: .forward, animated: true, completion: nil)
        // sets the view to the right search controller
        currentViewController = locationViewController
        
        filteredAllEvents = []
        locationViewController.tableView.reloadData()
        // clears the data in the tableveiw and the data array
       
        searchBar.placeholder = "Search for a event location"
        // resets the dataarray with the corresponding type of data
        //self.getAllEvent(type: "eventLocation")
        
        eventButton.isEnabled = true
        locationButton.isEnabled = false
        userButton.isEnabled = true
        locationBarView.isHidden = false
        userBarView.isHidden = true
        nameBarView.isHidden = true
        locationButton.titleLabel!.font = UIFont.boldSystemFont(ofSize: 15.0)
        userButton.titleLabel!.font = UIFont.systemFont(ofSize: 15.0)
        eventButton.titleLabel!.font = UIFont.systemFont(ofSize: 15.0)
    }
    @IBAction func userButtonClicked(_ sender: Any) {
        if currentViewController == eventViewController {
            spvc.setViewControllers([userViewController], direction: .forward, animated: true, completion: nil)
        } else {
            spvc.setViewControllers([userViewController], direction: .reverse, animated: true, completion: nil)
        }
        // sets the view to the right search controller
        currentViewController = userViewController
        
        filteredAllEvents = []
        userViewController.tableView.reloadData()
        // clears the data in the tableveiw and the data array
        
        searchBar.placeholder = "Search for a user"
        // resets the dataarray with the corresponding type of data
        self.getAllUsers()
        
        eventButton.isEnabled = true
        locationButton.isEnabled = true
        userButton.isEnabled = false
        locationBarView.isHidden = true
        userBarView.isHidden = false
        nameBarView.isHidden = true
        userButton.titleLabel!.font = UIFont.boldSystemFont(ofSize: 15.0)
        locationButton.titleLabel!.font = UIFont.systemFont(ofSize: 15.0)
        eventButton.titleLabel!.font = UIFont.systemFont(ofSize: 15.0)
    }
    
    func getAllUsers(){
        
        let userRef = databaseRef.child("users")
        
        userRef.observe(.childAdded, with: { (snapshot) in
            if let userDict = snapshot.value as? [String: Any] {
                
                let userInfo = UserInfo.init()
                userInfo.userName = userDict["name"] as! String
                userInfo.userType = userDict["userType"] as? String ?? ""
                userInfo.userProfilePicURL = userDict["profileImageURL"] as? String ?? ""
//                let userCreatedEvents = userDict["userCreatedEvents"] as? [String: String] ?? ["":""]
//                let userSignedUpEvents = userDict["userSignedUpEvents"] as? [String: String] ?? ["":""]
//                let userInfo = UserInfo(type: userType, name: userName, profileURL: profileImageURL, userEvents: userCreatedEvents, signedUp: userSignedUpEvents)
                
                self.allUsers.append(userInfo)
            }
        })
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension SecondViewController: UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        // if the eventbutton is enabled then that means the the location view is present
        if !(locationButton.isEnabled) {
            
            self.filteredAllEvents = self.allEvents.filter{ data in
                
                let dataString = data
                
                return(dataString.eventLocation.lowercased().contains(self.searchController.searchBar.text!.lowercased()))
            }
            locationViewController.tableView.reloadData()
        } else if !(eventButton.isEnabled) {
            
            self.filteredAllEvents = self.allEvents.filter{ data in
                
                let dataString = data
                
                return(dataString.eventName.lowercased().contains(self.searchController.searchBar.text!.lowercased()))
            }
            eventViewController.tableView.reloadData()
        } else {
            
            self.filteredAllEvents = self.allUsers.filter{ data in
                
                let dataString = data
                
                return(dataString.userName.lowercased().contains(self.searchController.searchBar.text!.lowercased()))
            }
            userViewController.tableView.reloadData()
        }
    }
}

extension SecondViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if filteredAllEvents.count <= 0 {
            tableView.separatorStyle = .none
            return 0
        } else {
            tableView.separatorStyle = .singleLine
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return filteredAllEvents.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if !(locationButton.isEnabled) {
            
            let cell = locationViewController.tableView.dequeueReusableCell(withIdentifier: "locationCell") as! LocationTableViewCell
            let eventInfo = filteredAllEvents[indexPath.row] as! EventInfo
            
            cell.eventName.text = eventInfo.eventName
            cell.eventLocation.text = eventInfo.eventLocation
            
            let profileImageRef = storageRef.child("profile_image/\(eventInfo.eventCreator!)")
            profileImageRef.getData(maxSize: 1 * 1024 * 1024) { data, error in
                if let error = error {
                    
                    print(error)
                } else {
                    cell.eventImage.image = UIImage(data: data!)
                }
            }
            return cell
        } else if !(eventButton.isEnabled) {
            
            let cell = eventViewController.tableView.dequeueReusableCell(withIdentifier: "nameCell") as! NameTableViewCell
            let eventInfo = filteredAllEvents[indexPath.row] as! EventInfo
            let startDate = Date(timeIntervalSince1970: eventInfo.eventStartDate)
            let endDate = Date(timeIntervalSince1970: eventInfo.eventEndDate)
            let startTimeString = timeFormatter.string(from: startDate)
            let endTimeString = timeFormatter.string(from: endDate)
            let startDateFormated = dateFormatter.string(from: startDate)
            
            cell.eventName.text = eventInfo.eventName
            let profileImageRef = storageRef.child("profile_image/\(eventInfo.eventCreator!)")
            
            profileImageRef.getData(maxSize: 1 * 1024 * 1024) { data, error in
                if let error = error {
                    
                    print(error)
                } else {
                    cell.eventImage.image = UIImage(data: data!)
                }
            }
            
            if startTimeString.suffix(2) == endTimeString.suffix(2){
                cell.eventTime.text = "\(startDateFormated) | \(startTimeString.dropLast(2))- \(endTimeString)"
            } else {
                cell.eventTime.text = "\(startDateFormated) | \(startTimeString) - \(endTimeString)"
            }
            return cell
        } else {
            
            let cell = userViewController.tableView.dequeueReusableCell(withIdentifier: "userCell") as! UserTableViewCell
            let userInfo = filteredAllEvents[indexPath.row] as! UserInfo
            
            cell.userName.text = userInfo.userName
            cell.userType.text = userInfo.userType
            
            self.storage.reference(forURL: userInfo.userProfilePicURL).getData(maxSize: 1 * 1024 * 1024) { (data, error) in
                if let error = error {
                    print(error)
                } else {
                    cell.userImage.image = UIImage(data: data!)
                }
            }
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60;
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if !(eventButton.isEnabled) || !(locationButton.isEnabled){
            
            // gives the correct view dependign on the event type
            let eventInfo = filteredAllEvents[indexPath.row] as! EventInfo
            let eventType = eventInfo.eventType
            let userRef = databaseRef.child("users").child(eventInfo.eventCreator!)
            
            if(eventType == "simple"){
                
                let simpleEventInfoViewController = self.storyboard?.instantiateViewController(withIdentifier: "SimpleEventInfoViewController") as! SimpleEventInfoViewController
                simpleEventInfoViewController.eventInfo = eventInfo
                
                userRef.observeSingleEvent(of: .value, with: { (snapshot) in
                    let values = snapshot.value as? NSDictionary
                    
                    let userType = values?["userType"] as? String ?? ""
                    let userName = values?["name"] as? String ?? ""
                    let profileImageURL = values?["profileImageURL"] as? String ?? ""
                    let userCreatedEvents = values?["userCreatedEvents"] as? [String: String] ?? ["":""]
                    let userSignedUpEvents = values?["userSignedUpEvents"] as? [String: String] ?? ["":""]
                    
                    simpleEventInfoViewController.creatorInfo = UserInfo(type: userType, name: userName, profileURL: profileImageURL, userEvents: userCreatedEvents, signedUp: userSignedUpEvents)
                    self.navigationController?.pushViewController(simpleEventInfoViewController, animated: true)
                }) { (error) in
                    print(error.localizedDescription)
                }
            } else {
                
                let eventInfoViewController = self.storyboard?.instantiateViewController(withIdentifier: "EventInfoViewController") as! EventInfoViewController
                
                eventInfoViewController.eventInfo = eventInfo
                self.navigationController?.pushViewController(eventInfoViewController, animated: true)
            }
        } else {
            
        }
    }
}

extension SecondViewController: UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        
        guard let viewControllerIndex = tableViewControllerArray.index(of: viewController as! UITableViewController) else {
            return nil
        }
        
        let nextIndex = viewControllerIndex + 1
        let tableViewControllersCount = tableViewControllerArray.count
        
        guard tableViewControllersCount != nextIndex else {
            return nil
        }
        
        guard tableViewControllersCount > nextIndex else {
            return nil
        }
        
        currentViewController = tableViewControllerArray[nextIndex]
        return tableViewControllerArray[nextIndex]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        
        guard let viewControllerIndex = tableViewControllerArray.index(of: viewController as! UITableViewController) else {
            return nil
        }
        
        let previousIndex = viewControllerIndex - 1
        
        guard previousIndex >= 0 else {
            return nil
        }
        
        guard tableViewControllerArray.count > previousIndex else {
            return nil
        }
        
        currentViewController = tableViewControllerArray[previousIndex]
        return tableViewControllerArray[previousIndex]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        
        // if the transition was actually made
        if completed {
            
            if ((previousViewControllers == [eventViewController]) ||
                (previousViewControllers == [locationViewController])){
                
                self.userButtonClicked(userButton)
            } else if currentViewController == eventViewController {
                
                self.eventButtonClicked(eventButton)
            } else if currentViewController == locationViewController{
                
                self.locationButtonClicked(locationButton)
            }
        }
    }
}

//    func getAllEvent(type: String) {
//        // puts all the eventNames into the array
//        let eventRef = databaseRef.child("allEvents")
//
//        eventRef.observe(.childAdded, with: { (snapshot) in
//            if let eventDict = snapshot.value as? [String: Any] {
//
//                let eventData = eventDict[type] as! String
//                self.eventDataArray.append(eventData)
//            }
//        })
//    }
