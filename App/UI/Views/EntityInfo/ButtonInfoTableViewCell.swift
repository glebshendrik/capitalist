//
//  ButtonInfoTableViewCell.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 13.11.2019.
//  Copyright © 2019 Real Tranzit. All rights reserved.
//

import UIKit

protocol ButtonInfoTableViewCellDelegate : EntityInfoTableViewCellDelegate {
    func didTapInfoButton(field: ButtonInfoField?)
}

class ButtonInfoTableViewCell : EntityInfoTableViewCell {
    @IBOutlet weak var button: UIButton!
    
    var buttonDelegate: ButtonInfoTableViewCellDelegate? {
        return delegate as? ButtonInfoTableViewCellDelegate
    }

    var butonField: ButtonInfoField? {
        return field as? ButtonInfoField
    }
    
    override func updateUI() {
        guard let field = butonField else { return }
        button.setTitle(field.title, for: .normal)
        if let iconName = field.iconName {
            button.setImage(UIImage(named: iconName), for: .normal)
        }
        button.isEnabled = field.isEnabled
        button.backgroundColor = UIColor.by(field.backgroundColor)
    }
    
    @IBAction func didTapButton(_ sender: Any) {
        guard let field = butonField, field.isEnabled else { return }
        buttonDelegate?.didTapInfoButton(field: butonField)
    }
}
