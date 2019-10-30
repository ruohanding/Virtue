//
//  EventTypeViewController.swift
//  Virtue
//
//  Created by Ruohan Ding on 9/21/17.
//  Copyright © 2017 Ding. All rights reserved.
//

import UIKit

class EventTypeViewController: UIViewController {
    
    var eventType = ""
    
    @IBOutlet weak var simpleButton: UIButton!
    @IBOutlet weak var complexButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        simpleButton.layer.cornerRadius = 6
        complexButton.layer.cornerRadius = 6
    }
    
    @IBAction func cancelButtonPressed(_ sender: UIBarButtonItem) {
        
        dismiss(animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        if segue.identifier == "simpleSegue" {
            
            let nextController = segue.destination as! SimpleTableViewController
            nextController.eventType = "simple"
        } else {
            
            let nextController = segue.destination as! ThirdTableViewController
            nextController.eventType = "complex"
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
