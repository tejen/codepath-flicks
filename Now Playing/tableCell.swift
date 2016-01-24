//
//  tableCell.swift
//  Now Playing
//
//  Created by Tejen Hasmukh Patel on 1/23/16.
//  Copyright © 2016 Tejen. All rights reserved.
//

import UIKit

class tableCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var synopsisView: UITextView!
    @IBOutlet weak var posterImageView: UIImageView!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var ratingLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
