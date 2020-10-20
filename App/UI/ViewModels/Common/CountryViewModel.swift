//
//  CountryViewModel.swift
//  Capitalist
//
//  Created by Alexander Petropavlovsky on 10.04.2020.
//  Copyright © 2020 Real Tranzit. All rights reserved.
//

import Foundation

class CountryViewModel {
    public private(set) var countryCode: String

    var name: String
        
    init(countryCode: String) {
        self.countryCode = countryCode
        let id = NSLocale.localeIdentifier(fromComponents: [NSLocale.Key.countryCode.rawValue: countryCode])
        name = NSLocale.autoupdatingCurrent.localizedString(forIdentifier: id) ?? countryCode
    }
}
