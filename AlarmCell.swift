//
//  AlarmCell.swift
//  syl
//
//  Created by 유호균 on 2016. 4. 22..
//  Copyright © 2016년 timeros. All rights reserved.
//

import UIKit

class AlarmCell: UITableViewCell {
    @IBOutlet var userPhoto: UIImageView!
    @IBOutlet var user: UILabel!
    @IBOutlet var userMsg: UILabel!
    @IBOutlet var time: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
