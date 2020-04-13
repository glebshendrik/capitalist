//
//  CountriesViewModel.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 10.04.2020.
//  Copyright © 2020 Real Tranzit. All rights reserved.
//

import Foundation
import PromiseKit

class CountriesViewModel {
    private var filteredCountryViewModels: [CountryViewModel] = []
    private var countryViewModels: [CountryViewModel] = [] {
        didSet {
            filteredCountryViewModels = countryViewModels
        }
    }
    
    var numberOfCountries: Int {
        return filteredCountryViewModels.count
    }
    
    var hasSearchQuery: Bool {
        guard let searchQuery = searchQuery?.trimmed, !searchQuery.isEmpty else {
            return false
        }
        return true
    }
    
    var searchQuery: String? {
        didSet {
            guard hasSearchQuery, let searchQuery = searchQuery else {
                filteredCountryViewModels = countryViewModels
                return
            }
            filteredCountryViewModels = countryViewModels.filter { country in
                return country.name.lowercased().contains(searchQuery.lowercased())
            }
        }
    }
        
    func loadCountries() -> Promise<Void> {
        return  firstly {
                    countries()
                }.done {
                    self.countryViewModels = $0
                }
    }
    
    private func countries() -> Promise<[CountryViewModel]> {
        let bgq = DispatchQueue.global(qos: .background)
        return  firstly {
                    Promise.value(NSLocale.isoCountryCodes)
                }.map(on: bgq) { codes in
                    codes
                        .map { CountryViewModel(countryCode: $0) }
                        .sorted(by: { $0.name < $1.name })
                }
    }
    
    func countryViewModel(at indexPath: IndexPath) -> CountryViewModel? {
        return filteredCountryViewModels[safe: indexPath.row]
    }
}
