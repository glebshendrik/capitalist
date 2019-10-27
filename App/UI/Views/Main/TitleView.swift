//
//  BudgetView.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 11/03/2019.
//  Copyright © 2019 Real Tranzit. All rights reserved.
//

import UIKit

protocol TitleViewDelegate : class {
    func didTapTitle()
}

class TitleView : CustomView {
    weak var delegate: TitleViewDelegate? = nil
    
    @IBAction func didTap(_ sender: Any) {
        delegate?.didTapTitle()
    }
}
