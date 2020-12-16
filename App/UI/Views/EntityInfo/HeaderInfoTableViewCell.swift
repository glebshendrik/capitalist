//
//  HeaderInfoTableViewCell.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 22.05.2020.
//  Copyright © 2020 Real Tranzit. All rights reserved.
//

import UIKit

protocol HeaderInfoTableViewCellDelegate : EntityInfoTableViewCellDelegate {
    func didTapIcon(field: IconInfoField?)
}

class CombinedInfoTableViewCell : EntityInfoTableViewCell {
    @IBOutlet weak var iconView: IconView!
    @IBOutlet weak var headerLabelsStackView: UIStackView!
    @IBOutlet weak var mainValueLabel: UILabel!
    @IBOutlet weak var mainValueTitleLabel: UILabel!
    @IBOutlet weak var subLabelsStackView: UIStackView!
    @IBOutlet weak var firstSubLabelsView: UIView!
    @IBOutlet weak var firstSubValueLabel: UILabel!
    @IBOutlet weak var firstSubTitleLabel: UILabel!
    @IBOutlet weak var secondSubLabelsView: UIView!
    @IBOutlet weak var secondSubValueLabel: UILabel!
    @IBOutlet weak var secondSubTitleLabel: UILabel!
    
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

