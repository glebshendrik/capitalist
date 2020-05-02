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
    @IBOutlet weak var iconView: IconView!    
    
    var placeholderName: String {
        return "expense-source-default-icon"
    }
        
    var viewModel: ExpenseSourceViewModel? {
        didSet {
            updateUI()
        }
    }
    
    func updateUI() {
        guard let viewModel = viewModel else { return }
        
        nameLabel.text = viewModel.name
        amountLabel.text = viewModel.amountRounded
        
        iconView.iconType = viewModel.iconType
        iconView.vectorIconMode = .fullsize
        iconView.iconURL = viewModel.iconURL
        iconView.defaultIconName = viewModel.defaultIconName
        iconView.backgroundViewColor = UIColor.by(.gray1)
        iconView.iconTintColor = UIColor.by(.white100)
    }
}

