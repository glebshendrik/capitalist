//
//  CurrencyCollectionViewCell.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 10/02/2019.
//  Copyright © 2019 Real Tranzit. All rights reserved.
//

import UIKit

class CurrencyCollectionViewCell : UICollectionViewCell {
    @IBOutlet weak var codeLabel: UILabel!
    
    var viewModel: CurrencyViewModel? {
        didSet {
            updateUI()
        }
    }
    
    func updateUI() {
        codeLabel.text = viewModel?.code
        
        layer.shouldRasterize = true
        layer.rasterizationScale = UIScreen.main.scale
    }
}