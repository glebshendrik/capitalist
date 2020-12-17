//
//  ClearFiltersTableViewCell.swift
//  Capitalist
//
//  Created by Alexander Petropavlovsky on 19.11.2020.
//  Copyright © 2020 Real Tranzit. All rights reserved.
//

import UIKit

protocol ClearFiltersTableViewCellDelegate : class {
    func didTapClearFilters()
}

class ClearFiltersTableViewCell : UITableViewCell {
            
    @IBOutlet weak var clearFiltersButton: UIButton!
        
    weak var delegate: ClearFiltersTableViewCellDelegate? = nil
    
    var filtersNumber: Int = 0 {
        didSet {
            updateUI()
        }
    }
    
    private var clearFiltersButtonTitle: String {
        let clearFiltersText = NSLocalizedString("Очистить фильтры", comment: "")
        guard
            filtersNumber > 0
        else {
            return clearFiltersText
        }
        return "\(clearFiltersText) (\(filtersNumber))"
    }
    
    private func updateUI() {
        clearFiltersButton.setTitle(clearFiltersButtonTitle, for: .normal)
    }
    
    @IBAction func didTapClearFiltersButton(_ sender: Any) {
        delegate?.didTapClearFilters()
    }
}
