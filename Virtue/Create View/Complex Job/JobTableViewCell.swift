//
//  jobTableViewCell.swift
//  Virtue
//
//  Created by Ruohan Ding on 8/10/17.
//  Copyright © 2017 Ding. All rights reserved.
//

import UIKit

class JobTableViewCell: UITableViewCell {
    
    @IBOutlet weak var jobNameLabel: UILabel!
    @IBOutlet weak var shiftNumberLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
