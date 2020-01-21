//
//  ExpenseSourceTableViewCell.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 14/03/2019.
//  Copyright © 2019 Real Tranzit. All rights reserved.
//

import UIKit

class ExpenseSourceTableViewCell : UITableViewCell {
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var iconImageView: UIImageView!
    
    var placeholderName: String {
        return "expense-source-default-icon"
    }
    
    var imageTintColor: UIColor {        
        return UIColor.by(.white100)
    }
    
    var viewModel: ExpenseSourceViewModel? {
        didSet {
            updateUI()
        }
    }
    
    func updateUI() {
        nameLabel.text = viewModel?.name
        amountLabel.text = viewModel?.amountRounded
        iconImageView.setImage(with: viewModel?.iconURL,
                               placeholderName: placeholderName,
                               renderingMode: .alwaysTemplate)
        iconImageView.tintColor = imageTintColor
    }    
}

