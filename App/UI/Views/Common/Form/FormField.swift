//
//  FormField.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 02/08/2019.
//  Copyright © 2019 Real Tranzit. All rights reserved.
//

import Foundation

import UIKit
import SVGKit
import SDWebImageSVGCoder
import SnapKit

class FormField : UIView {
    private var didSetupConstraints = false
    
    // Subviews
    
    lazy var iconContainer: UIView = { return UIView() }()
    
    lazy var icon: UIImageView = { return UIImageView() }()
    
    lazy var vectorIcon: SVGKFastImageView = { return SVGKFastImageView(frame: CGRect.zero) }()
    
    lazy var errorLabel: UILabel = { return UILabel() }()
    
    lazy var separator: UIView = { return UIView() }()
    
    // Appearance properties
    
    @IBInspectable var focusedBackgroundColor: UIColor = UIColor.by(.blue6B93FB) {
        didSet { updateBackground() }
    }
    
    @IBInspectable var unfocusedBackgroundColor: UIColor = UIColor.by(.dark2A314B) {
        didSet { updateBackground() }
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
    
    var hasError: Bool {
        return errorLabel.text != nil && !errorLabel.text!.trimmed.isEmpty
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
    
    private func setup() {
        setupSubviews()
        setNeedsUpdateConstraints()
        updateSubviews()
    }
    
    func setupSubviews() {
        setupBackground()
        setupIcon()
        setupErrorLabel()
        setupSeparator()
    }
    
    func updateSubviews() {
        updateBackground()
        updateIcon()
        updateErrorLabel()
        updateSeparator()
    }
    
    func setupConstraints() {
        setupIconContainerConstraints()
        setupIconConstraints()
        setupVectorIconConstraints()
        setupSeparatorConstraints()
        setupErrorLabelConstraints()
    }
    
    func setupIconContainerConstraints() {
        iconContainer.snp.makeConstraints { make in
            make.width.height.equalTo(36)
            make.left.equalTo(16)
            make.centerY.equalToSuperview().offset(3)
        }
    }
    
    func setupIconConstraints() {
        icon.snp.makeConstraints { make in
            make.width.height.lessThanOrEqualTo(30)
            make.center.equalToSuperview()
        }
    }
    
    func setupVectorIconConstraints() {
        vectorIcon.snp.makeConstraints { make in
            make.width.height.lessThanOrEqualTo(30)
            make.center.equalToSuperview()
        }
    }
    
    func setupSeparatorConstraints() {
        separator.snp.makeConstraints { make in
            make.left.bottom.right.equalToSuperview()
            make.height.equalTo(1)
        }
    }
    
    func setupErrorLabelConstraints() {
        errorLabel.snp.makeConstraints { make in
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
    
    func addError(message: String?) {
        errorLabel.text = message
        didChangeError()
    }
    
    func clearError() {
        errorLabel.text = nil
        didChangeError()
    }
    
    func didChangeError() {
        
    }
    
    func setupBackground() {
        translatesAutoresizingMaskIntoConstraints = false
    }
    
    func updateBackground() {
        self.backgroundColor = unfocusedBackgroundColor
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
        
        iconContainer.backgroundColor = unfocusedBackgroundColor
        icon.tintColor = unfocusedIconTint
        
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
        errorLabel.textColor = errorLabelColor
        errorLabel.font = errorLabelFont
    }
    
    func setupSeparator() {
        separator.translatesAutoresizingMaskIntoConstraints = false
    }
    
    func updateSeparator() {
        separator.backgroundColor = separatorColor
    }
}
