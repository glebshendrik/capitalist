//
//  Numbers.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 30/07/2019.
//  Copyright © 2019 Real Tranzit. All rights reserved.
//

import Foundation

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
    func intMoney(with currency: Currency?) -> Int? {
        guard let currency = currency else { return nil }
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
    
    func moneyCurrencyString(with currency: Currency, shouldRound: Bool) -> String? {
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

func +(lhs: NSDecimalNumber, rhs: NSDecimalNumber) -> NSDecimalNumber {
    return lhs.adding(rhs)
}

extension Int {
    func moneyNumber(with currency: Currency) -> NSDecimalNumber {
        return NSDecimalNumber(integerLiteral: self).moneyNumber(with: currency)
    }
    
    func moneyDecimalString(with currency: Currency) -> String? {
        return NSDecimalNumber(integerLiteral: self).moneyDecimalString(with: currency)
    }
    
    func moneyDecimalString(with currency: Currency?) -> String? {
        guard let currency = currency else { return nil }
        return NSDecimalNumber(integerLiteral: self).moneyDecimalString(with: currency)
    }
    
    func moneyCurrencyString(with currency: Currency, shouldRound: Bool) -> String? {
        return NSDecimalNumber(integerLiteral: self).moneyCurrencyString(with: currency, shouldRound: shouldRound)
    }
}
