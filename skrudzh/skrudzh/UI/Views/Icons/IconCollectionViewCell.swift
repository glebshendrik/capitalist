//
//  IconCollectionViewCell.swift
//  skrudzh
//
//  Created by Alexander Petropavlovsky on 28/12/2018.
//  Copyright © 2018 rubikon. All rights reserved.
//

import UIKit
import AlamofireImage

class IconCollectionViewCell : UICollectionViewCell {
    @IBOutlet weak var iconImageView: UIImageView!
    
    var viewModel: IconViewModel? {
        didSet {
            updateUI()
        }
    }
    
    func updateUI() {
        iconImageView.af_cancelImageRequest()
        let placeholderImage = UIImage(named: "wallet-icon")
        if let iconURL = viewModel?.url {
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
