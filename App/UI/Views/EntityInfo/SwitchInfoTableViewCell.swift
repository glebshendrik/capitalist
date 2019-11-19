//
//  SwitchInfoTableViewCell.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 13.11.2019.
//  Copyright © 2019 Real Tranzit. All rights reserved.
//

import UIKit

protocol SwitchInfoTableViewCellDelegate {
    func didSwitch(field: SwitchInfoField?)
}

class SwitchInfoTableViewCell : UITableViewCell {
    @IBOutlet weak var titleButton: UIButton!
    @IBOutlet weak var switchControl: UISwitch!
    
    var delegate: SwitchInfoTableViewCellDelegate?
    
    var field: SwitchInfoField? {
        didSet {
            updateUI()
        }
    }
    
    func updateUI() {
        guard let field = field else { return }
        titleButton.setTitle(field.title, for: .normal)
        switchControl.setOn(field.value, animated: false)
    }
    
    @IBAction func didSwitch(_ sender: Any) {
        field?.value = switchControl.isOn
        delegate?.didSwitch(field: field)
    }
    
    @IBAction func didTapButton(_ sender: Any) {
        switchControl.setOn(!switchControl.isOn, animated: true)
        field?.value = switchControl.isOn
        delegate?.didSwitch(field: field)
    }
}
