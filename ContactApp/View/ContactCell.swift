//
//  ContactCell.swift
//  ContactApp
//
//  Created by SAURABH MISHRA on 16/05/20.
//  Copyright © 2020 SAURABH MISHRA. All rights reserved.
//

import UIKit

class ContactCell: UITableViewCell {

    @IBOutlet weak var email: UILabel!
    @IBOutlet weak var mobile: UILabel!
    @IBOutlet weak var name: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
