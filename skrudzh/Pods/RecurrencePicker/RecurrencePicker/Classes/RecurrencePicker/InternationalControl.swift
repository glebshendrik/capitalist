//
//  InternationalControl.swift
//  RecurrencePicker
//
//  Created by Xin Hong on 16/4/7.
//  Copyright © 2016年 Teambition. All rights reserved.
//

import Foundation

public enum RecurrencePickerLanguage {
    case english
    case simplifiedChinese
    case traditionalChinese
    case korean
    case japanese
    case russian
    
    static var preferred: RecurrencePickerLanguage {
        if let preferredLocalization = Bundle.preferredLocalizations(from: RecurrencePickerLanguage.all.map { $0.identifier }).first {
            return RecurrencePickerLanguage.all.first(where: { $0.identifier == preferredLocalization }) ?? .english
        }
        return .english
    }
    
    static var all: [RecurrencePickerLanguage] {
        return [.english, .simplifiedChinese, .traditionalChinese, .korean, .japanese, .russian]
    }
    
    internal var identifier: String {
        switch self {
        case .english: return "en"
        case .simplifiedChinese: return "zh-Hans"
        case .traditionalChinese: return "zh-Hant"
        case .korean: return "ko"
        case .japanese: return "ja"
        case .russian: return "ru"
        }
    }
}

internal func LocalizedString(_ key: String, comment: String? = nil) -> String {
    return InternationalControl.shared.localizedString(key, comment: comment)
}

public struct InternationalControl {
    public static var shared = InternationalControl()
    public var language: RecurrencePickerLanguage = RecurrencePickerLanguage.preferred

    internal func localizedString(_ key: String, comment: String? = nil) -> String {
        
        let path = Bundle(for: RecurrencePicker.self).path(forResource: language.identifier, ofType: "lproj") ?? Bundle.main.path(forResource: language.identifier, ofType: "lproj")
        guard let localizationPath = path else {
            return key
        }
        let bundle = Bundle(path: localizationPath)
        return bundle?.localizedString(forKey: key, value: nil, table: "RecurrencePicker") ?? key
    }
}
