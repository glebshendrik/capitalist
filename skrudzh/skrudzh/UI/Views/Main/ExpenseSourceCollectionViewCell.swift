//
//  ExpenseSourceCollectionViewCell.swift
//  skrudzh
//
//  Created by Alexander Petropavlovsky on 26/12/2018.
//  Copyright © 2018 rubikon. All rights reserved.
//

import UIKit
import AlamofireImage

class ExpenseSourceCollectionViewCell : UICollectionViewCell {
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var iconImageView: UIImageView!
    
    var viewModel: ExpenseSourceViewModel? {
        didSet {
            updateUI()
        }
    }
    
    func updateUI() {
        nameLabel.text = viewModel?.name
        amountLabel.text = viewModel?.amount
        iconImageView.setImage(with: viewModel?.iconURL, placeholderName: "wallet-icon")
    }
}


