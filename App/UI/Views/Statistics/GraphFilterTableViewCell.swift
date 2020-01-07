//
//  GraphFilterTableViewCell.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 18/04/2019.
//  Copyright © 2019 Real Tranzit. All rights reserved.
//

import UIKit
import AlamofireImage

class GraphFilterTableViewCell : UITableViewCell {
    
    @IBOutlet weak var iconImage: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var percentLabel: UILabel!
    @IBOutlet weak var valueLabel: UILabel!
    @IBOutlet weak var progressView: UIView!
    @IBOutlet weak var progressViewWidthConstraint: NSLayoutConstraint!
    
    var viewModel: GraphTransactionFilter? = nil {
        didSet {
            updateUI()
        }
    }
        
    private func updateUI() {
        guard let viewModel = viewModel else { return }
        
        iconImage.setImage(with: viewModel.iconURL, placeholderName: viewModel.iconPlaceholder, renderingMode: .alwaysTemplate)
        iconImage.tintColor = viewModel.coloringType == .icon ? viewModel.color : UIColor.by(.white100)
                
        titleLabel.text = viewModel.title
        valueLabel.text = viewModel.amountFormatted
        percentLabel.text = viewModel.percentsFormatted
        progressView.backgroundColor = viewModel.coloringType == .progress ? viewModel.color : UIColor.by(.white4)
        
        UIView.animate(withDuration: 0.2, delay: 0, options: [.curveEaseOut], animations: {
            self.progressViewWidthConstraint = self.progressViewWidthConstraint.setMultiplier(multiplier: CGFloat(viewModel.percents.doubleValue / 100.0))
            self.contentView.layoutIfNeeded()

        }, completion: nil)
        
        layer.shouldRasterize = true
        layer.rasterizationScale = UIScreen.main.scale
    }
}
