//
//  TransactionsSectionHeaderView.swift
//  Capitalist
//
//  Created by Alexander Petropavlovsky on 28/03/2019.
//  Copyright © 2019 Real Tranzit. All rights reserved.
//

import UIKit

class TransactionsSectionHeaderView: UITableViewHeaderFooterView {
    static let reuseIdentifier = "TransactionsSectionHeaderView"
    static let requiredHeight: CGFloat = 40.0
    
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var amountButton: UIButton!
    
    var section: TransactionsSection? {
        didSet {
            title = section?.title
            amountButton.setTitle(section?.amount, for: .normal)
            amountButton.isHidden = section?.amount == nil
        }
    }
    
    var title: String? {
        didSet {
            dateLabel.font = UIFont(name: "Roboto-Regular", size: 13.0)
            dateLabel.text = title
        }
    }
}
