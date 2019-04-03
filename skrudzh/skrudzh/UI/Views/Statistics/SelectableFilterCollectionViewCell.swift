//
//  SelectableFilterCollectionViewCell.swift
//  skrudzh
//
//  Created by Alexander Petropavlovsky on 03/04/2019.
//  Copyright © 2019 rubikon. All rights reserved.
//

import UIKit

class SelectableFilterCollectionViewCell : UICollectionViewCell {
    @IBOutlet weak var filterTitleLabel: UILabel!
    @IBOutlet weak var filterContainer: UIView!
    
    var viewModel: SelectableSourceOrDestinationHistoryTransactionFilter? {
        didSet {
            updateUI()
        }
    }
    
    func updateUI() {
        guard let viewModel = viewModel else { return }
        
        filterTitleLabel.text = viewModel.title
        
        let blueColor = UIColor(red: 0.42, green: 0.58, blue: 0.98, alpha: 1)
        let whiteColor = UIColor.white
        
        filterContainer.backgroundColor = viewModel.isSelected ? blueColor : whiteColor
        filterContainer.borderColor = blueColor
        filterTitleLabel.textColor = viewModel.isSelected ? whiteColor : blueColor
    }
}
