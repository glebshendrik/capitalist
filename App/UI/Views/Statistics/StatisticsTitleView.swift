//
//  StatisticsTitleView.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 28/03/2019.
//  Copyright © 2019 Real Tranzit. All rights reserved.
//

import UIKit

protocol StatisticsTitleViewDelegate {
    func didTapTitle()
}

class StatisticsTitleView : CustomView {
    @IBOutlet weak var titleLabel: UILabel!
    
    var delegate: StatisticsTitleViewDelegate?
    
    var dateRangeFilter: DateRangeTransactionFilter? {
        didSet {
            updateUI()
        }
    }
    
    @IBAction func didTapTitleButton(_ sender: Any) {
        delegate?.didTapTitle()
    }
    
    func updateUI() {
        UIView.transition(with: titleLabel,
             duration: 0.25,
              options: .transitionCrossDissolve,
           animations: { [weak self] in
               self?.titleLabel.text = self?.dateRangeFilter?.title.capitalized
        }, completion: nil)
    }
}
