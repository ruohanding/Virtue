//
//  MainTabBarViewController.swift
//  Virtue
//
//  Created by Ruohan Ding on 7/9/17.
//  Copyright © 2017 Ding. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase

class MainTabBarController: UITabBarController {
    // The main hub of everything, backbone of the project. Contains all the different views except for intro
    
    var profileDataRef: DatabaseReference!
    var userInfo = UserInfo()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // gets rid of seperator
        self.tabBar.backgroundImage = UIColor.white.imageFromColor()
        self.tabBar.shadowImage = UIColor.groupTableViewBackground.imageFromColor()
        profileDataRef = Database.database().reference()
        
        self.setUpIcons()
        self.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        
        self.checkUserStatus()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        var tabFrame = self.tabBar.frame
        //let tabHeight = self.tabBar.frame.height - 4
        //print(self.tabBar.frame.height)
        //print(self.tabBar.frame.height - 4)
        tabFrame.size.height = 45
        tabFrame.origin.y = self.view.frame.size.height - 45
        self.tabBar.frame = tabFrame
    }
    
    func setUpIcons() {
        // sets up all the icons for the tab bars
        let homeTab = self.viewControllers![0]
        homeTab.tabBarItem.title = nil
        homeTab.tabBarItem.selectedImage = UIImage(named: "Home-Icon")?.withRenderingMode(.alwaysOriginal)
        homeTab.tabBarItem.image = UIImage(named: "Home-Icon-Outline")?.withRenderingMode(.alwaysOriginal)
        homeTab.tabBarItem.imageInsets = UIEdgeInsets(top: 6, left: 0, bottom: -6, right: 0)
        
        let searchTab = self.viewControllers![1]
        searchTab.tabBarItem.title = nil
        searchTab.tabBarItem.selectedImage = UIImage(named: "Search-Icon")?.withRenderingMode(.alwaysOriginal)
        searchTab.tabBarItem.image = UIImage(named: "Search-Icon-Outline")?.withRenderingMode(.alwaysOriginal)
        searchTab.tabBarItem.imageInsets = UIEdgeInsets(top: 6, left: 0, bottom: -6, right: 0)
        
//        let settingTab = self.viewControllers![2]
//        settingTab.tabBarItem.title = nil
//        settingTab.tabBarItem.selectedImage = UIImage(named: "Setting-Icon")?.withRenderingMode(.alwaysOriginal)
//        settingTab.tabBarItem.image = UIImage(named: "Setting-Icon-Outline")?.withRenderingMode(.alwaysOriginal)
//        settingTab.tabBarItem.imageInsets = UIEdgeInsets(top: 6, left: 0, bottom: -6, right: 0)
        
        let notificationTab = self.viewControllers![2]
        notificationTab.tabBarItem.title = nil
        notificationTab.tabBarItem.image = UIImage(named: "Notification-Icon")?.withRenderingMode(.alwaysOriginal)
        notificationTab.tabBarItem.selectedImage = UIImage(named: "Notification-Icon-Selected")?.withRenderingMode(.alwaysOriginal)
        notificationTab.tabBarItem.imageInsets = UIEdgeInsets(top: 6, left: 0, bottom: -6, right: 0)
        
        let profileTab = self.viewControllers![3]
        profileTab.tabBarItem.title = nil
        profileTab.tabBarItem.selectedImage = UIImage(named: "Profile-Icon")?.withRenderingMode(.alwaysOriginal)
        profileTab.tabBarItem.image = UIImage(named: "Profile-Icon-Outline")?.withRenderingMode(.alwaysOriginal)
        profileTab.tabBarItem.imageInsets = UIEdgeInsets(top: 6, left: 0, bottom: -6, right: 0)
    }
    
    func checkUserStatus() {
        let ivc = self.storyboard?.instantiateViewController(withIdentifier: "IntroNavigationViewController") as! IntroNavigationViewController
        
        
        // checks to see if the user is logged in
        if Auth.auth().currentUser == nil {
            
            self.present(ivc, animated: true, completion: nil)
        } else if !(UserDefaults.standard.value(forKey: "userTypeDeltWith") as! Bool){
            
            let userID = Auth.auth().currentUser!.uid
            // uses the userid to find the userType
            
            self.profileDataRef.child("users").child(userID).observe(.value, with: { (snapshot) in
                
                let values = snapshot.value as? NSDictionary
                
                let userType = values?["userType"] as? String ?? ""
                let userName = values?["name"] as? String ?? ""
                let profileImageURL = values?["profileImageURL"] as? String ?? ""
                let userCreatedEvents = values?["userCreatedEvents"] as? [String: String] ?? ["":""]
                let userSignedUpEvents = values?["userSignedUpEvents"] as? [String: String] ?? ["":""]
                
                UserInfo.shared = UserInfo(type: userType, name: userName, profileURL: profileImageURL, userEvents: userCreatedEvents, signedUp: userSignedUpEvents)
                self.userInfo = UserInfo.shared
                // switches throught the difference cases of usertype.
                switch userType {
                case "":
                    self.performSegue(withIdentifier: "mainToUserTypeSegue", sender: self)
                    UserDefaults.standard.set(false, forKey: "userTypeDeltWith")
                    break
                case "Volunteer":
                    if (self.viewControllers?.count)! == 5 {
                        self.viewControllers?.remove(at: 2)
                    }
                    UserDefaults.standard.set(true, forKey: "userTypeDeltWith")
                    break
                case "Creator":
                    let tnc = self.storyboard?.instantiateViewController(withIdentifier: "ThirdNavigationController") as! ThirdNavigationController
                    tnc.tabBarItem.title = nil
                    //tnc.tabBarItem.selectedImage = UIImage(named: "Profile-Icon")?.withRenderingMode(.alwaysOriginal)
                    tnc.tabBarItem.image = UIImage(named: "Create-Icon-Basic")?.withRenderingMode(.alwaysOriginal)
                    tnc.tabBarItem.imageInsets = UIEdgeInsets(top: 6, left: 0, bottom: -6, right: 0)
                    if (self.viewControllers?.count)! < 5 {
                        self.viewControllers?.insert(tnc, at: 2)
                    }
                    UserDefaults.standard.set(true, forKey: "userTypeDeltWith")
                    break
                default:
                    break
                }
                
            }) { (error) in
                
                print(error.localizedDescription)
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated
        
    }
}

extension MainTabBarController: UITabBarControllerDelegate {
    
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        
        // if the create view controller is even displayed
        if UserInfo.shared.userType == "Creator" {
            
            // if the veiw controller selected is our "create" veiw controller, then we aren't going to just switch to it
            // and display it, we are going to not switch to it and make it a popover.
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let thirdNavigationController = storyboard.instantiateViewController(withIdentifier: "ThirdNavigationController") as! ThirdNavigationController
            let operationalViewController = viewControllers![2]
            
            if viewController == operationalViewController {
                
                present(thirdNavigationController, animated: true, completion: nil)
                
                return false
            }
        }
            
        return true
    }
}
