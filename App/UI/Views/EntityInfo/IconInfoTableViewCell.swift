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
    @IBOutlet weak var iconView: IconView!
    
    var iconDelegate: IconInfoTableViewCellDelegate? {
        return delegate as? IconInfoTableViewCellDelegate
    }
    
    var iconField: IconInfoField? {
        return field as? IconInfoField
    }
    
    override func updateUI() {
        guard let field = iconField else { return }
        
        iconView.iconType = field.iconType
        iconView.vectorIconMode = .fullsize
        iconView.iconURL = field.iconURL
        iconView.defaultIconName = field.placeholder
        iconView.iconTintColor = UIColor.by(.white100)
        iconView.backgroundViewColor = field.backgroundColor
    }
    
    @IBAction func didTapIcon(_ sender: Any) {
        iconDelegate?.didTapIcon(field: iconField)
    }
}
