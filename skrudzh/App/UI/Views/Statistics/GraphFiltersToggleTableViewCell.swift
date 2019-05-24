//
//  GraphFiltersToggleTableViewCell.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 18/04/2019.
//  Copyright © 2019 Real Tranzit. All rights reserved.
//

import UIKit

protocol GraphFiltersToggleDelegate {
    func didTapFiltersToggleButton()
}

class GraphFiltersToggleTableViewCell : UITableViewCell {
    @IBOutlet weak var toggleButton: UIButton!
    
    var delegate: GraphFiltersToggleDelegate?
    
    var viewModel: GraphViewModel? = nil {
        didSet {
            updateUI()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        toggleButton.setImageToRight()
    }
    
    @IBAction func didTapToggleButton(_ sender: Any) {
        delegate?.didTapFiltersToggleButton()
    }
    
    private func updateUI() {
        guard let viewModel = viewModel else { return }        
        toggleButton.setImage(UIImage(named: viewModel.filtersToggleImageName), for: .normal)
        toggleButton.setTitle(viewModel.filtersToggleText, for: .normal)
    }
}
