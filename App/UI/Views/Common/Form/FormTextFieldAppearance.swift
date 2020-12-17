//
//  FormTextFieldAppearance.swift
//  Capitalist
//
//  Created by Alexander Petropavlovsky on 29/07/2019.
//  Copyright © 2019 Real Tranzit. All rights reserved.
//

import UIKit

typealias TextFieldAppearanceOptions = (backgroundColor: UIColor,
                                        textColor: UIColor,
                                        placeholderColor: UIColor,
                                        placeholderFont: UIFont?,
                                        iconBackgroundColor: UIColor,
                                        iconTint: UIColor)

enum FormTextFieldState {
    case focusedPresentValid
    case focusedPresentInvalid
    case focusedEmptyValid
    case focusedEmptyInvalid
    case unfocusedPresentValid
    case unfocusedPresentInvalid
    case unfocusedEmptyValid
    case unfocusedEmptyInvalid
    
    static func stateBy(isFocused: Bool, isPresent: Bool, hasError: Bool) -> FormTextFieldState {
        switch (isFocused, isPresent, hasError) {
        case (true, true, false):       return .focusedPresentValid
        case (true, true, true):        return .focusedPresentInvalid
        case (true, false, false):      return .focusedEmptyValid
        case (true, false, true):       return .focusedEmptyInvalid
        case (false, true, false):      return .unfocusedPresentValid
        case (false, true, true):       return .unfocusedPresentInvalid
        case (false, false, false):     return .unfocusedEmptyValid
        case (false, false, true):      return .unfocusedEmptyInvalid
        }
    }
}

extension FormTextField {
    func appearanceOptions() -> TextFieldAppearanceOptions {
        switch state {
        case .focusedPresentValid,
             .focusedPresentInvalid:    return focusedPresentTextFieldOptions()
        case .focusedEmptyValid,
             .focusedEmptyInvalid:      return focusedEmptyTextFieldOptions()
        case .unfocusedPresentValid:    return unfocusedPresentValidTextFieldOptions()
        case .unfocusedPresentInvalid:  return unfocusedPresentInvalidTextFieldOptions()
        case .unfocusedEmptyValid:      return unfocusedEmptyValidTextFieldOptions()
        case .unfocusedEmptyInvalid:    return unfocusedEmptyInvalidTextFieldOptions()
        }
    }
    
    private func focusedPresentTextFieldOptions() -> TextFieldAppearanceOptions {
        return (focusedBackgroundColor,
                focusedTextColor,
                focusedPlaceholderWithTextColor,
                smallPlaceholderFont,
                focusedIconBackground,
                focusedIconTint)
    }
    
    private func focusedEmptyTextFieldOptions() -> TextFieldAppearanceOptions {
        return (focusedBackgroundColor,
                focusedTextColor,
                focusedPlaceholderNoTextColor,
                bigPlaceholderFont,
                focusedIconBackground,
                focusedIconTint)
    }
    
    private func unfocusedPresentValidTextFieldOptions() -> TextFieldAppearanceOptions {
        return (unfocusedBackgroundColor,
                unfocusedTextColor,
                unfocusedPlaceholderColor,
                smallPlaceholderFont,
                unfocusedIconBackground,
                unfocusedIconTint)
    }
    
    private func unfocusedPresentInvalidTextFieldOptions() -> TextFieldAppearanceOptions {
        return (unfocusedBackgroundColor,
                unfocusedTextColor,
                unfocusedPlaceholderColor,
                smallPlaceholderFont,
                invalidIconBackground,
                unfocusedIconTint)
    }
    
    private func unfocusedEmptyValidTextFieldOptions() -> TextFieldAppearanceOptions {
        return (unfocusedBackgroundColor,
                unfocusedTextColor,
                unfocusedPlaceholderColor,
                bigPlaceholderFont,
                unfocusedIconBackground,
                unfocusedIconTint)
    }
    
    private func unfocusedEmptyInvalidTextFieldOptions() -> TextFieldAppearanceOptions {
        return (unfocusedBackgroundColor,
                unfocusedTextColor,
                unfocusedPlaceholderColor,
                bigPlaceholderFont,
                invalidIconBackground,
                unfocusedIconTint)
    }
}
