//
//  StatisticsTitleView.swift
//  skrudzh
//
//  Created by Alexander Petropavlovsky on 28/03/2019.
//  Copyright © 2019 rubikon. All rights reserved.
//

import UIKit

protocol StatisticsTitleViewDelegate {
    func didTapRemoveRangeButton()
}

class StatisticsTitleView : NavigationBarCustomTitleView {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var dateRangeLabel: UILabel!
    @IBOutlet weak var removeDateRangeButton: UIButton!
    
    var delegate: StatisticsTitleViewDelegate?
    var dateRangeFilter: DateRangeHistoryTransactionFilter? {
        didSet {
            updateUI()
        }
    }
    
    @IBAction func didTapRemoveRangeButton(_ sender: Any) {
        delegate?.didTapRemoveRangeButton()
    }
    
    func updateUI() {
        dateRangeLabel.text = dateRangeFilter?.title
        removeDateRangeButton.isHidden = dateRangeFilter == nil
    }
}
