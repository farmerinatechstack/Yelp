//
//  VendorCell.swift
//  Yelp
//
//  Created by Hassan Karaouni on 4/18/15.
//  Copyright (c) 2015 Timothy Lee. All rights reserved.
//

import UIKit

class VendorCell: UITableViewCell {
    
    @IBOutlet weak var nameLabel: UILabel!

    @IBOutlet weak var distLabel: UILabel!
    
    @IBOutlet weak var numReviewsLabel: UILabel!
    
    @IBOutlet weak var dollarsLabel: UILabel!
    
    @IBOutlet weak var addressLabel: UILabel!
    
    @IBOutlet weak var typesLabel: UILabel!
    
    @IBOutlet weak var thumbView: UIImageView!
    
    @IBOutlet weak var revView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
