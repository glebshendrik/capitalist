//
//  TransactionTableViewCell.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 27/03/2019.
//  Copyright © 2019 Real Tranzit. All rights reserved.
//

import UIKit

class TransactionTableViewCell : UITableViewCell {
    @IBOutlet weak var destinationIconImageView: UIImageView!
    @IBOutlet weak var sourceTitleLabel: UILabel!
    @IBOutlet weak var destinationTitleLabel: UILabel!
    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var delimeter: UIView?
    
    var viewModel: TransactionViewModel? {
        didSet {
            updateUI()
        }
    }
    
    private func  updateUI() {
        guard let viewModel = viewModel else { return }
        
        delimeter?.alpha = 0.3
                
        updateIconUI(url: viewModel.destinationIconURL,
                     placeholder: viewModel.destinationType.defaultIconName(basketType: viewModel.basketType))
        
        sourceTitleLabel.text = viewModel.sourceTitle
        destinationTitleLabel.text = viewModel.destinationTitle
        amountLabel.text = viewModel.amount
        
        layer.shouldRasterize = true
        layer.rasterizationScale = UIScreen.main.scale
    }
    
    func updateIconUI(url: URL?, placeholder: String?) {
        destinationIconImageView.setImage(with: url,
                                          placeholderName: placeholder,
                                          renderingMode: .alwaysTemplate)
    }
}

