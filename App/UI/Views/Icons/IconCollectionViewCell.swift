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
    @IBOutlet weak var iconImageView: UIImageView!
    
    var viewModel: IconViewModel? {
        didSet {
            updateUI()
        }
    }
    
    func updateUI() {
        guard let viewModel = viewModel else { return }
        
        iconImageView.setImage(with: viewModel.url, placeholderName: viewModel.category.defaultIconName, renderingMode: .alwaysTemplate)
        iconImageView.tintColor = UIColor.by(.textFFFFFF)
        layer.shouldRasterize = true
        layer.rasterizationScale = UIScreen.main.scale        
    }
}
