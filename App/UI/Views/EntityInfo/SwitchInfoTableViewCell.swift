//
//  SwitchInfoTableViewCell.swift
//  Capitalist
//
//  Created by Alexander Petropavlovsky on 13.11.2019.
//  Copyright © 2019 Real Tranzit. All rights reserved.
//

import UIKit

protocol SwitchInfoTableViewCellDelegate : EntityInfoTableViewCellDelegate {
    func didSwitch(field: SwitchInfoField?)
}

class SwitchInfoTableViewCell : EntityInfoTableViewCell {
    @IBOutlet weak var titleButton: UIButton!
    @IBOutlet weak var switchControl: UISwitch!
    
    var switchDelegate: SwitchInfoTableViewCellDelegate? {
        return delegate as? SwitchInfoTableViewCellDelegate
    }

    var switchField: SwitchInfoField? {
        return field as? SwitchInfoField
    }
    
    override func updateUI() {
        guard let field = switchField else { return }
        titleButton.setTitle(field.title, for: .normal)
        switchControl.setOn(field.value, animated: false)
    }
    
    @IBAction func didSwitch(_ sender: Any) {
        switchField?.value = switchControl.isOn
        switchDelegate?.didSwitch(field: switchField)
    }
    
    @IBAction func didTapButton(_ sender: Any) {
        switchControl.setOn(!switchControl.isOn, animated: true)
        switchField?.value = switchControl.isOn
        switchDelegate?.didSwitch(field: switchField)
    }
}
