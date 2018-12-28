//
//  MoneyTextField.swift
//  skrudzh
//
//  Created by Alexander Petropavlovsky on 27/12/2018.
//  Copyright © 2018 rubikon. All rights reserved.
//

import UIKit
import SkyFloatingLabelTextField

class MoneyTextField: SkyFloatingLabelTextField {
    private var currencyFormatter: NumberFormatter = Formatter.currency
    private var decimalFormatter: NumberFormatter = Formatter.decimal
    
    var numberValue: NSNumber? {
        guard let textValue = text else { return nil }
        return currencyFormatter.number(from: textValue)
    }
    
    override func didMoveToSuperview() {
        keyboardType = .decimalPad        
        addTarget(self, action: #selector(textFieldEditingDidBegin(_:)), for: UIControl.Event.editingDidBegin)
        addTarget(self, action: #selector(textFieldEditingChanged(_:)), for: UIControl.Event.editingChanged)
        addTarget(self, action: #selector(textFieldEditingDidEnd(_:)), for: UIControl.Event.editingDidEnd)
    }
    
    @objc internal func textFieldEditingDidBegin(_ sender: UITextField) {
        guard let value = numberValue else { return }
        text = decimalFormatter.string(from: value)
    }
    
    @objc internal func textFieldEditingChanged(_ sender: UITextField) {
        text = formattedText()
    }
    
    @objc internal func textFieldEditingDidEnd(_ sender: UITextField) {
        guard let textValue = text,
            let value = decimalFormatter.number(from: textValue) else { return }
        text = decimalFormatter.string(from: value)
    }
    
    private func formattedText() -> String? {
        guard   let textValue = text,
                textValue.contains(currencyFormatter.decimalSeparator) else {
            // don't format nil text or if it doesn't conrain decimal separator yet
            return text
        }
        
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

extension NumberFormatter {
    convenience init(numberStyle: Style) {
        self.init()
        self.numberStyle = numberStyle
    }
}

struct Formatter {
    static var decimal : NumberFormatter {
        let formatter = NumberFormatter(numberStyle: .decimal)
        formatter.groupingSeparator = ""
        formatter.generatesDecimalNumbers = true
        formatter.minimumFractionDigits = Formatter.currency.minimumFractionDigits
        formatter.maximumFractionDigits = Formatter.currency.maximumFractionDigits
        return formatter
    }
    
    static var currency : NumberFormatter {
        let formatter = NumberFormatter(numberStyle: .currency)
        formatter.locale = Locale.current
        return formatter
    }
}

extension String {
    var intMoney: Int? {
        guard let decimal = Formatter.decimal.number(from: self) as? NSDecimalNumber else {
            return nil
        }
        let multiplyFactor = NSDecimalNumber(value: 10).raising(toPower: Formatter.decimal.maximumFractionDigits)
        return decimal.multiplying(by: multiplyFactor).intValue
    }
}

extension Int {
    var moneyNumber: NSDecimalNumber {
        let divideFactor = NSDecimalNumber(value: 10).raising(toPower: Formatter.currency.maximumFractionDigits)
        return NSDecimalNumber(value: self).dividing(by: divideFactor)
    }
    
    var moneyDecimalString: String? {
        return Formatter.decimal.string(from: moneyNumber)
    }
    
    func moneyStringWithCurrency(symbol: String) -> String? {
        let formatter = Formatter.currency
        formatter.currencySymbol = symbol
        return formatter.string(from: moneyNumber)
    }
}
