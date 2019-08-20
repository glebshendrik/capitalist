//
//  ExpenseSourceCollectionViewCell.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 26/12/2018.
//  Copyright © 2018 Real Tranzit. All rights reserved.
//

import UIKit
import AlamofireImage
import CircleProgressView

class ExpenseSourceCollectionViewCell : EditableCell {
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var iconImageView: UIImageView!
        
    var imageTintColor: UIColor {
        return UIColor.by(.textFFFFFF)
    }
    
    var viewModel: ExpenseSourceViewModel? {
        didSet {
            updateUI()
        }
    }
    
    func updateUI() {
        nameLabel.text = viewModel?.name
        amountLabel.text = viewModel?.amountRounded
        iconImageView.setImage(with: viewModel?.iconURL, placeholderName: viewModel?.defaultIconName, renderingMode: .alwaysTemplate)
        iconImageView.tintColor = imageTintColor
    }    
    
}
