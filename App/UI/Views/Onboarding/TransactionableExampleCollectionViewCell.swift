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
    @IBOutlet weak var iconView: IconView!
    @IBOutlet weak var selectionIndicator: UIView!
    
    var viewModel: TransactionableExampleViewModel? {
        didSet {
            updateUI()
        }
    }
    
    private func updateUI() {
        guard let viewModel = viewModel else { return }
        
        nameLabel.text = viewModel.name
        iconView.defaultIconName = viewModel.defaultIconName
        iconView.iconURL = viewModel.iconURL
        selectionIndicator.alpha = viewModel.selected ? 1.0 : 0.0
    }
}
