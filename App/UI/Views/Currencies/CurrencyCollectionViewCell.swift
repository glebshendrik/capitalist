//
//  CurrencyCollectionViewCell.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 10/02/2019.
//  Copyright © 2019 Real Tranzit. All rights reserved.
//

import UIKit

class CurrencyCollectionViewCell : UICollectionViewCell {
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var symbolLabel: UILabel!
    
    var viewModel: CurrencyViewModel? {
        didSet {
            updateUI()
        }
    }
    
    func updateUI() {
        nameLabel.text = viewModel?.name
        symbolLabel.text = viewModel?.symbol
    }
}
