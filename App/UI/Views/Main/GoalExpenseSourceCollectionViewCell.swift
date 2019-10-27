//
//  GoalExpenseSourceCollectionViewCell.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 25/01/2019.
//  Copyright © 2019 Real Tranzit. All rights reserved.
//

import UIKit
import AlamofireImage
import CircleProgressView

class GoalExpenseSourceCollectionViewCell : ExpenseSourceCollectionViewCell {
    @IBOutlet weak var progressView: CircleProgressView!
        
    override func updateUI() {
        super.updateUI()
        
        guard let viewModel = viewModel else { return }
        
        func iconTintColor() -> UIColor {
            if viewModel.isGoalCompleted {
                return UIColor.by(.blue6B93FB)
            }
            return UIColor.by(.textFFFFFF)
        }
        
        func centerFillColor() -> UIColor {
            if viewModel.isGoalCompleted {
                return UIColor.by(.textFFFFFF)
            }
            
            return UIColor.by(.blue6B93FB)
        }
        
        func trackFillColor() -> UIColor {
            return UIColor.by(.textFFFFFF)
        }
        
        iconImageView.tintColor = iconTintColor()
        
        progressView.progress = viewModel.goalProgress
        progressView.centerFillColor = centerFillColor()
        progressView.trackFillColor = trackFillColor()
        progressView.trackBackgroundColor = trackFillColor().withAlphaComponent(0.3)
    }        
}
