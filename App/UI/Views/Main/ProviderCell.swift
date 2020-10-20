//
//  ProviderCell.swift
//  Capitalist
//
//  Created by Alexander Petropavlovsky on 28/06/2019.
//  Copyright © 2019 Real Tranzit. All rights reserved.
//

import UIKit
import SVGKit
import SaltEdge
import SDWebImageSVGCoder

class ProviderCell : UITableViewCell {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var iconView: IconView!
    
    var viewModel: ProviderViewModel? = nil {
        didSet {
            updateUI()
        }
    }
    
    private func updateUI() {
        guard let viewModel = viewModel else { return }
        
        titleLabel.text = viewModel.name
        
        iconView.vectorIconMode = .fullsize
        iconView.iconURL = viewModel.logoURL        
    }
}

