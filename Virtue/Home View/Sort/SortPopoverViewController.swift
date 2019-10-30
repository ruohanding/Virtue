//
//  SortPopoverViewController.swift
//  Virtue
//
//  Created by Ruohan Ding on 9/30/17.
//  Copyright © 2017 Ding. All rights reserved.
//

import UIKit

class SortPopoverViewController: UIViewController {
    
    var sortType = "soonestFirst"

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    @IBAction func cancelPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    @IBAction func donePressed(_ sender: Any) {
        let presentingViewController = self.presentingViewController as! UINavigationController
        let parentViewController = presentingViewController.viewControllers.first as! FirstTableViewController
        parentViewController.sortType = sortType
        parentViewController.sort()
        
        dismiss(animated: true, completion: nil)
    }
    @IBAction func soonestFirst(_ sender: Any) {
        sortType = "soonestFirst"
    }
    @IBAction func latestFirst(_ sender: Any) {
        sortType = "latestFirst"
    }
    @IBAction func shortestFirst(_ sender: Any) {
        sortType = "shortestFirst"
    }
    @IBAction func longestFirst(_ sender: Any) {
        sortType = "longestFirst"
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
