//
//  OpportunityTableViewCell.swift
//  Virtue
//
//  Created by Ruohan Ding on 7/11/17.
//  Copyright © 2017 Ding. All rights reserved.
//

import UIKit

class OpportunityTableViewCell: UITableViewCell {
    // The prototype cell of the opportunties
    
    @IBOutlet weak var contentPic: UIImageView!
    @IBOutlet weak var profilePic: UIImageView!

    @IBOutlet weak var profileName: UILabel!
    @IBOutlet weak var eventName: UILabel!
    @IBOutlet weak var eventDay: UILabel!
    @IBOutlet weak var eventTime: UILabel!
    //@IBOutlet weak var eventLocation: UILabel!
    @IBOutlet weak var eventAvailability: UILabel!
    
    var eventInfo: EventInfo!
    var creatorInfo: UserInfo!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // makes profile image round
        self.profilePic.layer.borderWidth = 1
        self.profilePic.layer.masksToBounds = false
        self.profilePic.layer.cornerRadius = profilePic.frame.height/2
        self.profilePic.clipsToBounds = true
        
        self.contentPic.layer.masksToBounds = false
        self.contentPic.layer.cornerRadius = 8
        self.contentPic.clipsToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}
