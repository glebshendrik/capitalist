//
//  HistoryTransactionsSectionHeaderView.swift
//  skrudzh
//
//  Created by Alexander Petropavlovsky on 28/03/2019.
//  Copyright © 2019 rubikon. All rights reserved.
//

import UIKit

class HistoryTransactionsSectionHeaderView: UITableViewHeaderFooterView {
    static let reuseIdentifier = "HistoryTransactionsSectionHeaderView"
    static let requiredHeight: CGFloat = 50.0
    
    @IBOutlet weak var dateLabel: UILabel!
    
    var section: HistoryTransactionsSection? {
        didSet {
            dateLabel.text = section?.title
        }
    }
}
