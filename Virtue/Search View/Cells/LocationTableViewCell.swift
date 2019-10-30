//
//  LocationTableViewCell.swift
//  Virtue
//
//  Created by Ruohan Ding on 1/13/18.
//  Copyright © 2018 Ding. All rights reserved.
//

import UIKit

class LocationTableViewCell: UITableViewCell {

    @IBOutlet weak var eventImage: UIImageView!
    @IBOutlet weak var eventLocation: UILabel!
    @IBOutlet weak var eventName: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.eventImage.layer.borderWidth = 1
        self.eventImage.layer.masksToBounds = false
        self.eventImage.layer.cornerRadius = eventImage.frame.height/2
        self.eventImage.clipsToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
