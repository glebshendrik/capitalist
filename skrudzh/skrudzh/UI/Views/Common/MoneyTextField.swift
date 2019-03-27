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
    private var currencyFormatter: NumberFormatter?
    private var decimalFormatter: NumberFormatter?
    
    var currency: Currency? = nil {
        didSet {
            updateCurrencyFormatter()
        }
    }
    
    private func updateCurrencyFormatter() {
        guard let currency = currency else {
            currencyFormatter = nil
            decimalFormatter = nil
            return
        }
        currencyFormatter = Formatter.currency(with: currency)
        decimalFormatter = Formatter.decimal(with: currency)
    }
    
    var numberValue: NSNumber? {
        guard let textValue = text else { return nil }
        return currencyFormatter?.number(from: textValue)
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
        
//        NSString *locDecSeparator = [[NSLocale currentLocale] decimalSeparator];
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

extension NumberFormatter {
    convenience init(numberStyle: Style) {
        self.init()
        self.numberStyle = numberStyle
    }
}

struct Formatter {
    static func decimal(with currency: Currency) -> NumberFormatter {
        let currencyFormatter = Formatter.currency(with: currency)
        let formatter = NumberFormatter(numberStyle: .decimal)
        formatter.locale = Locale.current
        formatter.groupingSeparator = ""
        formatter.generatesDecimalNumbers = true
        formatter.minimumFractionDigits = currencyFormatter.minimumFractionDigits
        formatter.maximumFractionDigits = currencyFormatter.maximumFractionDigits
        return formatter
    }
    
    static func currency(with currency: Currency) -> NumberFormatter {
        let formatter = NumberFormatter(numberStyle: .currency)
        formatter.locale = Locale.current
        formatter.currencyCode = currency.code
        formatter.currencySymbol = currency.symbol
        formatter.internationalCurrencySymbol = currency.symbol
        formatter.maximumFractionDigits = Int(log10(Double(currency.subunitToUnit)))
        formatter.minimumFractionDigits = 0
        
        formatter.positiveFormat = formatter.positiveFormat.replacingOccurrences(of: "¤", with: "")
        formatter.positiveFormat = formatter.positiveFormat.replacingOccurrences(of: " ", with: "")
        
        if let format = formatter.positiveFormat {
            formatter.positiveFormat = currency.symbolFirst ? "¤\(format)" : "\(format)¤"
        }
        
        return formatter
    }
}

extension String {
    func intMoney(with currency: Currency) -> Int? {
        guard let decimal = Formatter.decimal(with: currency).number(from: self) as? NSDecimalNumber else {
            return nil
        }
        let multiplyFactor = NSDecimalNumber(value: currency.subunitToUnit)
        return decimal.multiplying(by: multiplyFactor).intValue
    }
}

extension NSDecimalNumber {
    func moneyNumber(with currency: Currency) -> NSDecimalNumber {
        let divideFactor = NSDecimalNumber(value: currency.subunitToUnit)
        return self.dividing(by: divideFactor)
    }
    
    func moneyDecimalString(with currency: Currency) -> String? {
        return Formatter.decimal(with: currency).string(from: moneyNumber(with: currency))
    }
}

extension Int {
    func moneyNumber(with currency: Currency) -> NSDecimalNumber {
        let divideFactor = NSDecimalNumber(value: currency.subunitToUnit)
        return NSDecimalNumber(value: self).dividing(by: divideFactor)
    }
    
    func moneyDecimalString(with currency: Currency) -> String? {
        return Formatter.decimal(with: currency).string(from: moneyNumber(with: currency))
    }
    
    func moneyCurrencyString(with currency: Currency, shouldRound: Bool = true) -> String? {
        let formatter = Formatter.currency(with: currency)
        
        var number = moneyNumber(with: currency)
        
        struct Abbreviation {
            var threshold: Double
            var divisor: NSDecimalNumber
            var suffix: String
        }
        
        let abbreviations = [Abbreviation(      threshold: 1000000.0, divisor: 1000.0, suffix: "k "),
                             Abbreviation(   threshold: 1000000000.0, divisor: 1000000.0, suffix: "M "),
                             Abbreviation(threshold: 1000000000000.0, divisor: 10000000000.0, suffix: "M+ "),]
        
        let startValue = number.doubleValue.abs
        
        let abbreviation = abbreviations.last(where: { startValue >= $0.threshold })
        let suffix = abbreviation?.suffix ?? ""
        
        if let abbreviation = abbreviation {
            number = number.dividing(by: abbreviation.divisor)
        }

        if shouldRound {
            let roundingHandler = NSDecimalNumberHandler(roundingMode: .down,
                                                         scale: 0,
                                                         raiseOnExactness: false,
                                                         raiseOnOverflow: false,
                                                         raiseOnUnderflow: false,
                                                         raiseOnDivideByZero: false)
            number = number.rounding(accordingToBehavior: roundingHandler)
            formatter.numberStyle = .none
            formatter.roundingMode = .down
            formatter.maximumFractionDigits = 0
        }
        
        formatter.positiveFormat = formatter.positiveFormat.replacingOccurrences(of: "¤", with: "")
        formatter.positiveFormat = formatter.positiveFormat.replacingOccurrences(of: " ", with: "")
        formatter.negativeFormat = formatter.negativeFormat.replacingOccurrences(of: "¤", with: "")
        formatter.negativeFormat = formatter.negativeFormat.replacingOccurrences(of: " ", with: "")
        
        if let format = formatter.positiveFormat {
            formatter.positiveFormat = currency.symbolFirst ? "¤\(format)\(suffix)" : "\(format)\(suffix)¤"
        }
        
        if let format = formatter.negativeFormat {
            formatter.negativeFormat = currency.symbolFirst ? "¤\(format)\(suffix)" : "\(format)\(suffix)¤"
        }
        
        guard var formattedString = formatter.string(from: number) else { return nil }
        
        if  let firstSuffixCharacter = suffix.first,
            let indexOfFirstSuffixCharacter = formattedString.firstIndex(of: firstSuffixCharacter) {
            let indexOfSpace = formattedString.index(before: indexOfFirstSuffixCharacter)
            formattedString.remove(at: indexOfSpace)
            return formattedString
        }

        return formattedString
    }
}
