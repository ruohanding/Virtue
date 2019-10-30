//
//  ShiftTableViewCell.swift
//  Virtue
//
//  Created by Ruohan Ding on 8/10/17.
//  Copyright © 2017 Ding. All rights reserved.
//

import UIKit

class ShiftTableViewCell: UITableViewCell {

    @IBOutlet weak var shiftEndLabel: UILabel!
    @IBOutlet weak var shiftStartLabel: UILabel!
    @IBOutlet weak var shiftNumberLabel: UILabel!
    @IBOutlet weak var numberOfSpotsLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }

}
