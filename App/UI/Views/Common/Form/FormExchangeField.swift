//
//  FormExchangeField.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 02/08/2019.
//  Copyright © 2019 Real Tranzit. All rights reserved.
//

import UIKit
import SVGKit
import SDWebImageSVGCoder
import SnapKit

class FormExchangeField : FormField {
    private var didChangeAmount: ((String?) -> Void)? = nil
    private var didChangeConvertedAmount: ((String?) -> Void)? = nil
    
    // Subviews
    
    lazy var exchangeContainer: UIView = { return UIView() }()
    
    lazy var amountContainer: UIView = { return UIView() }()
    
    lazy var convertedAmountContainer: UIView = { return UIView() }()
    
    lazy var focusLine: UIView = { return UIView() }()
    
    lazy var convertArrow: UIImageView = { return UIImageView() }()
    
    lazy var amountField: MoneyTextField = { return MoneyTextField() }()
    
    lazy var amountFieldBackground: UIView = { return UIView() }()
    
    lazy var amountCurrencyLabel: UILabel = { return UILabel() }()
    
    lazy var convertedAmountField: MoneyTextField = { return MoneyTextField() }()
    
    lazy var convertedAmountFieldBackground: UIView = { return UIView() }()
    
    lazy var convertedAmountCurrencyLabel: UILabel = { return UILabel() }()
    
    // Appearance properties
    
    @IBInspectable var focusedTextColor: UIColor = UIColor.by(.textFFFFFF) {
        didSet { updateTextField() }
    }
    
    @IBInspectable var unfocusedTextColor: UIColor = UIColor.by(.textFFFFFF) {
        didSet { updateTextField() }
    }
    
    @IBInspectable var focusedPlaceholderNoTextColor: UIColor = UIColor.by(.textFFFFFF) {
        didSet { updateTextField() }
    }
    
    @IBInspectable var focusedPlaceholderWithTextColor: UIColor = UIColor.by(.text435585) {
        didSet { updateTextField() }
    }
    
    @IBInspectable var unfocusedPlaceholderColor: UIColor = UIColor.by(.text9EAACC) {
        didSet { updateTextField() }
    }
    
    @IBInspectable var bigPlaceholderFont: UIFont = UIFont(name: "Rubik-Regular", size: 15)! {
        didSet { updateTextField() }
    }
    
    @IBInspectable var smallPlaceholderFont: UIFont = UIFont(name: "Rubik-Regular", size: 10)! {
        didSet { updateTextField() }
    }
    
    @IBInspectable var lineColor: UIColor = UIColor.clear {
        didSet { updateTextField() }
    }
    
    @IBInspectable var selectedLineColor: UIColor = UIColor.by(.textFFFFFF) {
        didSet { updateTextField() }
    }
    
    @IBInspectable var selectedLineHeight: CGFloat = 1.0 {
        didSet { updateTextField() }
    }
    
    @IBInspectable var amountPlaceholder: String? = nil {
        didSet { updateTextField() }
    }
    
    @IBInspectable var convertedAmountPlaceholder: String? = nil {
        didSet { updateTextField() }
    }
    
    @IBInspectable var convertImage: UIImage? = UIImage(named: "") {
        didSet { updateTextField() }
    }
    
    @IBInspectable var convertImageTint: UIColor = UIColor.by(.textFFFFFF) {
        didSet { updateTextField() }
    }
    
    @IBInspectable var unfocusedCurrencyColor: UIColor = UIColor.by(.textFFFFFF) {
        didSet { updateTextField() }
    }
    
    @IBInspectable var focusedCurrencyColor: UIColor = UIColor.by(.textFFFFFF) {
        didSet { updateTextField() }
    }
    
    @IBInspectable var unfocusedFieldBackgroundColor: UIColor = UIColor.clear {
        didSet { updateTextField() }
    }
    
    @IBInspectable var focusedFieldBackgroundColor: UIColor = UIColor.by(.textFFFFFF) {
        didSet { updateTextField() }
    }
    
    // Computed properties
    
    var amount: String? {
        get { return amountField.text?.trimmed }
        set { amountField.text = newValue }
    }
    
    var convertedAmount: String? {
        get { return convertedAmountField.text?.trimmed }
        set { convertedAmountField.text = newValue }
    }
    
    var currency: Currency? {
        get { return amountField.currency }
        set {
            amountField.currency = newValue
            updateCurrencyLabel()
        }
    }
    
    var convertedCurrency: Currency? {
        get { return convertedAmountField.currency }
        set {
            convertedAmountField.currency = newValue
            updateConvertedCurrencyLabel()
        }
    }
    
    var areExchangeFieldsFocused: Bool {
        return isAmountFieldFocused || isConvertedAmountFieldFocused
    }
    
    var isAmountFieldFocused: Bool {
        return amountField.isFirstResponder
    }
    
    var isAmountPresent: Bool {
        return amount != nil && !amount!.isEmpty
    }
    
    var isConvertedAmountFieldFocused: Bool {
        return convertedAmountField.isFirstResponder
    }
    
    var isConvertedAmountPresent: Bool {
        return convertedAmount != nil && !convertedAmount!.isEmpty
    }
    
    
    
//    var state: FormTextFieldState {
//        return FormTextFieldState.stateBy(isFocused: isTextFieldFocused, isPresent: isTextPresent, hasError: hasError)
//    }
    
    func didChangeAmount(_ didChange: @escaping (_ text: String?) -> Void) {
        self.didChangeAmount = didChange
    }
    
    func didChangeConvertedAmount(_ didChange: @escaping (_ text: String?) -> Void) {
        self.didChangeConvertedAmount = didChange
    }
    
    override func setupSubviews() {
        super.setupSubviews()
        setupContainer()
        setupAmountContainer()
        setupConvertedAmountContainer()
        setupConvertArrow()
        setupAmountTextField()
        setupAmountBackground()
        setupAmountCurrencyLabel()
        setupConvertedAmountTextField()
        setupConvertedAmountBackground()
        setupConvertedAmountCurrencyLabel()
        setupFocusLine()
    }
    
    override func updateSubviews() {
        super.updateSubviews()
        updateContainer()
        updateAmountContainer()
        updateConvertedAmountContainer()
        updateConvertArrow()
        updateAmountTextField()
        updateAmountBackground()
        updateAmountCurrencyLabel()
        updateConvertedAmountTextField()
        updateConvertedAmountBackground()
        updateConvertedAmountCurrencyLabel()
        updateFocusLine()
    }
    
    override func setupConstraints() {
        super.setupConstraints()
        setupContainerConstraints()
        setupAmountContainerConstraints()
        setupConvertedAmountContainerConstraints()
        setupConvertArrowConstraints()
        setupAmountTextFieldConstraints()
        setupAmountBackgroundConstraints()
        setupAmountCurrencyLabelConstraints()
        setupConvertedAmountTextFieldConstraints()
        setupConvertedAmountBackgroundConstraints()
        setupConvertedAmountCurrencyLabelConstraints()
        setupFocusLineConstraints()
    }
    
    func setupTextFieldConstraints() {
        textField.snp.makeConstraints { make in
            make.top.equalTo(10)
            make.right.equalTo(subValueLabel.snp.left).offset(8)
            make.bottom.equalTo(-16)
            make.left.equalTo(iconContainer.snp.right).offset(20)
        }
        textField.setContentHuggingPriority(.defaultLow, for: .horizontal)
        textField.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
    }
    
    func setupSubValueLabelConstraints() {
        subValueLabel.snp.makeConstraints { make in
            make.right.equalTo(-16)
            make.centerY.equalTo(3)
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
    
    @objc func textFieldEditingDidBegin(_ textField: UITextField) {
        updateStateAppearance()
    }
    
    @objc func amountFieldEditingChanged(_ textField: UITextField) {
        clearError()
        didChangeAmount?(textField.trimmedText)
    }
    
    @objc func convertedAmountFieldEditingChanged(_ textField: UITextField) {
        clearError()
        didChangeConvertedAmount?(textField.trimmedText)
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
        
        textField.isEnabled = isEnabled
        textField.isUserInteractionEnabled = isEnabled
    }
    
    override func updateIcon(forceImageUpdate: Bool = true) {
        super.updateIcon(forceImageUpdate: forceImageUpdate)
        
        let appearanceOptions = self.appearanceOptions()
        
        iconContainer.backgroundColor = appearanceOptions.iconBackgroundColor
        icon.tintColor = appearanceOptions.iconTint
        
    }
    
    override func updateErrorLabel() {
        super.updateErrorLabel()
        errorLabel.isHidden = areExchangeFieldsFocused
    }
    
    func updateStateAppearance() {
        updateBackground()
        updateIcon(forceImageUpdate: false)
        updateTextField()
        updateErrorLabel()
    }
}
