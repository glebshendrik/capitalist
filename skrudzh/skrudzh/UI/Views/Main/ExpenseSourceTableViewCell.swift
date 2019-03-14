//
//  ExpenseSourceTableViewCell.swift
//  skrudzh
//
//  Created by Alexander Petropavlovsky on 14/03/2019.
//  Copyright © 2019 rubikon. All rights reserved.
//

import UIKit

class ExpenseSourceTableViewCell : UITableViewCell {
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var iconImageView: UIImageView!
    
    var placeholderName: String {
        return "wallet-default-icon"
    }
    
    var imageTintColor: UIColor {
        return UIColor(red: 105 / 255.0, green: 145 / 255.0, blue: 250 / 255.0, alpha: 1)
    }
    
    var viewModel: ExpenseSourceViewModel? {
        didSet {
            updateUI()
        }
    }
    
    func updateUI() {
        nameLabel.text = viewModel?.name
        amountLabel.text = viewModel?.amount
        iconImageView.setImage(with: viewModel?.iconURL, placeholderName: placeholderName, renderingMode: .alwaysTemplate)
        iconImageView.tintColor = imageTintColor
    }    
}

