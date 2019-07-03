//
//  ProviderCell.swift
//  Three Baskets
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
    @IBOutlet weak var logoImageView: SVGKFastImageView!
    
    var viewModel: ProviderViewModel? = nil {
        didSet {
            updateUI()
        }
    }
    
    private func updateUI() {
        titleLabel.text = viewModel?.name
        logoImageView.sd_setImage(with: viewModel?.logoURL, completed: nil)
    }
}

