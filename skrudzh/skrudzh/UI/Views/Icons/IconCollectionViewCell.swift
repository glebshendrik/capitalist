//
//  IconCollectionViewCell.swift
//  skrudzh
//
//  Created by Alexander Petropavlovsky on 28/12/2018.
//  Copyright © 2018 rubikon. All rights reserved.
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
        iconImageView.setImage(with: viewModel?.url, placeholderName: "smile-icon")
        layer.shouldRasterize = true
        layer.rasterizationScale = UIScreen.main.scale        
    }
}
