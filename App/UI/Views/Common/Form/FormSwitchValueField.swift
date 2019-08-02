//
//  FormSwitchValueField.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 01/08/2019.
//  Copyright © 2019 Real Tranzit. All rights reserved.
//

import UIKit
import SnapKit

class FormSwitchValueField : FormTapField {
    lazy var switchView: UISwitch = { return UISwitch() }()
    
    @IBInspectable var switchOnTintColor: UIColor = UIColor.by(.textFFFFFF) {
        didSet { updateSwitch() }
    }
    
    @IBInspectable var switchThumbTintColor: UIColor = UIColor.by(.textFFFFFF) {
        didSet { updateSwitch() }
    }
    
    var value: Bool {
        get { return switchView.isOn }
        set { switchView.setOn(newValue, animated: true) }
    }
    
    override func setupSubviews() {
        super.setupSubviews()
        setupSwitch()
    }
    
    override func updateSubviews() {
        super.updateSubviews()
        updateSwitch()
    }
    
    override func setupConstraints() {
        super.setupConstraints()
        setupSwitchConstraints()
    }
    
    func setupSwitchConstraints() {
        switchView.snp.makeConstraints { make in
            make.right.equalTo(-16)
            make.centerY.equalTo(3)
        }
        switchView.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        switchView.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
    }
    
    override func setupTextFieldConstraints() {
        textField.snp.makeConstraints { make in
            make.top.equalTo(10)
            make.right.equalTo(switchView.snp.left).offset(8)
            make.bottom.equalTo(-16)
            make.left.equalTo(iconContainer.snp.right).offset(20)
        }
        textField.setContentHuggingPriority(.defaultLow, for: .horizontal)
        textField.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
    }
    
    func setupSwitch() {
        switchView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(switchView)
        switchView.addTarget(self, action: #selector(didSwitch(_:)), for: UIControl.Event.valueChanged)
    }
    
    func updateSwitch() {
        switchView.onTintColor = switchOnTintColor
        switchView.thumbTintColor = switchThumbTintColor
        switchView.isEnabled = isEnabled
    }
    
    override func updateArrow() {
        super.updateArrow()
        arrow.isHidden = true
    }
    
    override func updateSubValueLabel() {
        super.updateSubValueLabel()
        subValueLabel.isHidden = true
    }
    
    @objc private func didSwitch(_ sender: Any) {
        tap()
    }
}
