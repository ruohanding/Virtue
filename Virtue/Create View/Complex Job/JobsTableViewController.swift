//
//  JobsTableViewController.swift
//  Virtue
//
//  Created by Ruohan Ding on 7/30/17.
//  Copyright © 2017 Ding. All rights reserved.
//

import UIKit

class JobsTableViewController: UITableViewController {
    
    var jobDictionary : [String: JobInfo]!
    var eventStartDate : Date!
    var eventEndDate : Date!
    var selectedIndexPath : IndexPath!
    var eventType = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Sets navigation items
        navigationItem.title = "Jobs"
        navigationItem.rightBarButtonItem = self.editButtonItem
        navigationController?.setToolbarHidden(false, animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "jobInfoSegue" {
            // gives the singleJobViewController the necessry data
            let nextViewController = segue.destination as! SingleJobViewController
            let cell = self.tableView.cellForRow(at: selectedIndexPath) as! JobTableViewCell
            
            let jobName = cell.jobNameLabel.text
            let jobInfoArray = jobDictionary[jobName!]
            let shiftArray = jobInfoArray?.shiftArray
            let jobDescription = jobInfoArray?.jobDescription
            let multipleShiftsBool = jobInfoArray?.multipleShiftsAllowed
            
            nextViewController.shiftArray = shiftArray!
            nextViewController.jobDescription = jobDescription!
            nextViewController.multipleShiftBool = multipleShiftsBool!
            nextViewController.jobName = jobName
        } else if segue.identifier == "addJobSegue" {
            
            let nextNavController = segue.destination as! UINavigationController
            let nextViewController = nextNavController.viewControllers.first as! AddJobTableViewController
            
            nextViewController.eventStartDate = eventStartDate
            nextViewController.eventEndDate = eventEndDate
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        self.tableView.reloadData()
        // sets the previouse controller's dictionary to be the same as ours. Just a consistancy thing
        let previousController = self.navigationController?.viewControllers[(self.navigationController?.viewControllers.count)! - 2] as! ThirdTableViewController
        
        previousController.allJobsDictionaryArray = jobDictionary
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension JobsTableViewController {
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "jobCell") as! JobTableViewCell
        
        // sets the correct value inside the dictionary to the correct label
        let jobName = Array(jobDictionary.keys)[indexPath.row]
        let jobInfoArray = jobDictionary[jobName]
        let shiftsArray: [ShiftInfo] = jobInfoArray!.shiftArray
        
        cell.shiftNumberLabel.text = ("\(shiftsArray.count) shifts")
        cell.jobNameLabel.text = jobName
        return cell
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return jobDictionary.count
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        selectedIndexPath = indexPath
        
        // performs correct segue and deselects the row
        self.performSegue(withIdentifier: "jobInfoSegue", sender: self)
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
