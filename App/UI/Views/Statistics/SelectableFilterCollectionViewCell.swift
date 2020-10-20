//
//  SelectableFilterCollectionViewCell.swift
//  Capitalist
//
//  Created by Alexander Petropavlovsky on 03/04/2019.
//  Copyright © 2019 Real Tranzit. All rights reserved.
//

import UIKit

class SelectableFilterCollectionViewCell : UICollectionViewCell {
    @IBOutlet weak var filterTitleLabel: UILabel!
    @IBOutlet weak var selectionIndicator: UIImageView!
    
    var viewModel: SelectableTransactionableFilter? {
        didSet {
            updateUI()
        }
    }
    
    func updateUI() {
        guard let viewModel = viewModel else { return }        
        filterTitleLabel.text = viewModel.title
        selectionIndicator.isHidden = !viewModel.isSelected
    }
}
