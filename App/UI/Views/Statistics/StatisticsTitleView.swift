//
//  StatisticsTitleView.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 28/03/2019.
//  Copyright © 2019 Real Tranzit. All rights reserved.
//

import UIKit

protocol StatisticsTitleViewDelegate {
    func didTapRemoveDateRangeButton()
}

class StatisticsTitleView : CustomView {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var dateRangeLabel: UILabel!
    @IBOutlet weak var removeDateRangeButton: UIButton!
    
    var delegate: StatisticsTitleViewDelegate?
    var dateRangeFilter: DateRangeTransactionFilter? {
        didSet {
            updateUI()
        }
    }
    
    @IBAction func didTapRemoveRangeButton(_ sender: Any) {
        delegate?.didTapRemoveDateRangeButton()
    }
    
    func updateUI() {
        dateRangeLabel.text = dateRangeFilter?.title
        removeDateRangeButton.isHidden = dateRangeFilter == nil
    }
}
