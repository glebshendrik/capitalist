//
//  FloatingTextField.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 21/05/2019.
//  Copyright © 2019 Real Tranzit. All rights reserved.
//

import UIKit
import SkyFloatingLabelTextField

class FloatingTextField : SkyFloatingLabelTextField {
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var iconContainer: UIView!
    @IBOutlet weak var icon: UIImageView!
    
    func updateAppearance() {
        titleFormatter = { $0 }
        
        let focused = isFirstResponder
        let present = text != nil && !text!.trimmed.isEmpty
        
        let textFieldOptions = self.textFieldOptions(focused: focused, present: present)
        
        backgroundView.backgroundColor = textFieldOptions.background
        iconContainer.backgroundColor = textFieldOptions.iconBackground
        icon.tintColor = textFieldOptions.iconTint
        textColor = textFieldOptions.text
        placeholderFont = textFieldOptions.placeholderFont
        placeholderColor = textFieldOptions.placeholder
        titleColor = textFieldOptions.placeholder
        selectedTitleColor = textFieldOptions.placeholder
    }
    
    private func textFieldOptions(focused: Bool, present: Bool) -> (background: UIColor, text: UIColor, placeholder: UIColor, placeholderFont: UIFont?, iconBackground: UIColor, iconTint: UIColor) {
        
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
        
        let focusedIconTint = UIColor.by(.blue6B93FB)
        let unfocusedIconTint = UIColor.by(.textFFFFFF)
        
        switch (focused, present) {
        case (true, true):
            return (focusedBackgroundColor, textColor, focusedPlaceholderWithTextColor, smallPlaceholderFont, focusedIconBackground, focusedIconTint)
        case (true, false):
            return (focusedBackgroundColor, textColor, focusedPlaceholderNoTextColor, bigPlaceholderFont, focusedIconBackground, focusedIconTint)
        case (false, true):
            return (unfocusedBackgroundColor, textColor, unfocusedPlaceholderColor, smallPlaceholderFont, unfocusedIconBackground, unfocusedIconTint)
        case (false, false):
            return (unfocusedBackgroundColor, textColor, unfocusedPlaceholderColor, bigPlaceholderFont, unfocusedIconBackground, unfocusedIconTint)
        }
    }
}
