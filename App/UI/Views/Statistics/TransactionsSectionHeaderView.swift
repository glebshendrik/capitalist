//
//  TransactionsSectionHeaderView.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 28/03/2019.
//  Copyright © 2019 Real Tranzit. All rights reserved.
//

import UIKit

class TransactionsSectionHeaderView: UITableViewHeaderFooterView {
    static let reuseIdentifier = "TransactionsSectionHeaderView"
    static let requiredHeight: CGFloat = 50.0
    
    @IBOutlet weak var dateLabel: UILabel!
    
    var section: TransactionsSection? {
        didSet {
            dateLabel.text = section?.title
        }
    }
    
    var title: String? {
        didSet {
            dateLabel.font = UIFont(name: "Rubik-Regular", size: 15.0)
            dateLabel.text = title
        }
    }
}
