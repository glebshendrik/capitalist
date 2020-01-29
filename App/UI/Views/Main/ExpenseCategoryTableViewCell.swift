//
//  ExpenseCategoryTableViewCell.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 14/03/2019.
//  Copyright © 2019 Real Tranzit. All rights reserved.
//

import UIKit

class ExpenseCategoryTableViewCell : UITableViewCell {
    
    @IBOutlet weak var iconBackgroundView: UIView!
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
                               placeholderName: viewModel.defaultIconName,
                               renderingMode: .alwaysTemplate)        
        iconImageView.tintColor = UIColor.by(.white100)
        iconBackgroundView.backgroundColor = viewModel.basketType.iconBackgroundColor
    }
}
