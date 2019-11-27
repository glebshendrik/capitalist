//
//  IconInfoTableViewCell.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 13.11.2019.
//  Copyright © 2019 Real Tranzit. All rights reserved.
//

import UIKit
import SVGKit
import SDWebImageSVGCoder
import AlamofireImage

protocol IconInfoTableViewCellDelegate : EntityInfoTableViewCellDelegate {
    func didTapIcon(field: IconInfoField?)
}

class IconInfoTableViewCell : EntityInfoTableViewCell {
    @IBOutlet weak var iconBackgroundView: UIView!
    @IBOutlet weak var iconBackgroundImageView: UIImageView!
    @IBOutlet weak var rasterImageView: UIImageView!
    @IBOutlet weak var vectorImageView: SVGKFastImageView!
    @IBOutlet weak var pencilImageView: UIImageView!
    
    var iconDelegate: IconInfoTableViewCellDelegate? {
        return delegate as? IconInfoTableViewCellDelegate
    }
    
    var iconField: IconInfoField? {
        return field as? IconInfoField
    }
    
    override func updateUI() {
        guard let field = iconField else { return }
        pencilImageView.isHidden = false
        rasterImageView.isHidden = field.iconType != .raster
        vectorImageView.isHidden = field.iconType != .vector
        rasterImageView.setImage(with: field.iconURL, placeholderName: field.placeholder, renderingMode: .alwaysTemplate)
        rasterImageView.tintColor = UIColor.by(.textFFFFFF)
        vectorImageView.sd_setImage(with: field.iconURL, completed: nil)
        if let backgroundImageName = field.backgroundImageName {
            iconBackgroundImageView.image = UIImage(named: backgroundImageName)
        }
        else {
            iconBackgroundImageView.image = nil
        }
    }
    
    @IBAction func didTapIcon(_ sender: Any) {
        iconDelegate?.didTapIcon(field: iconField)
    }
}
