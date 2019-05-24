//
//  HistoryTransactionsHeaderTableViewCell.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 27/03/2019.
//  Copyright © 2019 Real Tranzit. All rights reserved.
//

import UIKit

protocol HistoryTransactionsHeaderDelegate: class {
    func didTapExportButton()
}

class HistoryTransactionsHeaderTableViewCell : UITableViewCell {
    
    weak var delegate: HistoryTransactionsHeaderDelegate?
    
    @IBAction func didTapExportButton(_ sender: Any) {
        delegate?.didTapExportButton()
    }
}
