//
//  Helper.swift
//  Virtue
//
//  Created by Ruohan Ding on 7/9/17.
//  Copyright © 2017 Ding. All rights reserved.
//

/* Usefull stuff:

 writes to the file whatever was inputed into the email text filed
 This is extremely useful because of how it only writes to file instead of also clearing file
 fileWriter = FileHandle.init(forWritingAtPath: FILEURL.path)!
 fileWriter.seekToEndOfFile()
 fileWriter.write(emailData)
 fileWriter.closeFile()
 
 func isEmailValid(testString: String) -> Bool {
 // checks if the email is valid
 // print("validate calendar: \(testStr)") Unsure as to what this code does
 let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
 
 let testEmail = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
 return testEmail.evaluate(with: testString)
 }
 */

import Foundation
import UIKit

struct Config {
    
    static var SOTRAGE_REF = "gs://virtue-18a94.appspot.com"
}

class UserInfo {
    
    static var shared = UserInfo()
    
    var userType: String!
    var userName: String!
    var userProfilePicURL: String!
    var userCreatedEventNames: [String:String]!
    var userSignedUpEvents: [String:String]!
    
    init(type: String, name: String, profileURL: String, userEvents: [String: String], signedUp: [String: String]) {
        
        userType = type
        userName = name
        userProfilePicURL = profileURL
        userCreatedEventNames = userEvents
        userSignedUpEvents = signedUp
        
    }
    
    init() {
        
        userType = ""
        userName = ""
        userProfilePicURL = ""
        userCreatedEventNames = [String: String]()
        userSignedUpEvents = [String: String]()
    }
}

class EventInfo {
    // class that helps with storing event data
    var eventCreator: String!
    var eventID: String!
    var eventName: String!
    var eventImageURL: String!
    var eventImageID: String!
    var eventDescription: String!
    var eventStartDate: Double!
    var eventEndDate: Double!
    var eventLocation: String!
    var eventAvailability: Int!
    var eventType: String!
    var eventLongest: TimeInterval!
    var eventShortest: TimeInterval!
    var eventActive: Bool!
    var jobsArray: [JobInfo]!
    
    init(creator: String, ID: String, name: String, imageURL: String, imageID: String, description: String, startDate: Double, endDate: Double, longest: TimeInterval, shortest: TimeInterval, location: String, availability: Int, type: String, active:Bool, jobs: [JobInfo]) {
        
        eventCreator = creator
        eventID = ID
        eventName = name
        eventImageURL = imageURL
        eventImageID = imageID
        eventDescription = description
        eventStartDate = startDate
        eventEndDate = endDate
        eventLongest = longest
        eventShortest = shortest
        eventLocation = location
        eventAvailability = availability
        eventType = type
        eventActive = active
        jobsArray = jobs
    }
    
    init(creator: String, ID: String, name: String, imageURL: String, imageID: String, description: String, startDate: Double, endDate: Double, longest: TimeInterval, shortest: TimeInterval, location: String, availability: Int, type: String, active:Bool) {
        
        eventCreator = creator
        eventID = ID
        eventName = name
        eventImageURL = imageURL
        eventImageID = imageID
        eventDescription = description
        eventStartDate = startDate
        eventEndDate = endDate
        eventLongest = longest
        eventShortest = shortest
        eventLocation = location
        eventAvailability = availability
        eventType = type
        eventActive = active
        jobsArray = [JobInfo]()
    }
    
    init() {
        
        eventCreator = ""
        eventID = ""
        eventName = ""
        eventImageURL = ""
        eventImageID = ""
        eventDescription = ""
        eventStartDate = 0
        eventEndDate = 0
        eventLongest = 0
        eventShortest = 0
        eventLocation = ""
        eventType = ""
        eventAvailability = 0
        eventActive = true
        jobsArray = [JobInfo]()
    }
}

class JobInfo {
    // class that helps with storing data, specificly job data
    var jobName: String!
    var jobDescription : String!
    var multipleShiftsAllowed: Bool!
    var shiftArray: [ShiftInfo]!
    
    init(name: String, description: String, mult: Bool, shifts: [ShiftInfo]) {
        
        jobName = name
        jobDescription = description
        multipleShiftsAllowed = mult
        shiftArray = shifts
    }
    
    init() {
        
        jobName = ""
        jobDescription = ""
        multipleShiftsAllowed = true
        shiftArray = [ShiftInfo]()
    }
}

class ShiftInfo {
    // class that helps with storing shift data
    var shiftStartDate: Double!
    var shiftEndDate: Double!
    var shiftPeopleNum: Int!
    var shiftInterval: TimeInterval!
    
    init(startDate: Double, endDate: Double, interval: TimeInterval, peopleNum: Int) {
        
        shiftStartDate = startDate
        shiftEndDate = endDate
        shiftPeopleNum = peopleNum
        shiftInterval = interval
    }
    
    init() {
        
        shiftStartDate = 0
        shiftEndDate = 0
        shiftPeopleNum = 0
        shiftInterval = 0
    }
}

class EventInfoArray {
    
    static var shared = EventInfoArray()
    
    var allEventsArray : [EventInfo]!
    
    init(array: [EventInfo]) {
        allEventsArray = array
    }
    
    init() {
        allEventsArray = [EventInfo]()
    }
}

extension UIColor {
    
    func imageFromColor() -> UIImage {
        UIGraphicsBeginImageContext(CGSize(width: 1, height: 1))
        setFill()
        UIGraphicsGetCurrentContext()?.fill(CGRect(x: 0, y: 0, width: 1, height: 1))
        let image = UIGraphicsGetImageFromCurrentImageContext() ?? UIImage()
        UIGraphicsEndImageContext()
        
        return image
    }
}
/*
 
 Dead Stuff:
 
 This was the og concept for the profile page, it resizes the tabbar within the view
 // resizes the tabbar controller inside of the view to make it look good
 self.ptbc = self.storyboard!.instantiateViewController(withIdentifier: "ProfileTabBarController") as! UITabBarController
 self.ptbc.view.frame = CGRect(x: 0, y: 172, width: self.view.frame.width, height: self.view.frame.height - 50)
 self.ptbc.tabBar.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: 0)
 
 // adds that tabbarcontroller as a child of the view
 self.addChildViewController(ptbc)
 self.view.addSubview(ptbc.view)
 self.ptbc.didMove(toParentViewController: self)
 
 //adds constraints programically
 func addContraintsWithFormat(_ format: String, views: UIView...) {
 var viewDict = [String: UIView]()
 
 for (index, view) in views.enumerated() {
 let key = "v\(index)"
 view.translatesAutoresizingMaskIntoConstraints = false
 viewDict[key] = view
 }
 
 view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: format, options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: viewDict))
 }
 */
