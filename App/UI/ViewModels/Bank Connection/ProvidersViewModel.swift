//
//  ProvidersViewModel.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 28/06/2019.
//  Copyright © 2019 Real Tranzit. All rights reserved.
//

import Foundation
import PromiseKit
import SaltEdge

class ProvidersViewModel {
    private let bankConnectionsCoordinator: BankConnectionsCoordinatorProtocol
    
    private var filteredProviderViewModels: [ProviderViewModel] = []
    private var providerViewModels: [ProviderViewModel] = [] {
        didSet {
            filteredProviderViewModels = providerViewModels
        }
    }
    
    public private(set) var loading: Bool = false
    
    var numberOfProviders: Int {
        return filteredProviderViewModels.count
    }
    
    var hasSearchQuery: Bool {
        guard let searchQuery = searchQuery?.trimmed, !searchQuery.isEmpty else {
            return false
        }
        return true
    }
    
    var searchQuery: String? {
        didSet {
            guard hasSearchQuery else {
                filteredProviderViewModels = providerViewModels
                return
            }
            filteredProviderViewModels = providerViewModels.filter { provider in
                return provider.name.lowercased().contains(searchQuery!.lowercased())
            }
        }
    }
    
    var selectedCountryViewModel: CountryViewModel? = nil
    
    var fetchDataFrom: Date? = nil
    
    var selectedProviderViewModel: ProviderViewModel? = nil
    
    init(bankConnectionsCoordinator: BankConnectionsCoordinatorProtocol) {
        self.bankConnectionsCoordinator = bankConnectionsCoordinator
        setupCountry()
    }
    
    func clear() {
        providerViewModels = []
        searchQuery = nil
    }
    
    func set(loading: Bool) {
        self.loading = loading
    }
    
    private func setupCountry() {
        guard let country = Locale.current.regionCode else { return }
        selectedCountryViewModel = CountryViewModel(countryCode: country)
    }
    
    func loadProviders() -> Promise<Void> {
        return  firstly {
                    bankConnectionsCoordinator.loadProviders(country: selectedCountryViewModel?.countryCode)
                }.get { providers in
                    self.providerViewModels = providers.map { ProviderViewModel(provider: $0) }
                }.asVoid()
    }
    
    func providerViewModel(at indexPath: IndexPath) -> ProviderViewModel? {        
        return filteredProviderViewModels[safe: indexPath.row]
    }
        
    func loadConnection(for provider: ProviderViewModel) -> Promise<Connection> {
        return bankConnectionsCoordinator.loadConnection(for: provider.provider)
    }
    
    func createConnectionSession(for providerViewModel: ProviderViewModel) -> Promise<URL> {
        return bankConnectionsCoordinator.createConnectSession(providerCode: providerViewModel.provider.code,
                                                               countryCode: providerViewModel.provider.countryCode,
                                                               fromDate: fetchDataFrom)
    }
    
    func createReconnectSession(for providerViewModel: ProviderViewModel, connection: Connection?) -> Promise<URL> {
        guard let connection = connection else {
            return Promise(error: BankConnectionError.canNotCreateConnection)
        }
        return bankConnectionsCoordinator.createReconnectSession(connection: connection,
                                                                 fromDate: fetchDataFrom)
    }
    
    func createRefreshConnectionSession(for providerViewModel: ProviderViewModel, connection: Connection?) -> Promise<URL> {
        guard let connection = connection else {
            return Promise(error: BankConnectionError.canNotCreateConnection)
        }
        return bankConnectionsCoordinator.createRefreshConnectionSession(connection: connection)
    }
}
