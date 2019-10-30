//
//  SingleJobViewController.swift
//  Virtue
//
//  Created by Ruohan Ding on 8/10/17.
//  Copyright © 2017 Ding. All rights reserved.
//

import UIKit

class SingleJobViewController: UIViewController {

    @IBOutlet weak var shiftTableView: UITableView!
    @IBOutlet weak var multipleShiftsLabel: UILabel!
    @IBOutlet weak var jobDescriptionTextView: UITextView!
    
    var multipleShiftBool: Bool!
    var jobDescription: String!
    var shiftArray = [ShiftInfo]()
    var jobName: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = jobName
        jobDescriptionTextView.text = jobDescription
        
        if multipleShiftBool {
            multipleShiftsLabel.text = "Volunteers allowed to sign up for multiple shifts"
        } else {
            multipleShiftsLabel.text = "Volunteers NOT allowed to sign up for multiple shifts"
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension SingleJobViewController: UITableViewDelegate, UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // gets the data form the shiftCell from the shift array array from the dictionary.
        let shiftInfo = shiftArray[indexPath.row]
        let startTime = shiftInfo.shiftStartDate
        let endTime = shiftInfo.shiftEndDate
        let peopleNum = shiftInfo.shiftPeopleNum
        
        // sets the data for the shift cell
        let cell = shiftTableView.dequeueReusableCell(withIdentifier: "shiftCell") as! ShiftTableViewCell
        cell.shiftNumberLabel.text = "Shift \(indexPath.row + 1)"
        
        let startDate = Date(timeIntervalSince1970: startTime!)
        let endDate = Date(timeIntervalSince1970: endTime!)
        cell.shiftStartLabel.text = startDate.description
        cell.shiftEndLabel.text = endDate.description
        cell.numberOfSpotsLabel.text = "\(peopleNum!) Spots"
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return shiftArray.count
    }
}
