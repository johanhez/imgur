//
//  PictureTableViewCell.swift
//  imgur
//
//  Created by Johan Hernandez on 4/10/18.
//  Copyright © 2018 Johan Hernandez. All rights reserved.
//

import UIKit

class PictureTableViewCell: UITableViewCell {

    @IBOutlet weak var title_label: UILabel!
    @IBOutlet weak var main_picture_imageview: UIImageView!
    @IBOutlet weak var date_of_post_label: UILabel!
    @IBOutlet weak var number_of_pics_label: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
