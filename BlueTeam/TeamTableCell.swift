//
//  TeamTableCell.swift
//  BlueTeam
//
//  Created by Yanliang Gu on 7/13/16.
//  Copyright © 2016 Yanliang Gu. All rights reserved.
//

import UIKit

class TeamTableCell: UITableViewCell {
    @IBOutlet weak var deleteBtn: UIButton!
    @IBOutlet weak var addBtn: UIButton!
    @IBOutlet weak var textField: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.layer.borderColor = UIColor.grayColor().CGColor
        self.layer.borderWidth = 0.5
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
