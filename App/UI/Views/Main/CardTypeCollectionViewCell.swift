//
//  CardTypeCollectionViewCell.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 12.05.2020.
//  Copyright © 2020 Real Tranzit. All rights reserved.
//

import UIKit

class CardTypeCollectionViewCell : UICollectionViewCell {
    @IBOutlet weak var iconView: UIImageView!
    
    var viewModel: CardTypeViewModel? {
        didSet {
            updateUI()
        }
    }
    
    private func updateUI() {
        guard let viewModel = viewModel else { return }
        
        iconView.image = UIImage(named: viewModel.imageName)
        layer.shouldRasterize = true
        layer.rasterizationScale = UIScreen.main.scale
    }
}
