//
//  UserSettingsTableViewController.swift
//  Virtue
//
//  Created by Ruohan Ding on 10/17/17.
//  Copyright © 2017 Ding. All rights reserved.
//

import UIKit
import FirebaseAuth


class UserSettingsTableViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // back button
        self.navigationController?.navigationBar.backIndicatorImage = UIImage(named: "Back-Black")?.withRenderingMode(.alwaysOriginal)
        self.navigationController?.navigationBar.backIndicatorTransitionMaskImage = UIImage(named: "Back")?.withRenderingMode(.alwaysOriginal)
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
    }
    
    @IBAction func doneClicked(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func logOut(){
        (self.presentingViewController as! UITabBarController).selectedIndex = 0
        dismiss(animated: true, completion: nil)
        
        try! Auth.auth().signOut()

        UserDefaults.standard.set(false, forKey: "userTypeDeltWith")


        let ivc = self.storyboard?.instantiateViewController(withIdentifier: "IntroNavigationViewController") as! IntroNavigationViewController
        present(ivc, animated: true, completion: nil)
        
//        // Experimental!! Might mess up app!!
//        UIApplication.shared.keyWindow?.rootViewController = storyboard!.instantiateViewController(withIdentifier: "MainTabBarController")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 && indexPath.row == 0 {
            logOut()
        } else if indexPath.section == 0 && indexPath.row == 1{
            let phoneViewController = self.storyboard?.instantiateViewController(withIdentifier: "PhoneViewController") as! PhoneViewController
            self.present(phoneViewController, animated: true, completion: nil)
        }
    }
}
