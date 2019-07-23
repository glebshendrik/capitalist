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

class FormTextField : UIControl {
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var textField: FloatingTextField!
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var iconContainer: UIView!
    @IBOutlet weak var icon: UIImageView!
    @IBOutlet weak var vectorIcon: SVGKFastImageView!
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var separator: UIView!
    
    var nibName: String {
        return String(describing: type(of: self))
    }
    
    override var intrinsicContentSize: CGSize {
        return UIView.layoutFittingExpandedSize
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    func setup() {
        Bundle.main.loadNibNamed(nibName, owner: self, options: nil)
        addSubview(contentView)
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        updateAppearance()
    }
    
    func addError(message: String?) {
        errorLabel.text = message
        updateAppearance()
    }
    
    func clearError() {
        errorLabel.text = nil
        updateAppearance()
    }
    
    func setIcon(name: String) {
        icon.image = UIImage(named: name)?.withRenderingMode(.alwaysTemplate)
    }
    
    func setIcon(url: URL, placeholder: String, isVector: Bool = false) {
        if isVector {
            vectorIcon.sd_setImage(with: url, completed: nil)
        }
        else {
            icon.setImage(with: url, placeholderName: placeholder, renderingMode: .alwaysTemplate)
        }
        
    }
    
    func updateAppearance() {
        textField.titleFormatter = { $0 }
        
        let focused = textField.isFirstResponder
        let present = textField.text != nil && !textField.text!.trimmed.isEmpty
        let invalid = errorLabel.text != nil && !errorLabel.text!.trimmed.isEmpty
        
        let textFieldOptions = self.textFieldOptions(focused: focused, present: present, invalid: invalid)
        
        backgroundView.backgroundColor = textFieldOptions.background
        iconContainer.backgroundColor = textFieldOptions.iconBackground
        icon.tintColor = textFieldOptions.iconTint
        textField.textColor = textFieldOptions.text
        textField.placeholderFont = textFieldOptions.placeholderFont
        textField.placeholderColor = textFieldOptions.placeholder
        textField.titleColor = textFieldOptions.placeholder
        textField.selectedTitleColor = textFieldOptions.placeholder
    }
    
    private func textFieldOptions(focused: Bool, present: Bool, invalid: Bool) -> (background: UIColor, text: UIColor, placeholder: UIColor, placeholderFont: UIFont?, iconBackground: UIColor, iconTint: UIColor) {
        
        let focusedBackgroundColor = UIColor.by(.blue6B93FB)
        let unfocusedBackgroundColor = UIColor.by(.dark2A314B)
        
        let textColor = UIColor.by(.textFFFFFF)
        
        let focusedPlaceholderNoTextColor = UIColor.by(.textFFFFFF)
        let focusedPlaceholderWithTextColor = UIColor.by(.text435585)
        let unfocusedPlaceholderColor = UIColor.by(.text9EAACC)
        
        let bigPlaceholderFont = UIFont(name: "Rubik-Regular", size: 15)
        let smallPlaceholderFont = UIFont(name: "Rubik-Regular", size: 10)
        
        let focusedIconBackground = UIColor.by(.textFFFFFF)
        let unfocusedIconBackground = UIColor.by(.gray7984A4)
        let invalidIconBackground = UIColor.by(.redFE3745)
        
        let focusedIconTint = UIColor.by(.blue6B93FB)
        let unfocusedIconTint = UIColor.by(.textFFFFFF)
        
        switch (focused, present, invalid) {
        case (true, true, _):
            return (focusedBackgroundColor, textColor, focusedPlaceholderWithTextColor, smallPlaceholderFont, focusedIconBackground, focusedIconTint)
        case (true, false, _):
            return (focusedBackgroundColor, textColor, focusedPlaceholderNoTextColor, bigPlaceholderFont, focusedIconBackground, focusedIconTint)
        case (false, true, false):
            return (unfocusedBackgroundColor, textColor, unfocusedPlaceholderColor, smallPlaceholderFont, unfocusedIconBackground, unfocusedIconTint)
        case (false, true, true):
            return (unfocusedBackgroundColor, textColor, unfocusedPlaceholderColor, smallPlaceholderFont, invalidIconBackground, unfocusedIconTint)
        case (false, false, false):
            return (unfocusedBackgroundColor, textColor, unfocusedPlaceholderColor, bigPlaceholderFont, unfocusedIconBackground, unfocusedIconTint)
        case (false, false, true):
            return (unfocusedBackgroundColor, textColor, unfocusedPlaceholderColor, bigPlaceholderFont, invalidIconBackground, unfocusedIconTint)
        }
    }
}
