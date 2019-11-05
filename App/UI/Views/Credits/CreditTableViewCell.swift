//
//  CreditTableViewCell.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 26/09/2019.
//  Copyright © 2019 Real Tranzit. All rights reserved.
//

import Foundation
import AlamofireImage

class CreditTableViewCell : UITableViewCell {
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var typeLabel: UILabel!
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var paidAmountLabel: UILabel!
    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var progressFillWidthConstraint: NSLayoutConstraint!
    
    var placeholderName: String {
        return IconCategory.expenseSourceDebt.defaultIconName
    }
    
    var imageTintColor: UIColor {
        return UIColor.by(.textFFFFFF)
    }
    
    var viewModel: CreditViewModel? {
        didSet {
            updateUI()
        }
    }
    
    var paymentsProgress: CGFloat {
        guard let viewModel = viewModel else { return 0.0 }
        return CGFloat(viewModel.paymentsProgress)
    }
    
    func updateUI() {
        nameLabel.text = viewModel?.name
        typeLabel.text = viewModel?.typeName
        paidAmountLabel.text = viewModel?.paidAmount        
        amountLabel.text = viewModel?.returnAmountFormatted
        iconImageView.setImage(with: viewModel?.iconURL,
                               placeholderName: placeholderName,
                               renderingMode: .alwaysTemplate)
        iconImageView.tintColor = imageTintColor
        progressFillWidthConstraint = progressFillWidthConstraint.setMultiplier(multiplier: paymentsProgress)
        contentView.layoutIfNeeded()
    }
}
