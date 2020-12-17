//
//  CreditTypeViewModel.swift
//  Capitalist
//
//  Created by Alexander Petropavlovsky on 28/09/2019.
//  Copyright © 2019 Real Tranzit. All rights reserved.
//

import Foundation

class CreditTypeViewModel {
    public private(set) var creditType: CreditType
    
    var id: Int {
        return creditType.id
    }
        
    var name: String {
        return creditType.localizedName
    }
    
    var periodUnit: PeriodUnit {
        return creditType.periodUnit
    }
    
    var minValue: Int {
        return creditType.minValue
    }
    
    var minValueFormatted: String {
        return formatted(value: minValue)
    }
    
    var maxValue: Int {
        return creditType.maxValue
    }
    
    var maxValueFormatted: String {
        return formatted(value: maxValue)
    }
    
    var defaultValue: Int {
        return creditType.defaultValue
    }
    
    var hasMonthlyPayments: Bool {
        return creditType.hasMonthlyPayments
    }
    
    var periodSuperUnit: PeriodUnit? {
        return creditType.periodSuperUnit
    }
    
    var unitsInSuperUnit: Int? {
        return creditType.unitsInSuperUnit
    }
    
    var rowOrder: Int {
        return creditType.rowOrder
    }
    
    var deletedAt: Date? {
        return creditType.deletedAt
    }
    
    var isDefault: Bool {
        return creditType.isDefault
    }
    
    init(creditType: CreditType) {
        self.creditType = creditType
    }
    
    func formatted(value: Int) -> String {
        func formatString(for unit: PeriodUnit) -> String {
            switch unit {
            case .days:
                return NSLocalizedString("period unit days", comment: "")
            case .months:
                return NSLocalizedString("period unit months", comment: "")
            case .years:
                return NSLocalizedString("period unit years", comment: "")
            }
        }
        
        guard   let periodSuperUnit = periodSuperUnit,
                let unitsInSuperUnit = unitsInSuperUnit,
                value >= unitsInSuperUnit else {
            return String.localizedStringWithFormat(formatString(for: periodUnit), value)
        }
        
        let parentUnits = value / unitsInSuperUnit
        let remainingUnits = value % unitsInSuperUnit
    
        let parentUnitsFormatted = String.localizedStringWithFormat(formatString(for: periodSuperUnit), parentUnits)
        let unitsFormatted = String.localizedStringWithFormat(formatString(for: periodUnit), remainingUnits)
        
        return remainingUnits == 0 ? "\(parentUnitsFormatted)" : "\(parentUnitsFormatted) \(unitsFormatted)"
    }
}
