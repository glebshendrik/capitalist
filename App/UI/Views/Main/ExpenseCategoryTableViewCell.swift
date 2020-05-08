//
//  ExpenseCategoryTableViewCell.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 14/03/2019.
//  Copyright © 2019 Real Tranzit. All rights reserved.
//

import UIKit
import SwipeCellKit

class ExpenseCategoryTableViewCell : SwipeTableViewCell {
    
    @IBOutlet weak var iconView: IconView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var spentLabel: UILabel!
    
    var viewModel: ExpenseCategoryViewModel? {
        didSet {
            updateUI()
        }
    }
    
    func updateUI() {
        guard let viewModel = viewModel else { return }
                
        nameLabel.text = viewModel.name
        spentLabel.text = viewModel.spentRounded
        
        iconView.iconType = .raster
        iconView.vectorIconMode = .fullsize
        iconView.iconURL = viewModel.iconURL
        iconView.defaultIconName = viewModel.defaultIconName
        iconView.backgroundViewColor = viewModel.basketType.iconBackgroundColor
        iconView.iconTintColor = UIColor.by(.white100)
    }
}
