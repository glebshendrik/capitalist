//
//  DateRangeCollectionViewCell.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 03/04/2019.
//  Copyright © 2019 Real Tranzit. All rights reserved.
//

import UIKit

protocol DateRangeCollectionViewCellDelegate {
    func didTapFromDate()
    func didTapToDate()
}

class DateRangeCollectionViewCell : UICollectionViewCell {
    @IBOutlet weak var fromDateLabel: UILabel!
    @IBOutlet weak var toDateLabel: UILabel!
    
    private var delegate: DateRangeCollectionViewCellDelegate?
    
    @IBAction func didTapFromDateButton(_ sender: Any) {
        delegate?.didTapFromDate()
    }
    
    @IBAction func didTapToDateButton(_ sender: Any) {
        delegate?.didTapToDate()
    }
    
    func configure(with delegate: DateRangeCollectionViewCellDelegate?, fromDate: Date?, toDate: Date?) {
        self.delegate = delegate
        
        let selectedDateColor = UIColor(red: 0.42, green: 0.58, blue: 0.98, alpha: 1)
        let unselectedDateColor = UIColor(red: 0.47, green: 0.52, blue: 0.64, alpha: 1)
        
        fromDateLabel.textColor = fromDate == nil ? unselectedDateColor : selectedDateColor
        toDateLabel.textColor = toDate == nil ? unselectedDateColor : selectedDateColor
        
        fromDateLabel.text = fromDate?.dateString(ofStyle: .short) ?? "Начало периода"
        toDateLabel.text = toDate?.dateString(ofStyle: .short) ?? "Конец периода"
    }
}
