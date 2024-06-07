//
//  ReadingCell.swift
//  smartleveler
//
//  Created by apple on 07/05/18.
//  Copyright © 2018 com. All rights reserved.
//

import UIKit

class ReadingCell: UITableViewCell {
    @IBOutlet var titleLabel : UILabel!
    @IBOutlet var deleteButton : UIButton!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
