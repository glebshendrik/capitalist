//
//  ExpenseCategoryCollectionViewCell.swift
//  skrudzh
//
//  Created by Alexander Petropavlovsky on 17/01/2019.
//  Copyright © 2019 rubikon. All rights reserved.
//

import UIKit
import AlamofireImage

class ExpenseCategoryCollectionViewCell : UICollectionViewCell {
    
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var iconContainerView: UIView!
    @IBOutlet weak var iconProgressView: UIView!
    @IBOutlet weak var iconBackgroundView: UIView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var monthlySpentLabel: UILabel!
    @IBOutlet weak var monthlyPlannedLabel: UILabel!
    
    var viewModel: ExpenseSourceViewModel? {
        didSet {
            updateUI()
        }
    }
    
    func updateUI() {
        nameLabel.text = viewModel?.name
        monthlyPlannedLabel.text = viewModel?.amount
        iconImageView.setImage(with: viewModel?.iconURL, placeholderName: "wallet-icon")
    }
}
