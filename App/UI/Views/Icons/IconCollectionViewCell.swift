//
//  IconCollectionViewCell.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 28/12/2018.
//  Copyright © 2018 Real Tranzit. All rights reserved.
//

import UIKit
import AlamofireImage

class IconCollectionViewCell : UICollectionViewCell {
    @IBOutlet weak var iconView: IconView!
    
    var viewModel: IconViewModel? {
        didSet {
            updateUI()
        }
    }
    
    func updateUI() {
        guard let viewModel = viewModel else { return }
        
        iconView.iconURL = viewModel.url
        iconView.defaultIconName = viewModel.category.defaultIconName
        iconView.backgroundViewColor = UIColor.by(.black1)
        iconView.iconTintColor = UIColor.by(.white100)
        iconView.iconType = .raster

        layer.shouldRasterize = true
        layer.rasterizationScale = UIScreen.main.scale        
    }
}
