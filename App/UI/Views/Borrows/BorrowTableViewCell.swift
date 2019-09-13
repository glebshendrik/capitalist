//
//  BorrowTableViewCell.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 12/09/2019.
//  Copyright © 2019 Real Tranzit. All rights reserved.
//

import Foundation
import AlamofireImage

class BorrowTableViewCell : UITableViewCell {
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var borrowedAtLabel: UILabel!
    @IBOutlet weak var paydayLabel: UILabel!
    
    var placeholderName: String {
        return IconCategory.expenseSourceDebt.defaultIconName
    }
    
    var imageTintColor: UIColor {
        return UIColor.by(.textFFFFFF)
    }
    
    var viewModel: BorrowViewModel? {
        didSet {
            updateUI()
        }
    }
    
    func updateUI() {
        nameLabel.text = viewModel?.name
        amountLabel.text = viewModel?.diplayAmount
        iconImageView.setImage(with: viewModel?.iconURL,
                               placeholderName: placeholderName,
                               renderingMode: .alwaysTemplate)
        iconImageView.tintColor = imageTintColor
        borrowedAtLabel.text = viewModel?.borrowedAtFormatted
        paydayLabel.text = viewModel?.paydayText
    }
}
