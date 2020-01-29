//
//  TransactionableExampleCollectionViewCell.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 21.01.2020.
//  Copyright © 2020 Real Tranzit. All rights reserved.
//

import UIKit

class TransactionableExampleCollectionViewCell : UICollectionViewCell {
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var selectionIndicator: UIView!
    
    var viewModel: TransactionableExampleViewModel? {
        didSet {
            updateUI()
        }
    }
    
    private func updateUI() {
        guard let viewModel = viewModel else { return }
        
        nameLabel.text = viewModel.name
        iconImageView.setImage(with: viewModel.iconURL, placeholderName: viewModel.defaultIconName, renderingMode: .alwaysTemplate)
        iconImageView.tintColor = UIColor.by(.white100)
        selectionIndicator.alpha = viewModel.selected ? 1.0 : 0.0
    }
}
