//
//  FilterCollectionViewCell.swift
//  skrudzh
//
//  Created by Alexander Petropavlovsky on 28/03/2019.
//  Copyright © 2019 rubikon. All rights reserved.
//

import UIKit

protocol FilterCellDelegate {
    func didTapDeleteButton(filter: SourceOrDestinationHistoryTransactionFilter)
}

class FilterCollectionViewCell : UICollectionViewCell {
    @IBOutlet weak var nameLabel: UILabel!
    
    var delegate: FilterCellDelegate?
    
    var viewModel: SourceOrDestinationHistoryTransactionFilter? {
        didSet {
            updateUI()
        }
    }
    
    func updateUI() {
        nameLabel.text = viewModel?.title
    }
    
    @IBAction func didTapDeleteButton(_ sender: Any) {
        guard let filter = viewModel else { return }
        delegate?.didTapDeleteButton(filter: filter)
    }
}
