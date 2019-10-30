//
//  jobInfoTableViewCell.swift
//  Virtue
//
//  Created by Ruohan Ding on 8/1/17.
//  Copyright © 2017 Ding. All rights reserved.
//

import UIKit

class JobInfoTableViewCell: UITableViewCell {
    
    @IBOutlet weak var infoTextView: UITextView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        infoTextView.textColor = UIColor.lightGray
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}
