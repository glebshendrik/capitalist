//
//  InteractiveFieldView.swift
//  Capitalist
//
//  Created by Alexander Petropavlovsky on 04.11.2020.
//  Copyright © 2020 Real Tranzit. All rights reserved.
//

import UIKit
import SnapKit

protocol InteractiveFieldViewDelegate : class {
    func didChangeFieldValue(field: InteractiveFieldView)
}

class InteractiveFieldView : CustomView {
    lazy var titleLabel: UILabel = { return UILabel() }()
    lazy var fieldContainer: UIView = { return UIView() }()
    lazy var fieldTextField: UITextField = { return UITextField() }()
    lazy var selectPicker: UIPickerView = { return UIPickerView() }()
    
    weak var delegate: InteractiveFieldViewDelegate? = nil
    
    var interactiveCredentials: ConnectionInteractiveCredentials? = nil {
        didSet {
            updateUI()
        }
    }
    
    var fieldCornerRadius: CGFloat = 6.0 {
        didSet {
            fieldContainer.cornerRadius = fieldCornerRadius
        }
    }
    
    var labelColor: UIColor = UIColor.by(.white100) {
        didSet {
            titleLabel.textColor = labelColor
        }
    }
    
    var labelFont: UIFont? = UIFont(name: "Roboto-Regular", size: 12) {
        didSet {
            titleLabel.font = labelFont
        }
    }
    
    var fieldBackgroundColor: UIColor = UIColor.by(.black1) {
        didSet {
            fieldContainer.backgroundColor = fieldBackgroundColor
            fieldTextField.backgroundColor = fieldBackgroundColor
        }
    }
    
    var fieldTextColor: UIColor = UIColor.by(.white100) {
        didSet {
            fieldTextField.textColor = fieldTextColor
        }
    }
    
    var fieldFont: UIFont? = UIFont(name: "Roboto-Regular", size: 12) {
        didSet {
            fieldTextField.font = fieldFont
        }
    }
    
    var value: String? {
        return fieldTextField.text
    }
    
    override func setup() {
        super.setup()
        backgroundColor = .clear
        setupTitle()
        setupField()
    }
    
    override func setupConstraints() {
        setupTitleConstraints()
        setupFieldContainerConstraints()
        setupFieldConstraints()
    }
    
    private func setupTitle() {
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(titleLabel)
        updateTitleUI()
    }
    
    private func setupField() {
        fieldContainer.translatesAutoresizingMaskIntoConstraints = false
        fieldTextField.translatesAutoresizingMaskIntoConstraints = false
        addSubview(fieldContainer)
        fieldContainer.addSubview(fieldTextField)
        fieldTextField.addTarget(self, action: #selector(didChangeFieldValue), for: .editingChanged)
        updateFieldUI()
    }
    
    private func updateUI() {
        updateTitleUI()
        updateFieldUI()
    }
    
    private func updateTitleUI() {
        titleLabel.textAlignment = .left
        titleLabel.font = labelFont
        titleLabel.adjustsFontSizeToFitWidth = true
        titleLabel.text = interactiveCredentials?.displayName
        titleLabel.textColor = labelColor
    }
    
    private func updateFieldUI() {
        fieldTextField.font = fieldFont
        fieldTextField.textAlignment = .center
        fieldTextField.textColor = fieldTextColor
        fieldContainer.backgroundColor = fieldBackgroundColor
        fieldTextField.backgroundColor = fieldBackgroundColor
        fieldContainer.cornerRadius = fieldCornerRadius
        guard
            let interactiveCredentials = interactiveCredentials
        else {
            return
        }
        switch interactiveCredentials.nature {
            case .text:
                updateFieldTextUI()
            case .password:
                updateFieldPasswordUI()
            case .number:
                updateFieldNumberUI()
            case .select:
                updateFieldSelectUI()
            default:
                return
        }
        fieldTextField.text = interactiveCredentials.value
        fieldTextField.placeholder = interactiveCredentials.displayName
    }
    
    @objc private func didChangeFieldValue(_ sender: Any) {        
        interactiveCredentials?.value = value
        delegate?.didChangeFieldValue(field: self)
    }
    
    private func updateFieldTextUI() {
        fieldTextField.keyboardType = .default
        fieldTextField.isSecureTextEntry = false
    }
    
    private func updateFieldPasswordUI() {
        fieldTextField.keyboardType = .default
        fieldTextField.isSecureTextEntry = true
        fieldTextField.textContentType = .password
    }
    
    private func updateFieldNumberUI() {
        fieldTextField.keyboardType = .numberPad
        fieldTextField.isSecureTextEntry = false
        if #available(iOS 12.0, *) {
            fieldTextField.textContentType = .oneTimeCode
        }
    }
    
    private func updateFieldSelectUI() {
        fieldTextField.keyboardType = .default
        fieldTextField.isSecureTextEntry = false
        fieldTextField.inputView = selectPicker
        selectPicker.delegate = self
        selectPicker.dataSource = self
        selectPicker.reloadAllComponents()
    }
    
    func setupTitleConstraints() {
        titleLabel.snp.makeConstraints { make in
            make.left.top.right.equalToSuperview()
            make.bottom.equalTo(fieldContainer.snp_top).offset(-4)
        }
    }
    
    func setupFieldContainerConstraints() {
        fieldContainer.snp.makeConstraints { make in
            make.left.bottom.right.equalToSuperview()
        }
    }
    
    func setupFieldConstraints() {
        fieldTextField.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(8)
            make.right.equalToSuperview().offset(-8)
            make.top.equalToSuperview().offset(4)
            make.bottom.equalToSuperview().offset(-4)
            make.height.equalTo(44)
        }
    }
}

extension InteractiveFieldView : UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        guard
            let options = interactiveCredentials?.options
        else {
            return 0
        }
        return options.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        guard
            let option = interactiveCredentials?.options?[row]
        else {
            return nil
        }
        return option.localizedName
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        guard
            var interactiveCredentials = interactiveCredentials,
            let option = interactiveCredentials.options?[row]
        else {
            return
        }
        interactiveCredentials.value = option.optionValue
        fieldTextField.text = option.localizedName
    }
}
