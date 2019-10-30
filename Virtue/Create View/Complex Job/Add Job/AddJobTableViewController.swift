//
//  AddJobTableViewController.swift
//  Virtue
//
//  Created by Ruohan Ding on 8/1/17.
//  Copyright © 2017 Ding. All rights reserved.
//

import UIKit

class AddJobTableViewController: UITableViewController{
    
    var shiftArray = [Int]()
    var eventStartDate : Date!
    var eventEndDate : Date!
    var nameTextView: UITextView!
    var descriptionTextView: UITextView!
    
    @IBOutlet weak var doneBarButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // adds a gesture so that when the user is done editing something they can just tap out
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(AddJobTableViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        
        self.tableView.addGestureRecognizer(tap)
        // makes certain cells in the view go into editing mode
        tableView.setEditing(true, animated: true)
        shiftArray.append(0)
    }
    
    @IBAction func doneBarButtonClicked(_ sender: UIBarButtonItem) {
        // gets the jobsTablViewController form the previous nav controller so data can be sent
        let previousNavController = self.presentingViewController as! ThirdNavigationController
        let previousController = previousNavController.topViewController as! JobsTableViewController
        
        let multipleShiftsCell = tableView.cellForRow(at: IndexPath(row: 0, section: 2)) as! MultipleShiftsTableViewCell
        
        // gets all the data for each shift for the job
        var shiftInfoArray = [ShiftInfo]()
        let shiftNum = shiftArray.count - 2
        for i in 0...shiftNum {
            
            let cell = tableView.cellForRow(at: IndexPath(row: i, section: 1)) as! ShiftTimeTableViewCell
            let peopleNum = Int(cell.peopleNumberField.text!)
            let shiftInterval = cell.endDate.timeIntervalSince(cell.startDate)
            
            let shiftInfo = ShiftInfo(startDate: cell.startDate.timeIntervalSince1970, endDate: cell.endDate.timeIntervalSince1970, interval: shiftInterval, peopleNum: peopleNum!)
            shiftInfoArray.append(shiftInfo)
        }
        
        let jobInfoArray = JobInfo(name: nameTextView.text, description: descriptionTextView.text, mult: multipleShiftsCell.multipleShiftsSwitch.isOn, shifts: shiftInfoArray)
        
        previousController.jobDictionary[nameTextView.text] = jobInfoArray
        
        dismiss(animated: true, completion: nil)
    }
    @IBAction func cancelBatButtonClicked(_ sender: UIBarButtonItem) {
        
        dismiss(animated: true, completion: nil)
        
    }
    
    @objc func dismissKeyboard() {
        // makes everything in the view resignFirstResponder which in turn dismisses all the keyboards
        self.view.endEditing(true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

extension AddJobTableViewController {
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // sets the correct cell for the specific section
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "JobInfoCell") as! JobInfoTableViewCell
            
            // in section 0 there are two cells, name and description. Set the correct name correspondingly
            if indexPath.row == 0 {
                
                cell.infoTextView.text = "Job name"
                nameTextView = cell.infoTextView
            } else if indexPath.row == 1 {
                
                cell.infoTextView.text = "Job description"
                descriptionTextView = cell.infoTextView
            }
            
            return cell
            
        } else if (indexPath.section == 1) && (indexPath.row == shiftArray.count - 1) {
            let cell = tableView.dequeueReusableCell(withIdentifier: "addShiftCell")!
            cell.textLabel?.text = "Add shift"
            
            return cell
        } else if (indexPath.section == 1) && (indexPath.row < shiftArray.count - 1) {
            // other then the add shift cell every other cell in section 1 should be a shiftTime
            let cell = tableView.dequeueReusableCell(withIdentifier: "shiftTimeCell") as! ShiftTimeTableViewCell
            //cell.startTimeField.text = ""
            //cell.endTimeField.text = ""
            
            cell.eventStartDate = eventStartDate
            cell.eventEndDate = eventEndDate
            
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "multipleShiftsCell") as! MultipleShiftsTableViewCell
            
            return cell
        }
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        // creates a white background for the header instead of the default grey
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.bounds.size.width, height: 30))
        headerView.backgroundColor = UIColor.white
        
        return headerView
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        // idk if this is really needed but it makes a header i think
        if section == 1 {
            return " "
        } else {
            return ""
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        if section == 0 {
            return super.tableView(tableView, heightForHeaderInSection: section)
        } else {
            
            return 30
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        // theres that one cell that needs to be super tall
        if indexPath.section == 0 && indexPath.row == 1 {
            
            return 115.0
        } else if (indexPath.section == 1) && (indexPath.row < shiftArray.count - 1) {
            
            return 116.0
        } else {
            
            return 44.0
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        
        return 3
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if section == 0 {
            
            return 2
        } else if section == 1 {
            
            return shiftArray.count
        } else {
            
            return 1
        }
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // we want to be able to delete and insert the first section cells
        if indexPath.section == 1{
            return true
        } else {
            return false
        }
    }
    
    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        // gives certain cells the ability to add new cells
        if (indexPath.section == 1) && (indexPath.row == shiftArray.count - 1) {
            
            return .insert
        } else {
            
            return .delete
        }
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        // this is when the user taps the add button to add a cell
        if editingStyle == .insert {
            
            shiftArray.append(0)
            doneBarButton.isEnabled = true
            
            self.tableView.insertRows(at: [indexPath], with: .top)
        } else if editingStyle == .delete {
            
            // makes sure that the number of shiftarray is correct
            shiftArray.removeLast()
            
            self.tableView.deleteRows(at: [indexPath], with: .left)
        }
    }
}

extension AddJobTableViewController: UITextViewDelegate {
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        
        // since textview does not have a placeholder property, we programtically added one
        if textView.textColor == UIColor.lightGray {
            
            textView.text = nil
            textView.textColor = UIColor.black
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        
        // set the correct placeholder for the correct view
        if textView.text.isEmpty {
            
            if textView == nameTextView {
                
                textView.text = "Job name"
            } else {
                
                textView.text = "Job description"
            }
            textView.textColor = UIColor.lightGray
        }
        
        if textView == nameTextView {
            
            nameTextView.text = textView.text
        } else {
            
            descriptionTextView.text = textView.text
        }
    }
}
