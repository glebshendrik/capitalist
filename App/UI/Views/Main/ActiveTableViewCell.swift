//
//  ActiveTableViewCell.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 23/10/2019.
//  Copyright © 2019 Real Tranzit. All rights reserved.
//

import UIKit
import SwipeCellKit

class ActiveTableViewCell : SwipeTableViewCell {
    @IBOutlet weak var iconView: IconView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var costLabel: UILabel!
    
    var viewModel: ActiveViewModel? {
        didSet {
            updateUI()
        }
    }
    
    func updateUI() {
        guard let viewModel = viewModel else { return }
                
        nameLabel.text = viewModel.name
        costLabel.text = viewModel.costRounded
        
        iconView.iconType = viewModel.iconType
        iconView.vectorIconMode = .fullsize
        iconView.iconURL = viewModel.iconURL
        iconView.defaultIconName = viewModel.defaultIconName
        iconView.backgroundViewColor = viewModel.basketType.iconBackgroundColor
    }
}
