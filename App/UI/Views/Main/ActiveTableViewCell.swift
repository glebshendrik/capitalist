//
//  ActiveTableViewCell.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 23/10/2019.
//  Copyright © 2019 Real Tranzit. All rights reserved.
//

import UIKit

class ActiveTableViewCell : UITableViewCell {
    
    @IBOutlet weak var backgroundImage: UIImageView!
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var costLabel: UILabel!
    
    var viewModel: ActiveViewModel? {
        didSet {
            updateUI()
        }
    }
    
    func updateUI() {
        guard let viewModel = viewModel else { return }
                
        nameLabel.text = viewModel.name
        costLabel.text = viewModel.costRounded
        iconImageView.setImage(with: viewModel.iconURL,
                               placeholderName: viewModel.defaultIconName,
                               renderingMode: .alwaysTemplate)
        iconImageView.tintColor = UIColor.by(.textFFFFFF)
        backgroundImage.image = UIImage.init(named: viewModel.iconBackgroundImageName)
    }
}
