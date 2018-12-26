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
        iconImageView.af_cancelImageRequest()
        let placeholderImage = UIImage(named: "wallet-icon")
        if let iconURL = viewModel?.iconURL {
            iconImageView.af_setImage(withURL: iconURL,
                                      placeholderImage: placeholderImage,
                                      filter: nil,
                                      progress: nil,
                                      progressQueue: DispatchQueue.main,
                                      imageTransition: UIImageView.ImageTransition.crossDissolve(0.3),
                                      runImageTransitionIfCached: false,
                                      completion: nil)
        }
        else {
            iconImageView.image = placeholderImage
        }
    }
}


