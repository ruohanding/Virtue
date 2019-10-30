//
//  FifthViewContoller.swift
//  Virtue
//
//  Created by Ruohan Ding on 7/9/17.
//  Copyright © 2017 Ding. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseStorage
import FirebaseDatabase

class FifthViewController: UIViewController {
    // Your profile
    
    var startPageViewController: UIPageViewController!
    var activeEventsTableViewController: ProfileTableViewController!
    var completedEventsTableViewController: ProfileTableViewController!
    var createdEventsTableViewController: ProfileTableViewController!
    var viewControllerArray: [UITableViewController]!
    var currentViewController: UITableViewController!
    var userInfo : UserInfo!
    var eventInfoArray : EventInfoArray!
    var storageRef: StorageReference!
    
    @IBOutlet weak var pageView: UIView!
    @IBOutlet weak var completedButton: UIButton!
    @IBOutlet weak var activeButton: UIButton!
    @IBOutlet weak var createdButton: UIButton!
    @IBOutlet weak var profilePic: UIImageView!
    @IBOutlet weak var createView: UIView!
    @IBOutlet weak var completeView: UIView!
    @IBOutlet weak var activeView: UIView!
    @IBOutlet weak var activeCount: UILabel!
    @IBOutlet weak var completedCount: UILabel!
    @IBOutlet weak var createdCount: UILabel!
    @IBOutlet weak var editButton: UIButton!
    @IBOutlet weak var settingsButton: UIButton!
    @IBOutlet weak var nameLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        storageRef = Storage.storage().reference()
        userInfo = UserInfo.shared
        
        editButton.layer.cornerRadius = 6
        editButton.layer.borderWidth = 1
        editButton.layer.borderColor = UIColor.groupTableViewBackground.cgColor
        
        settingsButton.layer.cornerRadius = 6
        settingsButton.layer.borderWidth = 1
        settingsButton.layer.borderColor = UIColor.groupTableViewBackground.cgColor
        
        // back button
        self.navigationController?.navigationBar.backIndicatorImage = UIImage(named: "Back-Black")?.withRenderingMode(.alwaysOriginal)
        self.navigationController?.navigationBar.backIndicatorTransitionMaskImage = UIImage(named: "Back")?.withRenderingMode(.alwaysOriginal)
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        
        startPageViewController = self.storyboard?.instantiateViewController(withIdentifier: "StatPageViewController") as! UIPageViewController
        
        activeEventsTableViewController = self.storyboard?.instantiateViewController(withIdentifier: "ProfileTableViewController") as! ProfileTableViewController
        completedEventsTableViewController = self.storyboard?.instantiateViewController(withIdentifier: "ProfileTableViewController") as! ProfileTableViewController
        createdEventsTableViewController = self.storyboard?.instantiateViewController(withIdentifier: "ProfileTableViewController") as! ProfileTableViewController
        
        activeEventsTableViewController.dataType = "active"
        completedEventsTableViewController.dataType = "completed"
        createdEventsTableViewController.dataType = "created"
        
        // sets the pageViewController
        startPageViewController.dataSource = self
        startPageViewController.delegate = self
        startPageViewController.view.frame = pageView.frame
        viewControllerArray = [activeEventsTableViewController, completedEventsTableViewController, createdEventsTableViewController]
        
        startPageViewController.setViewControllers([activeEventsTableViewController],
                                                   direction: .forward,
                                                   animated: true,
                                                   completion: nil)
        // sets up first view
        currentViewController = activeEventsTableViewController
        activeButton.isEnabled = false
        createdButton.isEnabled = true
        completedButton.isEnabled = true
        activeView.isHidden = false
        completeView.isHidden = true
        createView.isHidden = true
        completedButton.titleLabel!.font = UIFont.systemFont(ofSize: 15.0)
        activeButton.titleLabel!.font = UIFont.boldSystemFont(ofSize: 15.0)
        createdButton.titleLabel!.font = UIFont.systemFont(ofSize: 15.0)
        
        self.addChildViewController(startPageViewController)
        self.view.addSubview(startPageViewController.view)
        startPageViewController.didMove(toParentViewController: self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        userInfo = UserInfo.shared
        eventInfoArray = EventInfoArray.shared
        
        self.navigationController?.isNavigationBarHidden = true
        
        // sets the profile name
        nameLabel.text = userInfo.userName
        self.setProfilePic()
        self.setUpLabels()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        
        self.navigationController?.isNavigationBarHidden = false
    }
    
    @IBAction func completedPressed(_ sender: Any) {
        if currentViewController == activeEventsTableViewController {
            startPageViewController.setViewControllers([completedEventsTableViewController], direction: .forward, animated: true, completion: nil)
        } else {
            startPageViewController.setViewControllers([completedEventsTableViewController], direction: .reverse, animated: true, completion: nil)
        }
        currentViewController = completedEventsTableViewController
        
        activeButton.isEnabled = true
        createdButton.isEnabled = true
        completedButton.isEnabled = false
        activeView.isHidden = true
        completeView.isHidden = false
        createView.isHidden = true
        completedButton.titleLabel!.font = UIFont.boldSystemFont(ofSize: 15.0)
        activeButton.titleLabel!.font = UIFont.systemFont(ofSize: 15.0)
        createdButton.titleLabel!.font = UIFont.systemFont(ofSize: 15.0)
    }
    @IBAction func activePressed(_ sender: Any) {
        
        startPageViewController.setViewControllers([activeEventsTableViewController], direction: .reverse, animated: true, completion: nil)
        currentViewController = activeEventsTableViewController
        
        activeButton.isEnabled = false
        createdButton.isEnabled = true
        completedButton.isEnabled = true
        activeView.isHidden = false
        completeView.isHidden = true
        createView.isHidden = true
        completedButton.titleLabel!.font = UIFont.systemFont(ofSize: 15.0)
        activeButton.titleLabel!.font = UIFont.boldSystemFont(ofSize: 15.0)
        createdButton.titleLabel!.font = UIFont.systemFont(ofSize: 15.0)
    }
    @IBAction func createdPressed(_ sender: Any) {
        startPageViewController.setViewControllers([createdEventsTableViewController], direction: .forward, animated: true, completion: nil)
        currentViewController = createdEventsTableViewController
        
        activeButton.isEnabled = true
        createdButton.isEnabled = false
        completedButton.isEnabled = true
        activeView.isHidden = true
        completeView.isHidden = true
        createView.isHidden = false
        completedButton.titleLabel!.font = UIFont.systemFont(ofSize: 15.0)
        activeButton.titleLabel!.font = UIFont.systemFont(ofSize: 15.0)
        createdButton.titleLabel!.font = UIFont.boldSystemFont(ofSize: 15.0)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setProfilePic(){
        
        // makes a circle profile pic and sets it to a placeholder
        self.profilePic.layer.borderWidth = 1
        self.profilePic.layer.masksToBounds = false
        self.profilePic.layer.cornerRadius = profilePic.frame.height/2
        self.profilePic.clipsToBounds = true
        
        // gets the image from storage and puts it in
        if let userId = Auth.auth().currentUser?.uid {
            let profileImageRef = storageRef.child("profile_image/\(userId)")
            
            profileImageRef.getData(maxSize: 1 * 1024 * 1024) { data, error in
                if let error = error {
                    
                    print(error)
                } else {
                    self.profilePic.image = UIImage(data: data!)
                }
            }
        }
    }
    
    func setUpLabels(){
        var activeNum = 0
        var completedNum = 0
        var createdNum = 0
        
        let signedUpEvents = Array(userInfo.userSignedUpEvents.keys)
        let createdEvents = Array(userInfo.userCreatedEventNames.keys)
        
        for event in eventInfoArray.allEventsArray {
            if (signedUpEvents.contains(event.eventID)) && (event.eventActive){
                activeNum += 1
            } else if (signedUpEvents.contains(event.eventID)) && !(event.eventActive){
                completedNum += 1
            } else if createdEvents.contains(event.eventID) {
                createdNum += 1
            }
        }
        
        activeCount.text = String(activeNum) + " Active |"
        completedCount.text = String(completedNum) + " Completed |"
        createdCount.text = String(createdNum) + " Created"
    }
}

extension FifthViewController: UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        
        guard let viewControllerIndex = viewControllerArray.index(of: viewController as! UITableViewController) else {
            return nil
        }
        
        let nextIndex = viewControllerIndex + 1
        let viewControllersCount = viewControllerArray.count
        
        guard viewControllersCount != nextIndex else {
            return nil
        }
        
        guard viewControllersCount > nextIndex else {
            return nil
        }
        
        currentViewController = viewControllerArray[nextIndex]
        return viewControllerArray[nextIndex]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        
        guard let viewControllerIndex = viewControllerArray.index(of: viewController as! UITableViewController) else {
            return nil
        }
        
        let previousIndex = viewControllerIndex - 1
        
        guard previousIndex >= 0 else {
            return nil
        }
        
        guard viewControllerArray.count > previousIndex else {
            return nil
        }
        
        currentViewController = viewControllerArray[previousIndex]
        return viewControllerArray[previousIndex]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        
        // if the transition was actually made
        if completed {
            
            if ((previousViewControllers == [activeEventsTableViewController]) ||
                (previousViewControllers == [createdEventsTableViewController])){
                
                completedPressed(completedButton)
            } else if currentViewController == activeEventsTableViewController {
    
                activePressed(activeButton)
            } else if currentViewController == createdEventsTableViewController{
                
                createdPressed(createdButton)
            }
        }
    }
}


