//
//  ButtonInfoTableViewCell.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 13.11.2019.
//  Copyright © 2019 Real Tranzit. All rights reserved.
//

import UIKit

protocol ButtonInfoTableViewCellDelegate {
    func didTapInfoButton(field: ButtonInfoField?)
}

class ButtonInfoTableViewCell : UITableViewCell {
    @IBOutlet weak var button: UIButton!
    
    var delegate: ButtonInfoTableViewCellDelegate?
    
    var field: ButtonInfoField? {
        didSet {
            updateUI()
        }
    }
    
    func updateUI() {
        guard let field = field else { return }
        button.setTitle(field.title, for: .normal)
        if let iconName = field.iconName {
            button.setImage(UIImage(named: iconName), for: .normal)
        }
        button.isEnabled = field.isEnabled
    }
    
    @IBAction func didTapButton(_ sender: Any) {
        delegate?.didTapInfoButton(field: field)
    }
}
