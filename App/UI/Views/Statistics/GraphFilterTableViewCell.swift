//
//  GraphFilterTableViewCell.swift
//  Capitalist
//
//  Created by Alexander Petropavlovsky on 18/04/2019.
//  Copyright © 2019 Real Tranzit. All rights reserved.
//

import UIKit
import AlamofireImage

class GraphFilterTableViewCell : UITableViewCell {
    
    @IBOutlet weak var iconView: IconView!
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
        
        iconView.iconURL = viewModel.iconURL
        iconView.defaultIconName = viewModel.iconPlaceholder
        iconView.iconTintColor = viewModel.coloringType == .icon ? viewModel.color : UIColor.by(.white100)
        iconView.vectorBackgroundViewColor = viewModel.coloringType == .icon ? viewModel.color : UIColor.by(.white100)
        iconView.vectorIconMode = .medium
        
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
