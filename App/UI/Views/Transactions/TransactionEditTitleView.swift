//
//  TransactionEditTitleView.swift
//  Capitalist
//
//  Created by Alexander Petropavlovsky on 14.05.2020.
//  Copyright © 2020 Real Tranzit. All rights reserved.
//

import UIKit

class TransactionEditTitleView : CustomXibView {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var highlightView: UIView!
    
    func set(title: String) {
        guard title != titleLabel.text else { return }
        UIView.transition(with: titleLabel,
             duration: 0.25,
              options: .transitionCrossDissolve,
           animations: { [weak self] in
                self?.titleLabel.text = title
        }, completion: nil)
    }
    
    func set(highlightColor: UIColor) {
        guard highlightColor != highlightView.backgroundColor else { return }
        UIView.transition(with: highlightView,
             duration: 0.25,
              options: .transitionCrossDissolve,
           animations: { [weak self] in
                self?.highlightView.backgroundColor = highlightColor
        }, completion: nil)
    }
}
