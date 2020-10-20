//
//  AccountCell.swift
//  Capitalist
//
//  Created by Alexander Petropavlovsky on 04/07/2019.
//  Copyright © 2019 Real Tranzit. All rights reserved.
//

import UIKit

class AccountCell : UITableViewCell {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var cardsLabel: UILabel!
    @IBOutlet weak var balanceLabel: UILabel!
    
    var viewModel: AccountViewModel? = nil {
        didSet {
            updateUI()
        }
    }
    
    private func updateUI() {
        titleLabel.text = viewModel?.name
        cardsLabel.text = viewModel?.cards
        balanceLabel.text = viewModel?.balance
    }
}
