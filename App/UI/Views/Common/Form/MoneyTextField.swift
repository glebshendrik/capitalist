//
//  MoneyTextField.swift
//  Capitalist
//
//  Created by Alexander Petropavlovsky on 27/12/2018.
//  Copyright © 2018 Real Tranzit. All rights reserved.
//

import UIKit
import SkyFloatingLabelTextField

class MoneyTextField: FloatingTextField {
    private var currencyFormatter: NumberFormatter?
    private var decimalFormatter: NumberFormatter?
    
    var currency: Currency? = nil {
        didSet {
            updateCurrencyFormatter()
        }
    }
    
    var numberValue: NSNumber? {
        guard let textValue = text else { return nil }
        return currencyFormatter?.number(from: textValue)
    }
    
    var rewriteModeEnabled: Bool = false
    
    private func updateCurrencyFormatter() {
        guard let currency = currency else {
            currencyFormatter = nil
            decimalFormatter = nil
            return
        }
        currencyFormatter = Formatter.currency(with: currency)
        decimalFormatter = Formatter.decimal(with: currency)
    }
    
    override func didMoveToSuperview() {
        keyboardType = .decimalPad

        addTarget(self, action: #selector(textFieldEditingDidBegin(_:)), for: UIControl.Event.editingDidBegin)
        addTarget(self, action: #selector(textFieldEditingChanged(_:)), for: UIControl.Event.editingChanged)
        addTarget(self, action: #selector(textFieldEditingDidEnd(_:)), for: UIControl.Event.editingDidEnd)
    }
    
    @objc internal func textFieldEditingDidBegin(_ sender: UITextField) {
        guard let value = numberValue else { return }
        text = decimalFormatter?.string(from: value)
    }
    
    @objc internal func textFieldEditingChanged(_ sender: UITextField) {
        text = formattedText()
    }
    
    @objc internal func textFieldEditingDidEnd(_ sender: UITextField) {
        guard let textValue = text,
            let value = decimalFormatter?.number(from: textValue) else { return }
        text = decimalFormatter?.string(from: value)
    }
    
    private func formattedText() -> String? {
        guard   var textValue = text,
                let currencyFormatter = currencyFormatter else {
            // don't format nil text or if it doesn't conrain decimal separator yet
            return text
        }
        
        // Check if inputstr does not contain the Locale decimal separator
        if !textValue.contains(currencyFormatter.decimalSeparator) {
            //  No LocaleDecimalSeparator in inputstr or wrong LocaleDecimalSeparator in inputstr
            //  If there is a "." in inputstr replace by ","
            if textValue.contains(".") {
                textValue = textValue.replacingOccurrences(of: ".", with: currencyFormatter.decimalSeparator)
            } else if textValue.contains(",") {
                //  Else replace "," by "."
                textValue = textValue.replacingOccurrences(of: ",", with: currencyFormatter.decimalSeparator)
            }
        }
        
        guard textValue.contains(currencyFormatter.decimalSeparator) else { return textValue }
        
        guard currencyFormatter.maximumFractionDigits > 0 else {
            // remove decimal separator if max fraction digits <= 0
            return textValue.replacingOccurrences(of: currencyFormatter.decimalSeparator, with: "")
        }
        
        var decimalFixedValue = textValue
        
        // if there is more than one decimal separator in text
        if textValue.components(separatedBy: currencyFormatter.decimalSeparator).count - 1 > 1 {
            // find range of the last separator
            let lastSeparatorRange = textValue.range(
                of: currencyFormatter.decimalSeparator,
                options: NSString.CompareOptions.backwards,
                range: textValue.startIndex..<textValue.endIndex,
                locale: currencyFormatter.locale)
            
            // and replace it with empty string
            decimalFixedValue = textValue.replacingOccurrences(
                of: currencyFormatter.decimalSeparator,
                with: "",
                options: [NSString.CompareOptions.backwards],
                range: lastSeparatorRange)
        }
        
        let splittedNumberBySeparator = decimalFixedValue.components(separatedBy: currencyFormatter.decimalSeparator)
        
        guard   splittedNumberBySeparator.count > 1,
                let number = splittedNumberBySeparator.first,
                var fractionalDigits = splittedNumberBySeparator.last,
                case let removeCount = fractionalDigits.count - currencyFormatter.maximumFractionDigits,
                removeCount > 0 else {
            
            // if decimal satisfy currency formatter
            return decimalFixedValue
        }
        
        // if fractionalDigits more than allowed count
        if let truncatedFraction = fractionalDigits.slicing(from: 0, length: fractionalDigits.count - removeCount) {
            fractionalDigits = truncatedFraction
        }
        
        return number + currencyFormatter.decimalSeparator + fractionalDigits
    }
}
