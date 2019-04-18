//
//  GraphTotalTableViewCell.swift
//  skrudzh
//
//  Created by Alexander Petropavlovsky on 18/04/2019.
//  Copyright © 2019 rubikon. All rights reserved.
//

import UIKit

class GraphTotalTableViewCell : UITableViewCell {
    @IBOutlet weak var aggregatedValueLabel: UILabel!
    @IBOutlet weak var valueLabel: UILabel!
    
    var viewModel: GraphViewModel? = nil {
        didSet {
            updateUI()
        }
    }
    
    private func updateUI() {
        guard let viewModel = viewModel else { return }
        
        
    }
}
