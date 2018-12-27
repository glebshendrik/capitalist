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
    private var currencyFormatter: NumberFormatter = NumberFormatter()
    private var internalNumberFormatter: NumberFormatter = NumberFormatter()
    
    // MARK: Public
    /// Returns current number value
    var numberValue: NSNumber? {
        guard let textValue = text,
            let numberValue = currencyFormatter.number(from: textValue) else { return nil }
        
        return numberValue
    }
    
    func set(number: NSNumber?) {
        if let number = number {
            text = internalNumberFormatter.string(from: number)
        }
    }
    
    override func didMoveToSuperview() {
        currencyFormatter.numberStyle = .currency
        currencyFormatter.currencySymbol = "₽"
        
        internalNumberFormatter.numberStyle = .decimal
        internalNumberFormatter.groupingSeparator = ""
        
        internalNumberFormatter.minimumFractionDigits = currencyFormatter.minimumFractionDigits
        internalNumberFormatter.maximumFractionDigits = currencyFormatter.maximumFractionDigits
        
        keyboardType = .decimalPad
        
        addTarget(self, action: #selector(textFieldEditingDidBegin(_:)), for: UIControl.Event.editingDidBegin)
        addTarget(self, action: #selector(textFieldEditingChanged(_:)), for: UIControl.Event.editingChanged)
        addTarget(self, action: #selector(textFieldEditingDidEnd(_:)), for: UIControl.Event.editingDidEnd)
    }
    
    @objc internal func textFieldEditingDidBegin(_ sender: UITextField) {
        guard let value = numberValue else { return }
        
        text = internalNumberFormatter.string(from: value)
    }
    
    @objc internal func textFieldEditingChanged(_ sender: UITextField) {
//        if text == nil || text!.trimmed.isEmpty {
//            text = "0"
//        }
        guard let textValue = text, textValue.contains(currencyFormatter.decimalSeparator) else { return }
        
        if currencyFormatter.maximumFractionDigits == 0 {
            text = textValue.replacingOccurrences(of: currencyFormatter.decimalSeparator, with: "")
        } else {
            let decimalFixedValue: String
            
            if textValue.components(separatedBy: currencyFormatter.decimalSeparator).count-1 > 1 {
                let lastSeparatorRange = textValue.range(
                    of: currencyFormatter.decimalSeparator,
                    options: NSString.CompareOptions.backwards,
                    range: textValue.startIndex..<textValue.endIndex,
                    locale: currencyFormatter.locale)
                
                decimalFixedValue = textValue.replacingOccurrences(
                    of: currencyFormatter.decimalSeparator,
                    with: "",
                    options: [NSString.CompareOptions.backwards],
                    range: lastSeparatorRange)
            } else {
                decimalFixedValue = textValue
            }
            
            let splittedNumberBySeparator = decimalFixedValue.components(separatedBy: currencyFormatter.decimalSeparator)
            
            if splittedNumberBySeparator.count > 1,
                let number = splittedNumberBySeparator.first,
                let fractionalDigits = splittedNumberBySeparator.last,
                case let removeCount = fractionalDigits.characters.count - currencyFormatter.maximumFractionDigits, removeCount > 0 {
                let removedFraction = fractionalDigits.substring(with: fractionalDigits.startIndex..<fractionalDigits.characters.index(fractionalDigits.endIndex, offsetBy: -removeCount))
                text = number + currencyFormatter.decimalSeparator + removedFraction
            } else {
                text = decimalFixedValue
            }
        }
    }
    
    @objc internal func textFieldEditingDidEnd(_ sender: UITextField) {
        guard let textValue = text,
            let value = internalNumberFormatter.number(from: textValue) else { return }
        
        text = internalNumberFormatter.string(from: value)
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
        return formatter
    }
}
extension UITextField {
    var string: String { return text ?? "" }
}

extension String {
    private static var digitsPattern = UnicodeScalar("0")..."9"
    var digits: String {
        return unicodeScalars.filter { String.digitsPattern ~= $0 }.string
    }
}

extension Sequence where Iterator.Element == UnicodeScalar {
    var string: String { return String(String.UnicodeScalarView(self)) }
}
