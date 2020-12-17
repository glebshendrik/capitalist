//
//  TransactionTableViewCell.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 27/03/2019.
//  Copyright © 2019 Real Tranzit. All rights reserved.
//

import UIKit
import SwipeCellKit

class TransactionTableViewCell : SwipeTableViewCell {
    
    @IBOutlet weak var iconView: IconView!
    @IBOutlet weak var sourceTitleLabel: UILabel!
    @IBOutlet weak var destinationTitleLabel: UILabel!
    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var delimeter: UIView?
    @IBOutlet weak var typeLabel: UILabel!
    @IBOutlet weak var commentLabel: UILabel!
    @IBOutlet weak var bankTransactionIndicatorContainer: UIView!
    @IBOutlet weak var bankTransactionIndicator: UIImageView!
    
    var viewModel: TransactionViewModel? {
        didSet {
            updateUI()
        }
    }
    
    private func  updateUI() {
        guard let viewModel = viewModel else { return }
        
        delimeter?.alpha = 0.3
                                
        iconView.vectorIconMode = .medium
        iconView.iconURL = viewModel.iconURL
        iconView.defaultIconName = viewModel.iconPlaceholder
        iconView.backgroundViewColor = .clear
        iconView.iconTintColor = UIColor.by(.gray1)
        
        sourceTitleLabel.text = viewModel.title
        destinationTitleLabel.text = viewModel.subtitle
        amountLabel.text = viewModel.amount
        
        typeLabel.text = viewModel.typeDescription
        commentLabel.text = viewModel.comment
        typeLabel.textColor = UIColor.by(viewModel.typeDescriptionColorAsset)
        
        bankTransactionIndicatorContainer.isHidden = viewModel.remoteIndicatorHidden
        if  let bankTransactionIndicatorName = viewModel.remoteIndicatorName,
            let bankTransactionIndicatorColor = viewModel.remoteIndicatorColor {
            
            bankTransactionIndicator.image = UIImage(named: bankTransactionIndicatorName)
            bankTransactionIndicator.tintColor = UIColor.by(bankTransactionIndicatorColor)
        }
        else {
            bankTransactionIndicator.image = nil
        }
        
        layer.shouldRasterize = true
        layer.rasterizationScale = UIScreen.main.scale
    }
}

