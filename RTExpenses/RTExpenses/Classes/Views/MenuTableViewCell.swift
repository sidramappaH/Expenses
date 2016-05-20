//
//  MenuTableViewCell.swift
//  RTExpenses
//
//  Created by Sidramappa Halake  on 01/05/16.
//  Copyright © 2016 Robosoft. All rights reserved.
//

import UIKit

class MenuTableViewCell: UITableViewCell {
    
    @IBOutlet private  weak var menuImageView: UIImageView!
    @IBOutlet private weak var nameLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    func configureCell(forName name: String, iconName: String) {
        nameLabel.text = name
        menuImageView.image = UIImage(named: iconName)
    }
}
