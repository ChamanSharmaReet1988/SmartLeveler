//
//  VersionCell.swift
//  smartleveler
//
//  Created by Apple on 14/01/19.
//  Copyright © 2019 com. All rights reserved.
//

import UIKit

protocol VersionCellDelegate {
    func downloadAction(index : Int)
    func deleteAction(index : Int)
}

class VersionCell: UITableViewCell {
    @IBOutlet weak var downloadBtn: UIButton!
    @IBOutlet weak var detailLabel: UILabel!
    @IBOutlet weak var descriptionBtn: UIButton!
    @IBOutlet weak var versionNumLabel: UILabel!
    @IBOutlet weak var serialNoLabel: UILabel!
    @IBOutlet weak var createdDate: UILabel!
    var delegate: VersionCellDelegate?
    @IBOutlet weak var deleteButton: UIButton!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
    func updateUI(indexPath : IndexPath) {
        self.tag = indexPath.row
    }
    
    @IBAction func downloadAction() {
        if let _ = delegate {
            delegate?.downloadAction(index : tag)
        }
    }
    
    @IBAction func deleteAction() {
        if let _ = delegate {
            delegate?.deleteAction(index : tag)
        }
    }


}
