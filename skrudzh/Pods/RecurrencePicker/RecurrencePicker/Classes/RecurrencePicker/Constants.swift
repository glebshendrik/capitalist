//
//  Constants.swift
//  RecurrencePicker
//
//  Created by Xin Hong on 16/4/7.
//  Copyright © 2016年 Teambition. All rights reserved.
//

import UIKit
import EventKit

internal struct CellID {
    static let commonCell = "CommonCell"
    static let basicRecurrenceCell = "BasicRecurrenceCell"
    static let customRecurrenceViewCell = "CustomRecurrenceViewCell"
    static let pickerViewCell = "PickerViewCell"
    static let selectorItemCell = "SelectorItemCell"
    static let monthOrDaySelectorCell = "MonthOrDaySelectorCell"
}

internal struct Constant {
    static let defaultRowHeight: CGFloat = 44
    static let pickerViewCellHeight: CGFloat = 215
    static let pickerRowHeight: CGFloat = 40
    static let pickerMaxRowCount = 999
    static let detailTextColor = UIColor.gray

    static let selectorVerticalPadding: CGFloat = 1
    static let gridLineWidth: CGFloat = 0.5
    static let gridLineColor = UIColor(white: 187.0 / 255.0, alpha: 1)
    static let gridLineName = "RecurrencePicker.GridSelectorViewGridLine"
}

internal extension Constant {
    static let frequencies: [RecurrenceFrequency] = {
        return [.daily, .weekly, .monthly, .yearly]
    }()

    static let weekdays: [EKWeekday] = {
        return [.monday, .tuesday, .wednesday, .thursday, .friday, .saturday, .sunday]
    }()

    static func weekdaySymbols(of language: RecurrencePickerLanguage = InternationalControl.shared.language) -> [String] {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: language.identifier)
        var weekdaySymbols = dateFormatter.weekdaySymbols!
        weekdaySymbols.insert(weekdaySymbols.remove(at: 0), at: 6)
        return weekdaySymbols
    }

    static func shortMonthSymbols(of language: RecurrencePickerLanguage = InternationalControl.shared.language) -> [String] {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: language.identifier)
        return dateFormatter.shortMonthSymbols
    }

    static func monthSymbols(of language: RecurrencePickerLanguage = InternationalControl.shared.language) -> [String] {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: language.identifier)
        return language == .russian ? dateFormatter.standaloneMonthSymbols : dateFormatter.monthSymbols
    }

    static func basicRecurrenceStrings(of language: RecurrencePickerLanguage = InternationalControl.shared.language) -> [String] {
        let internationalControl = InternationalControl(language: language)
        return [internationalControl.localizedString("basicRecurrence.never"),
                internationalControl.localizedString("basicRecurrence.everyDay"),
                internationalControl.localizedString("basicRecurrence.everyWeek"),
                internationalControl.localizedString("basicRecurrence.everyTwoWeeks"),
                internationalControl.localizedString("basicRecurrence.everyMonth"),
                internationalControl.localizedString("basicRecurrence.everyYear"),
                internationalControl.localizedString("basicRecurrence.everyWeekday"),]
    }

    static func frequencyStrings(of language: RecurrencePickerLanguage = InternationalControl.shared.language) -> [String] {
        let internationalControl = InternationalControl(language: language)
        return [internationalControl.localizedString("frequency.daily"),
                internationalControl.localizedString("frequency.weekly"),
                internationalControl.localizedString("frequency.monthly"),
                internationalControl.localizedString("frequency.yearly"),]
    }

    static func unitStrings(of language: RecurrencePickerLanguage = InternationalControl.shared.language) -> [String] {
        let internationalControl = InternationalControl(language: language)
        return [internationalControl.localizedString("unit.day"),
                internationalControl.localizedString("unit.week"),
                internationalControl.localizedString("unit.month"),
                internationalControl.localizedString("unit.year"),]
    }

    static func pluralUnitStrings(of language: RecurrencePickerLanguage = InternationalControl.shared.language, interval: Int) -> [String] {

        guard language == .russian else {
            return pluralFewUnitStrings(of: language)
        }
        
        if (interval % 10 == 1
            &&
            interval % 100 != 11) {
            
            return Constant.pluralOneUnitStrings(of: language)
        }
        else
            if ((interval % 10 >= 2 && interval % 10 <= 4)
                &&
                !(interval % 100 >= 12 && interval % 100 <= 14)) {
                
                return Constant.pluralFewUnitStrings(of: language)
            }
            else
                if (interval % 10 == 0
                    ||
                    (interval % 10 >= 5 && interval % 10 <= 9)
                    ||
                    (interval % 100 >= 11 && interval % 100 <= 14)) {
                    
                    return Constant.pluralManyUnitStrings(of: language)
        }
        return Constant.pluralFewUnitStrings(of: language)
    }
    
    static func pluralOneUnitStrings(of language: RecurrencePickerLanguage = InternationalControl.shared.language) -> [String] {
        let internationalControl = InternationalControl(language: language)
        return [internationalControl.localizedString("pluralOneUnit.day"),
                internationalControl.localizedString("pluralOneUnit.week"),
                internationalControl.localizedString("pluralOneUnit.month"),
                internationalControl.localizedString("pluralOneUnit.year"),]
    }
    
    static func pluralFewUnitStrings(of language: RecurrencePickerLanguage = InternationalControl.shared.language) -> [String] {
        let internationalControl = InternationalControl(language: language)
        return [internationalControl.localizedString("pluralUnit.day"),
                internationalControl.localizedString("pluralUnit.week"),
                internationalControl.localizedString("pluralUnit.month"),
                internationalControl.localizedString("pluralUnit.year"),]
    }
    
    static func pluralManyUnitStrings(of language: RecurrencePickerLanguage = InternationalControl.shared.language) -> [String] {
        let internationalControl = InternationalControl(language: language)
        return [internationalControl.localizedString("pluralManyUnit.day"),
                internationalControl.localizedString("pluralManyUnit.week"),
                internationalControl.localizedString("pluralManyUnit.month"),
                internationalControl.localizedString("pluralManyUnit.year"),]
    }
}
