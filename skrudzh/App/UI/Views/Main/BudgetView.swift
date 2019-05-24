//
//  BudgetView.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 11/03/2019.
//  Copyright © 2019 Real Tranzit. All rights reserved.
//

import UIKit

protocol BudgetViewDelegate : class {
    func didTapBalance()
}

class BudgetView : NavigationBarCustomTitleView {
    @IBOutlet weak var balanceLabel: UILabel!
    @IBOutlet weak var spentLabel: UILabel!
    @IBOutlet weak var plannedLabel: UILabel!
    
    weak var delegate: BudgetViewDelegate? = nil
    
    @IBAction func didTapBalance(_ sender: Any) {
        delegate?.didTapBalance()
    }
}
