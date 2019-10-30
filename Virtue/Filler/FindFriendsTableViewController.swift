//
//  FindFriendsViewController.swift
//  Virtue
//
//  Created by Ruohan Ding on 11/8/17.
//  Copyright © 2017 Ding. All rights reserved.
//

import UIKit
import Contacts
import FirebaseAuth

class FindFriendsTableViewController: UITableViewController {
    
    var userContacts = [CNContact]()
    var newContacts = [CNContact]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        let store = CNContactStore()
        store.requestAccess(for: .contacts) { (isGranted, error) in
            
            if (error != nil) {
                print(error!)
            }
            
            if isGranted {
                DispatchQueue.main.async {
                    // solves reload data main ui problem
                    let keys = [CNContactPhoneNumbersKey, CNContactFamilyNameKey, CNContactGivenNameKey, CNContactEmailAddressesKey]
                    let request = CNContactFetchRequest(keysToFetch: keys as [CNKeyDescriptor])
                    
                    try? store.enumerateContacts(with: request) { (contact, error) in
                        for email in contact.emailAddresses {
                            Auth.auth().fetchProviders(forEmail: email.value as String, completion: { (ids, error) in
                                
                                if (error != nil){
                                    print(error!.localizedDescription)
                                    return
                                }
                                
                                if (ids != nil){
                                    if(ids! == ["password"]){
                                        if !(self.userContacts.contains(contact)){
                                            self.userContacts.append(contact)
                                        }
                                    } else {
                                        if !(self.userContacts.contains(contact)){
                                            self.userContacts.append(contact)
                                        }
                                    }
                                } else {
                                    if !(self.userContacts.contains(contact)){
                                        self.userContacts.append(contact)
                                    }
                                }
                                self.tableView.reloadData()
                            })
                        }
                    }
                }
            } else {
                //user denied access
                print("denied access")
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if section == 0{
            return userContacts.count
        } else {
            return newContacts.count
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "addFriendCell") as! AddFriendTableViewCell
        
        if indexPath.section == 0{
            cell.nameLabel.text = userContacts[indexPath.row].givenName
        } else {
            cell.nameLabel.text = String(indexPath.row)
            cell.nameLabel.text = newContacts[indexPath.row].givenName
        }
        
        return cell
    }
}
