//
//  PostTableViewCell.swift
//  snapshare
//
//  Created by Francisco San Emeterio on 6/27/17.
//  Copyright © 2017 Vinfranryia. All rights reserved.
//

import UIKit

class PostTableViewCell: UITableViewCell {

    @IBOutlet weak var userText: UILabel!
    @IBOutlet weak var postImage: UIImageView!
   
    var tapAction: ((PostTableViewCell) -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func likeButtonPressed(_ sender: UIButton) {
        tapAction?(self)
    }

}
