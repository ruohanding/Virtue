//
//  UserTableViewCell.swift
//  Virtue
//
//  Created by Ruohan Ding on 1/13/18.
//  Copyright © 2018 Ding. All rights reserved.
//

import UIKit

class UserTableViewCell: UITableViewCell {

    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var userType: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.userImage.layer.borderWidth = 1
        self.userImage.layer.masksToBounds = false
        self.userImage.layer.cornerRadius = userImage.frame.height/2
        self.userImage.clipsToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
