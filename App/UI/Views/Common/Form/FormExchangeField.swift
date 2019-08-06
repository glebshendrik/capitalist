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
        didSet { updateTextFields() }
    }
    
    @IBInspectable var unfocusedTextColor: UIColor = UIColor.by(.text9EAACC) {
        didSet { updateTextFields() }
    }
    
    @IBInspectable var focusedPlaceholderNoTextColor: UIColor = UIColor.by(.textFFFFFF) {
        didSet { updateTextFields() }
    }
    
    @IBInspectable var focusedPlaceholderWithTextColor: UIColor = UIColor.by(.text435585) {
        didSet { updateTextFields() }
    }
    
    @IBInspectable var unfocusedPlaceholderColor: UIColor = UIColor.by(.text9EAACC) {
        didSet { updateTextFields() }
    }
    
    @IBInspectable var bigPlaceholderFont: UIFont = UIFont(name: "Rubik-Regular", size: 15)! {
        didSet { updateTextFields() }
    }
    
    @IBInspectable var smallPlaceholderFont: UIFont = UIFont(name: "Rubik-Regular", size: 10)! {
        didSet { updateTextFields() }
    }
    
    @IBInspectable var lineColor: UIColor = UIColor.clear {
        didSet { updateFocusLine() }
    }
    
    @IBInspectable var selectedLineColor: UIColor = UIColor.by(.textFFFFFF) {
        didSet { updateFocusLine() }
    }
    
    @IBInspectable var selectedLineHeight: CGFloat = 1.0 {
        didSet { updateFocusLine() }
    }
    
    @IBInspectable var amountPlaceholder: String? = "Сумма" {
        didSet { updateTextFields() }
    }
    
    @IBInspectable var convertedAmountPlaceholder: String? = "Сумма" {
        didSet { updateTextFields() }
    }
    
    @IBInspectable var convertImage: UIImage? = UIImage(named: "right-arrow-icon") {
        didSet { updateConvertArrow() }
    }
    
    @IBInspectable var convertImageTint: UIColor = UIColor.by(.dark404B6F) {
        didSet { updateConvertArrow() }
    }
    
    @IBInspectable var unfocusedCurrencyColor: UIColor = UIColor.by(.text606B8A) {
        didSet { updateCurrencyLabels() }
    }
    
    @IBInspectable var focusedCurrencyColor: UIColor = UIColor.by(.textAFC1FF) {
        didSet { updateCurrencyLabels() }
    }
    
    @IBInspectable var unfocusedFieldBackgroundColor: UIColor = UIColor.clear {
        didSet { updateTextFieldBackgrounds() }
    }
    
    @IBInspectable var focusedFieldBackgroundColor: UIColor = UIColor.by(.blue5B7BD1) {
        didSet { updateTextFieldBackgrounds() }
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
            updateAmountCurrencyLabel()
        }
    }
    
    var convertedCurrency: Currency? {
        get { return convertedAmountField.currency }
        set {
            convertedAmountField.currency = newValue
            updateConvertedAmountCurrencyLabel()
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
    
    var amountTextFieldState: FormTextFieldState {
        return FormTextFieldState.stateBy(isFocused: isAmountFieldFocused, isPresent: isAmountPresent, hasError: hasError)
    }
    
    var convertedAmountTextFieldState: FormTextFieldState {
        return FormTextFieldState.stateBy(isFocused: isConvertedAmountFieldFocused, isPresent: isConvertedAmountPresent, hasError: hasError)
    }
    
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
    
    func setupContainer() {
        exchangeContainer.translatesAutoresizingMaskIntoConstraints = false
        addSubview(exchangeContainer)
    }
    
    func setupAmountContainer() {
        amountContainer.translatesAutoresizingMaskIntoConstraints = false
        exchangeContainer.addSubview(amountContainer)
    }
    
    func setupConvertedAmountContainer() {
        convertedAmountContainer.translatesAutoresizingMaskIntoConstraints = false
        exchangeContainer.addSubview(convertedAmountContainer)
    }
    
    func setupConvertArrow() {
        convertArrow.translatesAutoresizingMaskIntoConstraints = false
        exchangeContainer.addSubview(convertArrow)
    }
    
    func setupAmountTextField() {
        amountField.translatesAutoresizingMaskIntoConstraints = false
        amountContainer.addSubview(amountField)
        amountField.titleFormatter = { $0 }
        amountField.addTarget(self, action: #selector(textFieldEditingDidBegin(_:)), for: UIControl.Event.editingDidBegin)
        amountField.addTarget(self, action: #selector(amountFieldEditingChanged(_:)), for: UIControl.Event.editingChanged)
        amountField.addTarget(self, action: #selector(textFieldEditingDidEnd(_:)), for: UIControl.Event.editingDidEnd)
    }
    
    func setupAmountBackground() {
        amountFieldBackground.translatesAutoresizingMaskIntoConstraints = false
        amountContainer.addSubview(amountFieldBackground)
        amountFieldBackground.cornerRadius = 2
    }
    
    func setupAmountCurrencyLabel() {
        amountCurrencyLabel.translatesAutoresizingMaskIntoConstraints = false
        amountContainer.addSubview(amountCurrencyLabel)
    }
    
    func setupConvertedAmountTextField() {
        convertedAmountField.translatesAutoresizingMaskIntoConstraints = false
        convertedAmountContainer.addSubview(convertedAmountField)
        convertedAmountField.titleFormatter = { $0 }
        convertedAmountField.addTarget(self, action: #selector(textFieldEditingDidBegin(_:)), for: UIControl.Event.editingDidBegin)
        convertedAmountField.addTarget(self, action: #selector(convertedAmountFieldEditingChanged(_:)), for: UIControl.Event.editingChanged)
        convertedAmountField.addTarget(self, action: #selector(textFieldEditingDidEnd(_:)), for: UIControl.Event.editingDidEnd)
    }
    
    func setupConvertedAmountBackground() {
        convertedAmountFieldBackground.translatesAutoresizingMaskIntoConstraints = false
        convertedAmountContainer.addSubview(convertedAmountFieldBackground)
        convertedAmountFieldBackground.cornerRadius = 2
    }
    
    func setupConvertedAmountCurrencyLabel() {
        convertedAmountCurrencyLabel.translatesAutoresizingMaskIntoConstraints = false
        convertedAmountContainer.addSubview(convertedAmountCurrencyLabel)
    }
    
    func setupFocusLine() {
        focusLine.translatesAutoresizingMaskIntoConstraints = false
        exchangeContainer.addSubview(focusLine)
    }
    
    override func updateBackground() {
        let appearanceOptions = self.appearanceOptions()
        self.backgroundColor = appearanceOptions.fieldAppearance.backgroundColor
    }
    
    override func updateIcon(forceImageUpdate: Bool = true) {
        super.updateIcon(forceImageUpdate: forceImageUpdate)
        
        let appearanceOptions = self.appearanceOptions()
        
        iconContainer.backgroundColor = appearanceOptions.fieldAppearance.iconBackgroundColor
        icon.tintColor = appearanceOptions.fieldAppearance.iconTint
    }
    
    override func updateErrorLabel() {
        super.updateErrorLabel()
        errorLabel.isHidden = areExchangeFieldsFocused
    }
    
    func updateConvertArrow() {
        convertArrow.image = convertImage?.withRenderingMode(.alwaysTemplate)
        convertArrow.tintColor = convertImageTint
    }
    
    func updateAmountTextField() {
        let appearanceOptions = self.appearanceOptions().amountAppearance
        update(amountField, options: appearanceOptions, placeholder: amountPlaceholder)
    }
    
    func updateAmountBackground() {
        let appearanceOptions = self.appearanceOptions().amountAppearance
        amountFieldBackground.backgroundColor = appearanceOptions.textBackground
        amountFieldBackground.isHidden = !isAmountFieldFocused
    }
    
    func updateAmountCurrencyLabel() {
        let appearanceOptions = self.appearanceOptions().amountAppearance
        amountCurrencyLabel.text = currency?.code
        amountCurrencyLabel.textColor = appearanceOptions.currencyColor
    }
    
    func updateConvertedAmountTextField() {
        let appearanceOptions = self.appearanceOptions().convertedAmountAppearance
        update(convertedAmountField, options: appearanceOptions, placeholder: convertedAmountPlaceholder)
        convertedAmountField.titleColor = UIColor.clear
        convertedAmountField.selectedTitleColor = UIColor.clear
    }
    
    func updateConvertedAmountBackground() {
        let appearanceOptions = self.appearanceOptions().convertedAmountAppearance
        convertedAmountFieldBackground.backgroundColor = appearanceOptions.textBackground
        convertedAmountFieldBackground.isHidden = !isConvertedAmountFieldFocused
    }
    
    func updateConvertedAmountCurrencyLabel() {
        let appearanceOptions = self.appearanceOptions().convertedAmountAppearance
        convertedAmountCurrencyLabel.text = convertedCurrency?.code
        convertedAmountCurrencyLabel.textColor = appearanceOptions.currencyColor
    }
    
    func updateFocusLine() {
        let appearanceOptions = self.appearanceOptions().fieldAppearance
        focusLine.backgroundColor = appearanceOptions.focusLineColor
        focusLine.isHidden = !areExchangeFieldsFocused
    }
    
    func updateTextFields() {
        updateAmountTextField()
        updateConvertedAmountTextField()
    }
    
    func updateCurrencyLabels() {
        updateAmountCurrencyLabel()
        updateConvertedAmountCurrencyLabel()
    }
    
    func updateTextFieldBackgrounds() {
        updateAmountBackground()
        updateConvertedAmountBackground()
    }
    
    func updateStateAppearance() {
        updateBackground()
        updateIcon(forceImageUpdate: false)
        updateTextFields()
        updateTextFieldBackgrounds()
        updateCurrencyLabels()
        updateFocusLine()
        updateErrorLabel()
    }
    
    private func update(_ textField: MoneyTextField, options: TextAppearanceOptions, placeholder: String?) {
        textField.textColor = options.textColor
        textField.placeholderFont = options.placeholderFont
        textField.placeholderColor = options.placeholderColor
        textField.titleColor = options.placeholderColor
        textField.selectedTitleColor = options.placeholderColor
        
        textField.placeholder = placeholder
        textField.selectedTitle = placeholder
        textField.lineColor = UIColor.clear
        textField.selectedLineColor = UIColor.clear
        textField.lineHeight = 0
        textField.selectedLineHeight = 0
        
        textField.isEnabled = isEnabled
        textField.isUserInteractionEnabled = isEnabled
    }
    
    func setupContainerConstraints() {
        exchangeContainer.snp.makeConstraints { make in
            make.top.equalTo(10)
            make.right.equalTo(16)
            make.bottom.equalTo(-16)
            make.left.equalTo(iconContainer.snp.right).offset(20)
        }
    }
    
    func setupAmountContainerConstraints() {
        amountContainer.snp.makeConstraints { make in
            make.top.bottom.left.equalToSuperview()
            make.right.equalTo(convertArrow.snp.left).offset(5)
        }
    }
    
    func setupConvertedAmountContainerConstraints() {
        convertedAmountContainer.snp.makeConstraints { make in
            make.top.right.bottom.equalToSuperview()
            make.left.equalTo(convertArrow.snp.right).offset(5)
        }
    }
    
    func setupConvertArrowConstraints() {
        convertArrow.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }
    
    func setupAmountTextFieldConstraints() {
        amountField.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.left.equalTo(6)
        }
        amountField.setContentHuggingPriority(.defaultLow, for: .horizontal)
        amountField.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
    }
    
    func setupAmountBackgroundConstraints() {
        amountFieldBackground.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalTo(17)
            make.bottom.equalTo(3)
        }
    }
    
    func setupAmountCurrencyLabelConstraints() {
        amountCurrencyLabel.snp.makeConstraints { make in
            make.centerY.equalTo(8)
            make.right.equalTo(-6)
            make.left.equalTo(amountField.snp.right).offset(8)
        }
    }
    
    func setupConvertedAmountTextFieldConstraints() {
        convertedAmountField.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.left.equalTo(6)
        }
        convertedAmountField.setContentHuggingPriority(.defaultLow, for: .horizontal)
        convertedAmountField.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
    }
    
    func setupConvertedAmountBackgroundConstraints() {
        convertedAmountFieldBackground.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalTo(17)
            make.bottom.equalTo(3)
        }
    }
    
    func setupConvertedAmountCurrencyLabelConstraints() {
        convertedAmountCurrencyLabel.snp.makeConstraints { make in
            make.centerY.equalTo(8)
            make.right.equalTo(-6)
            make.left.equalTo(amountField.snp.right).offset(8)
        }
    }
    
    func setupFocusLineConstraints() {
        focusLine.snp.makeConstraints { make in
            make.height.equalTo(1)
            make.left.bottom.right.equalToSuperview()
        }
    }
    
    override func setupErrorLabelConstraints() {
        errorLabel.snp.makeConstraints { make in
            make.left.equalTo(exchangeContainer.snp.left)
            make.right.equalTo(exchangeContainer.snp.right)
            make.top.equalTo(exchangeContainer.snp.bottom).offset(-8)
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
    
    
}
