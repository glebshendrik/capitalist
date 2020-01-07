//
//  FormTextField.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 19/07/2019.
//  Copyright © 2019 Real Tranzit. All rights reserved.
//

import UIKit
import SVGKit
import SDWebImageSVGCoder
import SnapKit

class FormTextField : FormField {
    private var didChange: ((String?) -> Void)? = nil
    
    // Subviews
    
    lazy var textField: FloatingTextField = { return createTextField() }()
    
    lazy var subValueLabel: UILabel = { return UILabel() }()
    
    // Appearance properties
    
    @IBInspectable var focusedTextColor: UIColor = UIColor.by(.white100) {
        didSet { updateTextField() }
    }
    
    @IBInspectable var unfocusedTextColor: UIColor = UIColor.by(.white100) {
        didSet { updateTextField() }
    }
    
    @IBInspectable var focusedPlaceholderNoTextColor: UIColor = UIColor.by(.white100) {
        didSet { updateTextField() }
    }
    
    @IBInspectable var focusedPlaceholderWithTextColor: UIColor = UIColor.by(.white40) {
        didSet { updateTextField() }
    }
    
    @IBInspectable var unfocusedPlaceholderColor: UIColor = UIColor.by(.white40) {
        didSet { updateTextField() }
    }
    
    @IBInspectable var bigPlaceholderFont: UIFont = UIFont(name: "Roboto-Regular", size: 15)! {
        didSet { updateTextField() }
    }
    
    @IBInspectable var smallPlaceholderFont: UIFont = UIFont(name: "Roboto-Regular", size: 10)! {
        didSet { updateTextField() }
    }
    
    @IBInspectable var lineColor: UIColor = UIColor.clear {
        didSet { updateTextField() }
    }
    
    @IBInspectable var selectedLineColor: UIColor = UIColor.by(.white100) {
        didSet { updateTextField() }
    }
    
    @IBInspectable var lineHeight: CGFloat = 0.0 {
        didSet { updateTextField() }
    }
    
    @IBInspectable var selectedLineHeight: CGFloat = 1.0 {
        didSet { updateTextField() }
    }
    
    @IBInspectable var placeholder: String? = nil {
        didSet { updateTextField() }
    }
    
    @IBInspectable var subValueLabelColor: UIColor = UIColor.by(.white100) {
        didSet { updateSubValueLabel() }
    }
    
    @IBInspectable var subValueLabelFont: UIFont = UIFont(name: "Roboto-Regular", size: 15)! {
        didSet { updateSubValueLabel() }
    }
    
    // Computed properties
    
    var text: String? {
        get { return textField.text?.trimmed }
        set {
            if text != newValue {
                clearError()
            }
            textField.text = newValue
            updateStateAppearance()
        }
    }
    
    var subValue: String? {
        get { return subValueLabel.text }
        set {
            if subValue != newValue {
                clearError()
            }
            subValueLabel.text = newValue            
            updateSubValueLabel()
        }
    }
    
    var isTextFieldFocused: Bool {
        return textField.isFirstResponder
    }
    
    var isTextPresent: Bool {
        return textField.text != nil && !textField.text!.trimmed.isEmpty
    }
    
    var hasSubValue: Bool {
        return subValue != nil && !subValue!.trimmed.isEmpty
    }
    
    var state: FormTextFieldState {
        return FormTextFieldState.stateBy(isFocused: isTextFieldFocused, isPresent: isTextPresent, hasError: hasError)
    }
    
    func didChange(_ didChange: @escaping (_ text: String?) -> Void) {
        self.didChange = didChange
    }
    
    override func setupSubviews() {
        super.setupSubviews()
        setupTextField()
        setupSubValueLabel()
    }
    
    override func updateSubviews() {
        super.updateSubviews()
        updateTextField()
        updateSubValueLabel()
    }
    
    override func setupConstraints() {
        super.setupConstraints()
        setupTextFieldConstraints()
        setupSubValueLabelConstraints()
    }
    
    func setupTextFieldConstraints() {
        textField.snp.makeConstraints { make in
            make.top.equalTo(10)
            make.right.equalTo(subValueLabel.snp.left).offset(-8)
            make.bottom.equalTo(-16)
            make.left.equalTo(iconContainer.snp.right).offset(20)
        }
        textField.setContentHuggingPriority(.defaultLow, for: .horizontal)
        textField.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
    }
    
    func setupSubValueLabelConstraints() {
        subValueLabel.snp.makeConstraints { make in
            make.right.equalTo(-16)
            make.centerY.equalToSuperview().offset(3)
        }
        subValueLabel.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        subValueLabel.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
    }
    
    override func setupErrorLabelConstraints() {
        errorLabel.snp.makeConstraints { make in
            make.left.equalTo(textField.snp.left)
            make.right.equalTo(textField.snp.right)
            make.top.equalTo(textField.snp.bottom).offset(-8)
            make.bottom.greaterThanOrEqualToSuperview()
        }
    }
    
    func createTextField() -> FloatingTextField {
        return FloatingTextField()
    }
    
    @objc func textFieldEditingDidBegin(_ textField: UITextField) {
        updateStateAppearance()
    }
    
    @objc func textFieldEditingChanged(_ textField: UITextField) {
        clearError()
        didChange?(textField.trimmedText)
    }
    
    @objc func textFieldEditingDidEnd(_ textField: UITextField) {
        updateStateAppearance()
    }
    
    override func didChangeError() {
        super.didChangeError()
        updateStateAppearance()
    }
    
    override func updateBackground() {
        let appearanceOptions = self.appearanceOptions()
        self.backgroundColor = appearanceOptions.backgroundColor
    }
    
    func setupTextField() {
        textField.translatesAutoresizingMaskIntoConstraints = false
        addSubview(textField)
        textField.titleFormatter = { $0 }
        textField.addTarget(self, action: #selector(textFieldEditingDidBegin(_:)), for: UIControl.Event.editingDidBegin)
        textField.addTarget(self, action: #selector(textFieldEditingChanged(_:)), for: UIControl.Event.editingChanged)
        textField.addTarget(self, action: #selector(textFieldEditingDidEnd(_:)), for: UIControl.Event.editingDidEnd)
    }
    
    func updateTextField() {
        let appearanceOptions = self.appearanceOptions()
        
        textField.textColor = appearanceOptions.textColor
        textField.placeholderFont = appearanceOptions.placeholderFont
        textField.placeholderColor = appearanceOptions.placeholderColor
        textField.titleColor = appearanceOptions.placeholderColor
        textField.selectedTitleColor = appearanceOptions.placeholderColor
        
        textField.placeholder = placeholder
        textField.selectedTitle = placeholder
        textField.lineColor = lineColor
        textField.selectedLineColor = selectedLineColor
        textField.lineHeight = lineHeight
        textField.selectedLineHeight = selectedLineHeight
        textField.font = bigPlaceholderFont
        
        textField.isEnabled = isEnabled
        textField.isUserInteractionEnabled = isEnabled
    }
    
    func setupSubValueLabel() {
        subValueLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(subValueLabel)
        subValueLabel.backgroundColor = .clear
    }
    
    func updateSubValueLabel() {
        subValueLabel.font = subValueLabelFont
        subValueLabel.textColor = subValueLabelColor
    }
    
    override func updateIcon(forceImageUpdate: Bool = true) {
        super.updateIcon(forceImageUpdate: forceImageUpdate)
        
        let appearanceOptions = self.appearanceOptions()
        
        iconContainer.backgroundColor = appearanceOptions.iconBackgroundColor
        icon.tintColor = appearanceOptions.iconTint
        
    }
    
    override func updateErrorLabel() {
        super.updateErrorLabel()
        errorLabel.isHidden = isTextFieldFocused
    }
        
    func updateStateAppearance() {
        updateBackground()
        updateIcon(forceImageUpdate: false)
        updateTextField()
        updateErrorLabel()
    }
}
