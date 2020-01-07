    //
//  EntityTransactionTableViewCell.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 25.11.2019.
//  Copyright © 2019 Real Tranzit. All rights reserved.
//

import UIKit
import SVGKit
import SDWebImageSVGCoder

class EntityTransactionTableViewCell : TransactionTableViewCell {
    @IBOutlet weak var iconBackgroundView: UIView!
    @IBOutlet weak var iconBackgroundImageView: UIImageView!
    @IBOutlet weak var rasterImageView: UIImageView!
    @IBOutlet weak var vectorImageView: SVGKFastImageView!
    
    override func updateIconUI(url: URL?, placeholder: String?) {
        guard let viewModel = viewModel else { return }
        
        let isVector = false
        rasterImageView.isHidden = isVector
        vectorImageView.isHidden = !isVector
        rasterImageView.setImage(with: url, placeholderName: placeholder, renderingMode: .alwaysTemplate)
        rasterImageView.tintColor = UIColor.by(.gray1)
        vectorImageView.sd_setImage(with: url, completed: nil)
        if let backgroundImageName = viewModel.iconBackgroundImageName {
            iconBackgroundImageView.image = UIImage(named: backgroundImageName)
        }
        else {
            iconBackgroundImageView.image = nil
        }
        
    }
}
