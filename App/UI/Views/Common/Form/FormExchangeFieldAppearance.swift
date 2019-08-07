//
//  FormExchangeFieldAppearance.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 06/08/2019.
//  Copyright © 2019 Real Tranzit. All rights reserved.
//

import UIKit

typealias FieldAppearanceOptions = (backgroundColor: UIColor,
                                    iconBackgroundColor: UIColor,
                                    iconTint: UIColor,
                                    focusLineColor: UIColor)

typealias TextAppearanceOptions = ( textBackground: UIColor,
                                    textColor: UIColor,
                                    currencyColor: UIColor,
                                    placeholderColor: UIColor,
                                    placeholderFont: UIFont?)

typealias ExchangeFieldAppearanceOptions = (fieldAppearance: FieldAppearanceOptions,
                                            amountAppearance: TextAppearanceOptions,
                                            convertedAmountAppearance: TextAppearanceOptions)

extension FormExchangeField {
    func appearanceOptions() -> ExchangeFieldAppearanceOptions {
        switch (amountTextFieldState, convertedAmountTextFieldState) {
        case (.focusedEmptyValid, .unfocusedEmptyValid),
             (.focusedEmptyValid, .unfocusedEmptyInvalid),
             (.focusedEmptyInvalid, .unfocusedEmptyValid),
             (.focusedEmptyInvalid, .unfocusedEmptyInvalid): return focusedAmountAmountEmptyConvertedEmptyOptions()
        case (.focusedEmptyValid, .unfocusedPresentValid),
             (.focusedEmptyValid, .unfocusedPresentInvalid),
             (.focusedEmptyInvalid, .unfocusedPresentValid),
             (.focusedEmptyInvalid, .unfocusedPresentInvalid): return focusedAmountAmountEmptyConvertedPresentOptions()
        case (.focusedPresentValid, .unfocusedEmptyValid),
             (.focusedPresentValid, .unfocusedEmptyInvalid),
             (.focusedPresentInvalid, .unfocusedEmptyValid),
             (.focusedPresentInvalid, .unfocusedEmptyInvalid): return focusedAmountAmountPresentConvertedEmptyOptions()
        case (.focusedPresentValid, .unfocusedPresentValid),
             (.focusedPresentValid, .unfocusedPresentInvalid),
             (.focusedPresentInvalid, .unfocusedPresentValid),
             (.focusedPresentInvalid, .unfocusedPresentInvalid): return focusedAmountAmountPresentConvertedPresentOptions()
            
        case (.unfocusedEmptyValid, .focusedEmptyValid),
             (.unfocusedEmptyValid, .focusedEmptyInvalid),
             (.unfocusedEmptyInvalid, .focusedEmptyValid),
             (.unfocusedEmptyInvalid, .focusedEmptyInvalid): return focusedConvertedAmountEmptyConvertedEmptyOptions()
        case (.unfocusedEmptyValid, .focusedPresentValid),
             (.unfocusedEmptyValid, .focusedPresentInvalid),
             (.unfocusedEmptyInvalid, .focusedPresentValid),
             (.unfocusedEmptyInvalid, .focusedPresentInvalid): return focusedConvertedAmountEmptyConvertedPresentOptions()
        case (.unfocusedPresentValid, .focusedEmptyValid),
             (.unfocusedPresentValid, .focusedEmptyInvalid),
             (.unfocusedPresentInvalid, .focusedEmptyValid),
             (.unfocusedPresentInvalid, .focusedEmptyInvalid): return focusedConvertedAmountPresentConvertedEmptyOptions()
        case (.unfocusedPresentValid, .focusedPresentValid),
             (.unfocusedPresentValid, .focusedPresentInvalid),
             (.unfocusedPresentInvalid, .focusedPresentValid),
             (.unfocusedPresentInvalid, .focusedPresentInvalid): return focusedConvertedAmountPresentConvertedPresentOptions()
            
        case (.unfocusedEmptyValid, .unfocusedEmptyValid): return unfocusedValidAmountEmptyConvertedEmptyOptions()
        case (.unfocusedPresentValid, .unfocusedEmptyValid): return unfocusedValidAmountPresentConvertedEmptyOptions()
        case (.unfocusedEmptyValid, .unfocusedPresentValid): return unfocusedValidAmountEmptyConvertedPresentOptions()
        case (.unfocusedPresentValid, .unfocusedPresentValid): return unfocusedValidAmountPresentConvertedPresentOptions()
            
        case (.unfocusedEmptyInvalid, .unfocusedEmptyInvalid),
             (.unfocusedEmptyInvalid, .unfocusedEmptyValid),
             (.unfocusedEmptyValid, .unfocusedEmptyInvalid): return unfocusedInvalidAmountEmptyConvertedEmptyOptions()
        case (.unfocusedPresentInvalid, .unfocusedEmptyInvalid),
             (.unfocusedPresentInvalid, .unfocusedEmptyValid),
             (.unfocusedPresentValid, .unfocusedEmptyInvalid): return unfocusedInvalidAmountPresentConvertedEmptyOptions()
        case (.unfocusedEmptyInvalid, .unfocusedPresentInvalid),
             (.unfocusedEmptyInvalid, .unfocusedPresentValid),
             (.unfocusedEmptyValid, .unfocusedPresentInvalid): return unfocusedInvalidAmountEmptyConvertedPresentOptions()
        case (.unfocusedPresentInvalid, .unfocusedPresentInvalid),
             (.unfocusedPresentInvalid, .unfocusedPresentValid),
             (.unfocusedPresentValid, .unfocusedPresentInvalid): return unfocusedInvalidAmountPresentConvertedPresentOptions()
        default:
            return unfocusedValidAmountEmptyConvertedEmptyOptions()
        }
    }
    
    private func focusedAmountAmountEmptyConvertedEmptyOptions() -> ExchangeFieldAppearanceOptions {
        return (focusedFieldAppearance(), focusedEmptyTextFieldOptions(), focusedOtherEmptyTextFieldOptions())
    }
    
    private func focusedAmountAmountPresentConvertedEmptyOptions() -> ExchangeFieldAppearanceOptions {
        return (focusedFieldAppearance(), focusedPresentTextFieldOptions(), focusedOtherEmptyTextFieldOptions())
    }
    
    private func focusedAmountAmountEmptyConvertedPresentOptions() -> ExchangeFieldAppearanceOptions {
        return (focusedFieldAppearance(), focusedEmptyTextFieldOptions(), focusedOtherPresentTextFieldOptions())
    }
    
    private func focusedAmountAmountPresentConvertedPresentOptions() -> ExchangeFieldAppearanceOptions {
        return (focusedFieldAppearance(), focusedPresentTextFieldOptions(), focusedOtherPresentTextFieldOptions())
    }
    
    private func focusedConvertedAmountEmptyConvertedEmptyOptions() -> ExchangeFieldAppearanceOptions {
        return (focusedFieldAppearance(), focusedOtherEmptyTextFieldOptions(), focusedEmptyTextFieldOptions())
    }
    
    private func focusedConvertedAmountPresentConvertedEmptyOptions() -> ExchangeFieldAppearanceOptions {
        return (focusedFieldAppearance(), focusedOtherPresentTextFieldOptions(), focusedEmptyTextFieldOptions())
    }
    
    private func focusedConvertedAmountEmptyConvertedPresentOptions() -> ExchangeFieldAppearanceOptions {
        return (focusedFieldAppearance(), focusedOtherEmptyTextFieldOptions(), focusedPresentTextFieldOptions())
    }
    
    private func focusedConvertedAmountPresentConvertedPresentOptions() -> ExchangeFieldAppearanceOptions {
        return (focusedFieldAppearance(), focusedOtherPresentTextFieldOptions(), focusedPresentTextFieldOptions())
    }
    
    private func unfocusedValidAmountEmptyConvertedEmptyOptions() -> ExchangeFieldAppearanceOptions {
        return (unfocusedValidFieldAppearance(), unfocusedEmptyTextFieldOptions(), unfocusedEmptyTextFieldOptions())
    }
    
    private func unfocusedValidAmountPresentConvertedEmptyOptions() -> ExchangeFieldAppearanceOptions {
        return (unfocusedValidFieldAppearance(), unfocusedPresentTextFieldOptions(), unfocusedEmptyTextFieldOptions())
    }
    
    private func unfocusedValidAmountEmptyConvertedPresentOptions() -> ExchangeFieldAppearanceOptions {
        return (unfocusedValidFieldAppearance(), unfocusedEmptyTextFieldOptions(), unfocusedPresentTextFieldOptions())
    }
    
    private func unfocusedValidAmountPresentConvertedPresentOptions() -> ExchangeFieldAppearanceOptions {
        return (unfocusedValidFieldAppearance(), unfocusedPresentTextFieldOptions(), unfocusedPresentTextFieldOptions())
    }
    
    private func unfocusedInvalidAmountEmptyConvertedEmptyOptions() -> ExchangeFieldAppearanceOptions {
        return (unfocusedInvalidFieldAppearance(), unfocusedEmptyTextFieldOptions(), unfocusedEmptyTextFieldOptions())
    }
    
    private func unfocusedInvalidAmountPresentConvertedEmptyOptions() -> ExchangeFieldAppearanceOptions {
        return (unfocusedInvalidFieldAppearance(), unfocusedPresentTextFieldOptions(), unfocusedEmptyTextFieldOptions())
    }
    
    private func unfocusedInvalidAmountEmptyConvertedPresentOptions() -> ExchangeFieldAppearanceOptions {
        return (unfocusedInvalidFieldAppearance(), unfocusedEmptyTextFieldOptions(), unfocusedPresentTextFieldOptions())
    }
    
    private func unfocusedInvalidAmountPresentConvertedPresentOptions() -> ExchangeFieldAppearanceOptions {
        return (unfocusedInvalidFieldAppearance(), unfocusedPresentTextFieldOptions(), unfocusedPresentTextFieldOptions())
    }
    
    private func focusedFieldAppearance() -> FieldAppearanceOptions {
        return (focusedBackgroundColor,
                focusedIconBackground,
                focusedIconTint,
                selectedLineColor)
    }
    
    private func unfocusedValidFieldAppearance() -> FieldAppearanceOptions {
        return (unfocusedBackgroundColor,
                unfocusedIconBackground,
                unfocusedIconTint,
                lineColor)
    }
    
    private func unfocusedInvalidFieldAppearance() -> FieldAppearanceOptions {
        return (unfocusedBackgroundColor,
                invalidIconBackground,
                unfocusedIconTint,
                lineColor)
    }
    
    
    private func focusedPresentTextFieldOptions() -> TextAppearanceOptions {
        return (focusedFieldBackgroundColor,
                focusedTextColor,
                focusedCurrencyColor,
                focusedPlaceholderWithTextColor,
                smallPlaceholderFont)
    }
    
    private func focusedEmptyTextFieldOptions() -> TextAppearanceOptions {
        return (focusedFieldBackgroundColor,
                focusedTextColor,
                focusedCurrencyColor,
                focusedPlaceholderNoTextColor,
                bigPlaceholderFont)
    }
    
    private func focusedOtherPresentTextFieldOptions() -> TextAppearanceOptions {
        return (unfocusedFieldBackgroundColor,
                focusedTextColor,
                focusedCurrencyColor,
                focusedPlaceholderWithTextColor,
                smallPlaceholderFont)
    }
    
    private func focusedOtherEmptyTextFieldOptions() -> TextAppearanceOptions {
        return (unfocusedFieldBackgroundColor,
                focusedTextColor,
                focusedCurrencyColor,
                focusedPlaceholderNoTextColor,
                bigPlaceholderFont)
    }
    
    private func unfocusedPresentTextFieldOptions() -> TextAppearanceOptions {
        return (unfocusedFieldBackgroundColor,
                unfocusedTextColor,
                unfocusedCurrencyColor,
                unfocusedPlaceholderColor,
                smallPlaceholderFont)
    }
    
    private func unfocusedEmptyTextFieldOptions() -> TextAppearanceOptions {
        return (unfocusedFieldBackgroundColor,
                unfocusedTextColor,
                unfocusedCurrencyColor,
                unfocusedPlaceholderColor,
                bigPlaceholderFont)
    }    
}
