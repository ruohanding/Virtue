//
//  CreatorViewController.swift
//  Virtue
//
//  Created by Ruohan Ding on 1/6/18.
//  Copyright © 2018 Ding. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth
import FirebaseStorage


class CreatorViewController: UIViewController {
    
    var creatorInfo: UserInfo!
    var eventInfo: EventInfo!
    var dataRef : DatabaseReference!
    var storageRef: StorageReference!
    var storage: Storage!
    
    @IBOutlet weak var creatorImage: UIImageView!
    @IBOutlet weak var creatorName: UILabel!
    @IBOutlet weak var creatorDescription: UITextView!
    @IBOutlet weak var origanizationLabel: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        storage = Storage.storage()
        dataRef = Database.database().reference()
        
        creatorImage.layer.borderWidth = 1
        creatorImage.layer.masksToBounds = false
        creatorImage.layer.cornerRadius = creatorImage.frame.height/2
        creatorImage.clipsToBounds = true
        
        self.storage.reference(forURL: creatorInfo.userProfilePicURL).getData(maxSize: 1 * 1024 * 1024) { (data, error) in
            if let error = error {
                print(error)
            } else {
                self.creatorImage.image = UIImage(data: data!)
            }
        }
        
        creatorName.text = creatorInfo.userName
        origanizationLabel.sizeToFit()
        origanizationLabel.text = "Representing me, myself, and I. In conjunction with ME©, MySelf™, and I®."
        creatorDescription.sizeToFit()
        creatorDescription.text = "Hi my name is Blake and I like to watch the sunset while walking on a beach barefoot and enjoying the fresh ocean breeze blow through my lusciously long and beautiful hair but before the wind gets too harsh and starts to blow me away I dive deep into the ocean and try to catch seashells with my barefeet I am usually unsuccessfuly but once in a while I do end up getting the seashell and that's when the fun begins because then and only then do I get the pleasure of picking up a seashell with my teeth and eating it I enjoy the taste of grass as it gives me energy to moo all day long"
//        creatorDescription = creatorInfo.description
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
