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
    @IBOutlet weak var typeLabel: UILabel!
    @IBOutlet weak var commentLabel: UILabel!
    
    var viewModel: TransactionViewModel? {
        didSet {
            updateUI()
        }
    }
    
    private func  updateUI() {
        guard let viewModel = viewModel else { return }
        
        delimeter?.alpha = 0.3
                
        updateIconUI(url: viewModel.iconURL,
                     placeholder: viewModel.iconPlaceholder)
        
        sourceTitleLabel.text = viewModel.title
        destinationTitleLabel.text = viewModel.subtitle
        amountLabel.text = viewModel.amount
        
        typeLabel.text = viewModel.typeDescription
        commentLabel.text = viewModel.comment
        
        layer.shouldRasterize = true
        layer.rasterizationScale = UIScreen.main.scale
    }
    
    func updateIconUI(url: URL?, placeholder: String?) {
        destinationIconImageView.setImage(with: url,
                                          placeholderName: placeholder,
                                          renderingMode: .alwaysTemplate)
    }
}

