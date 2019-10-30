//
//  IntroContentViewController.swift
//  Virtue
//
//  Created by Ruohan Ding on 4/15/17.
//  Copyright © 2017 Ding. All rights reserved.
//

import UIKit

class IntroContentViewController: UIViewController {
    
    @IBOutlet weak var imageView: UIImageView!
    
    var pageIndex: Int!
    var imageFile: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.imageView.image = UIImage(named: imageFile)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
