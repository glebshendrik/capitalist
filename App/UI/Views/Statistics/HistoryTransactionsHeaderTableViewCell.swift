//
//  TransactionsHeaderTableViewCell.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 27/03/2019.
//  Copyright © 2019 Real Tranzit. All rights reserved.
//

import UIKit

protocol TransactionsHeaderDelegate: class {
    func didTapExportButton()
}

class TransactionsHeaderTableViewCell : UITableViewCell {
    
    weak var delegate: TransactionsHeaderDelegate?
    
    @IBAction func didTapExportButton(_ sender: Any) {
        delegate?.didTapExportButton()
    }
}
