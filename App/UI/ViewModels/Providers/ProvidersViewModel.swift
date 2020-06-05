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
//                    self.creatCSV(providers)
                    self.providerViewModels = providers.map { ProviderViewModel(provider: $0) }
                }.asVoid()
    }
    
    func creatCSV(_ providers: [SEProvider]) -> Void {
        let fileName = "providers.csv"
        let path = NSURL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(fileName)
        var csvText = ""
        
        providers.forEach { csvText.append("\($0.code)|\($0.name)|\($0.mode)|\($0.status)|\($0.customerNotifiedOnSignIn)|\($0.logoURL)\n") }
        
        do {
            try csvText.write(to: path!, atomically: true, encoding: String.Encoding.utf8)
        } catch {
            print("Failed to create file")
            print("\(error)")
        }
        print(csvText)
    }
    
    func providerViewModel(at indexPath: IndexPath) -> ProviderViewModel? {        
        return filteredProviderViewModels[safe: indexPath.row]
    }
        
    func loadConnection(for provider: ProviderViewModel) -> Promise<Connection> {
        return  firstly {
                    bankConnectionsCoordinator.loadConnection(for: provider.id)
                }.then { connection -> Promise<Connection> in
                    if connection.id == nil {
                        return self.bankConnectionsCoordinator.saveConnection(connection: connection, provider: provider.provider)
                    }
                    return Promise.value(connection)
                }
    }
    
    func createBankConnectionSession(for providerViewModel: ProviderViewModel) -> Promise<ProviderViewModel> {
        let languageCode = String(Locale.preferredLanguages[0].prefix(2)).lowercased()
        return  firstly {
                    bankConnectionsCoordinator.createSaltEdgeConnectSession(provider: providerViewModel.provider,
                                                                            languageCode: languageCode)
                }.then { connectURL -> Promise<ProviderViewModel> in
                    providerViewModel.connectURL = connectURL
                    return Promise.value(providerViewModel)
                }
    }
}
