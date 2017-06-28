//
//  UserTableViewCell.swift
//  snapshare
//
//  Created by Francisco San Emeterio on 6/28/17.
//  Copyright © 2017 Vinfranryia. All rights reserved.
//

import UIKit

protocol UserTableViewCellDelegate: class {
    func userCellFollowButtonPressed(sender: UserTableViewCell)
}

class UserTableViewCell: UITableViewCell {

    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var followButton: UIButton!
    
    weak var delegate: UserTableViewCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    @IBAction func followButtonClick(_ sender: Any) {
        if let delegate = delegate {
            delegate.userCellFollowButtonPressed(sender: self)
        }

    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
