//
//  ShiftTimeTableViewCell.swift
//  Virtue
//
//  Created by Ruohan Ding on 8/2/17.
//  Copyright © 2017 Ding. All rights reserved.
//

import UIKit

class ShiftTimeTableViewCell: UITableViewCell {
    
    @IBOutlet weak var startTimeField: UITextField!
    @IBOutlet weak var endTimeField: UITextField!
    @IBOutlet weak var peopleNumberField: UITextField!
    
    var startDatePicker:UIDatePicker = UIDatePicker()
    var endDatePicker:UIDatePicker = UIDatePicker()
    var startDate: Date!
    var endDate: Date!
    var eventStartDate : Date!
    var eventEndDate : Date!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    @IBAction func peopleNumberEditingEnd(_ sender: UITextField) {
        let num = Int(peopleNumberField.text!)
        
        if num == 0 {
            peopleNumberField.text = ""
        }
    }
    @IBAction func startTimeFieldEditing(_ sender: UITextField) {
        // makes the keyboard a datepicker
        
        self.checkEventDate()
        
        startDatePicker.datePickerMode = .dateAndTime
        startDatePicker.minuteInterval = 15
        startDatePicker.minimumDate = eventStartDate
        startDatePicker.maximumDate = eventEndDate
        sender.inputView = startDatePicker
        startDatePicker.addTarget(self, action:#selector(ShiftTimeTableViewCell.startDatePickerValueChanged), for:.valueChanged)
    }
    
    @IBAction func endTimeFiledEditing(_ sender: UITextField) {
        
        self.checkEventDate()
        
        endDatePicker.datePickerMode = .dateAndTime
        endDatePicker.minuteInterval = 15
        
        // sets the minimum date of end date if start date is not empty
        if startTimeField == nil {
            endDatePicker.minimumDate = eventStartDate
        } else {
            endDatePicker.minimumDate = startDatePicker.date
        }
        
        endDatePicker.maximumDate = eventEndDate

        sender.inputView = endDatePicker
        endDatePicker.addTarget(self, action: #selector(ShiftTimeTableViewCell.endDatePickerValueChanged), for: .valueChanged)
    }
    
    func checkEventDate() {
        
        if (eventStartDate) != nil {
            
            print("Event start or end date is propperly set")
        } else {
            
            createAlert(title: "Event Dates Are Not Properly Set", message: "You have not set your event dates, please do so before attempting to set shift dates")
            self.endEditing(true)
        }
    }
    
    func createAlert(title: String, message: String) {
        // creates an alert from given info
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        // creates the alert buttons
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action) in
            alert.dismiss(animated: true, completion: nil)
        }))
        
        parentViewController?.present(alert, animated: true, completion: nil)
    }
    
    @objc func startDatePickerValueChanged(sender:UIDatePicker) {
        // formats the date for the label
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM dd, h:mm a"
        dateFormatter.amSymbol = "AM"
        dateFormatter.pmSymbol = "PM"
        
        startTimeField.text = dateFormatter.string(from: sender.date)
        startDate = sender.date
        
        // change the date color if the date is set incorrectly
        if endTimeField != nil && (startDatePicker.date >= endDatePicker.date) {
            
            endTimeField.textColor = UIColor.red
        }
    }
    
    @objc func endDatePickerValueChanged(sender:UIDatePicker) {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM dd, h:mm a"
        dateFormatter.amSymbol = "AM"
        dateFormatter.pmSymbol = "PM"
        
        endTimeField.text = dateFormatter.string(from: sender.date)
        endDate = sender.date
        
        // the color might be red if the date was set wrong
        if endTimeField.textColor == UIColor.red && (startDatePicker.date <= endDatePicker.date){
            
            endTimeField.textColor = UIColor.black
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

extension ShiftTimeTableViewCell {
    // gets the parent view of the cell
    var parentViewController: UIViewController? {
        var parentResponder: UIResponder? = self
        while parentResponder != nil {
            parentResponder = parentResponder!.next
            if parentResponder is UIViewController {
                return parentResponder as! UIViewController!
            }
        }
        return nil
    }
}
