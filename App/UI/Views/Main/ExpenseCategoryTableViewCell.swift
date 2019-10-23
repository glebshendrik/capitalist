//
//  ExpenseCategoryTableViewCell.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 14/03/2019.
//  Copyright © 2019 Real Tranzit. All rights reserved.
//

import UIKit

class ExpenseCategoryTableViewCell : UITableViewCell {
    
    @IBOutlet weak var backgroundImage: UIImageView!
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var spentLabel: UILabel!
    
    var viewModel: ExpenseCategoryViewModel? {
        didSet {
            updateUI()
        }
    }
    
    func updateUI() {
        guard let viewModel = viewModel else { return }
                
        nameLabel.text = viewModel.name
        spentLabel.text = viewModel.spentRounded
        iconImageView.setImage(with: viewModel.iconURL,
                               placeholderName: viewModel.expenseCategory.basketType.iconCategory.defaultIconName,
                               renderingMode: .alwaysTemplate)
        iconImageView.tintColor = UIColor.by(.textFFFFFF)
        backgroundImage.image = UIImage.init(named: viewModel.expenseCategory.basketType.defaultIconBackground)
    }
}
