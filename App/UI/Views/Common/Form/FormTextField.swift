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

class FormTextField : UIView {
    private var didSetupConstraints = false
    
    private var didChange: ((String?) -> Void)? = nil
    
    // Subviews
    
    private lazy var textField: FloatingTextField = { return createTextField() }()
    
    private lazy var iconContainer: UIView = { return UIView() }()
    
    private lazy var icon: UIImageView = { return UIImageView() }()
    
    private lazy var vectorIcon: SVGKFastImageView = { return SVGKFastImageView(frame: CGRect.zero) }()
    
    private lazy var errorLabel: UILabel = { return UILabel() }()
    
    private lazy var separator: UIView = { return UIView() }()
    
    // Appearance properties
    
    @IBInspectable var focusedBackgroundColor: UIColor = UIColor.by(.blue6B93FB) {
        didSet { updateBackground() }
    }
    
    @IBInspectable var unfocusedBackgroundColor: UIColor = UIColor.by(.dark2A314B) {
        didSet { updateBackground() }
    }
    
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
    
    @IBInspectable var focusedIconBackground: UIColor = UIColor.by(.textFFFFFF) {
        didSet { updateIcon() }
    }
    
    @IBInspectable var unfocusedIconBackground: UIColor = UIColor.by(.gray7984A4) {
        didSet { updateIcon() }
    }
    
    @IBInspectable var invalidIconBackground: UIColor = UIColor.by(.redFE3745) {
        didSet { updateIcon() }
    }
    
    @IBInspectable var focusedIconTint: UIColor = UIColor.by(.blue6B93FB) {
        didSet { updateIcon() }
    }
    
    @IBInspectable var unfocusedIconTint: UIColor = UIColor.by(.textFFFFFF) {
        didSet { updateIcon() }
    }
    
    @IBInspectable var errorLabelFont: UIFont = UIFont(name: "Rubik-Regular", size: 10)! {
        didSet { updateErrorLabel() }
    }
    
    @IBInspectable var errorLabelColor: UIColor = UIColor.by(.redFE3745) {
        didSet { updateErrorLabel() }
    }
    
    @IBInspectable var lineColor: UIColor = UIColor.clear {
        didSet { updateTextField() }
    }
    
    @IBInspectable var selectedLineColor: UIColor = UIColor.by(.textFFFFFF) {
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
    
    @IBInspectable var isVector: Bool = false {
        didSet { updateIcon() }
    }
    
    @IBInspectable var imageName: String? = nil {
        didSet { updateIcon() }
    }
    
    var imageURL: URL? = nil {
        didSet { updateIcon() }
    }
    
    @IBInspectable var separatorColor: UIColor = UIColor.by(.delimeter2F3854) {
        didSet { updateSeparator() }
    }
    
    var isEnabled: Bool = true {
        didSet { updateSubviews() }
    }
    
    // Computed properties
    
    var text: String? {
        get { return textField.text?.trimmed }
        set { textField.text = newValue }
    }
    
    var isTextFieldFocused: Bool {
        return textField.isFirstResponder
    }
    
    var isTextPresent: Bool {
        return textField.text != nil && !textField.text!.trimmed.isEmpty
    }
    
    var hasError: Bool {
        return errorLabel.text != nil && !errorLabel.text!.trimmed.isEmpty
    }
    
    var state: FormTextFieldState {
        return FormTextFieldState.stateBy(isFocused: isTextFieldFocused, isPresent: isTextPresent, hasError: hasError)
    }
    
    // Methods
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    func didChange(_ didChange: @escaping (_ text: String?) -> Void) {
        self.didChange = didChange
    }
    
    private func setup() {
        setupSubviews()
        setNeedsUpdateConstraints()
        updateSubviews()
    }
    
    func setupSubviews() {
        setupBackground()
        setupTextField()
        setupIcon()
        setupErrorLabel()
        setupSeparator()
    }
    
    func updateSubviews() {
        updateBackground()
        updateTextField()
        updateIcon()
        updateErrorLabel()
        updateSeparator()
    }
    
    func setupConstraints() {
        iconContainer.snp.makeConstraints { make in
            make.width.height.equalTo(36)
            make.left.equalTo(16)
            make.centerY.equalToSuperview().offset(3)
        }
        
        icon.snp.makeConstraints { make in
            make.width.height.lessThanOrEqualTo(30)
            make.center.equalToSuperview()
        }
        
        vectorIcon.snp.makeConstraints { make in
            make.width.height.lessThanOrEqualTo(30)
            make.center.equalToSuperview()
        }
        
        textField.snp.makeConstraints { make in
            make.top.equalTo(10)
            make.right.equalTo(-32)
            make.bottom.equalTo(-16)
            make.left.equalTo(iconContainer.snp.right).offset(20)
        }
        
        separator.snp.makeConstraints { make in
            make.left.bottom.right.equalToSuperview()
            make.height.equalTo(1)
        }
        
        errorLabel.snp.makeConstraints { make in
            make.left.equalTo(textField.snp.left)
            make.right.equalTo(textField.snp.right)
            make.top.equalTo(textField.snp.bottom).offset(-8)
            make.bottom.greaterThanOrEqualToSuperview()
        }
    }
    
    override func updateConstraints() {
        if !didSetupConstraints {
            setupConstraints()
            didSetupConstraints = true
        }
        super.updateConstraints()
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
    
    func addError(message: String?) {
        errorLabel.text = message
        updateStateAppearance()
    }
    
    func clearError() {
        errorLabel.text = nil
        updateStateAppearance()
    }
}

// Setup & Update
extension FormTextField {
    func setupBackground() {
        translatesAutoresizingMaskIntoConstraints = false
    }
    
    func updateBackground() {
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
    
    func setupIcon() {
        iconContainer.translatesAutoresizingMaskIntoConstraints = false
        icon.translatesAutoresizingMaskIntoConstraints = false
        vectorIcon.translatesAutoresizingMaskIntoConstraints = false
        iconContainer.addSubview(icon)
        iconContainer.addSubview(vectorIcon)
        addSubview(iconContainer)
        iconContainer.cornerRadius = 18
    }
    
    func updateIcon(forceImageUpdate: Bool = true) {
        let appearanceOptions = self.appearanceOptions()
        
        iconContainer.backgroundColor = appearanceOptions.iconBackgroundColor
        icon.tintColor = appearanceOptions.iconTint
        
        icon.isHidden = isVector
        vectorIcon.isHidden = !isVector
        
        guard forceImageUpdate else { return }
        
        guard let url = imageURL else {
            if let imageName = imageName {
                icon.image = UIImage(named: imageName)?.withRenderingMode(.alwaysTemplate)
            }
            return
        }
        
        if isVector {
            vectorIcon.sd_setImage(with: url, completed: nil)
        }
        else {
            icon.setImage(with: url, placeholderName: imageName, renderingMode: .alwaysTemplate)
        }
    }
    
    func setupErrorLabel() {
        errorLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(errorLabel)
        errorLabel.numberOfLines = 0
    }
    
    func updateErrorLabel() {
        errorLabel.isHidden = isTextFieldFocused
        errorLabel.textColor = errorLabelColor
        errorLabel.font = errorLabelFont
    }
    
    func setupSeparator() {
        separator.translatesAutoresizingMaskIntoConstraints = false
    }
    
    func updateSeparator() {
        separator.backgroundColor = separatorColor
    }
    
    func updateStateAppearance() {
        updateBackground()
        updateIcon(forceImageUpdate: false)
        updateTextField()
        updateErrorLabel()
    }
}
