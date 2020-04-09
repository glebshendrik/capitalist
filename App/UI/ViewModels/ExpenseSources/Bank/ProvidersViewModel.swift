//
//  ProvidersViewModel.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 28/06/2019.
//  Copyright © 2019 Real Tranzit. All rights reserved.
//

import Foundation
import PromiseKit

class ProvidersViewModel {
    private let bankConnectionsCoordinator: BankConnectionsCoordinatorProtocol
    
    private var filteredProviderViewModels: [ProviderViewModel] = []
    private var providerViewModels: [ProviderViewModel] = [] {
        didSet {
            filteredProviderViewModels = providerViewModels
        }
    }
    
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
    
    init(bankConnectionsCoordinator: BankConnectionsCoordinatorProtocol) {
        self.bankConnectionsCoordinator = bankConnectionsCoordinator
    }
    
    func loadProviders() -> Promise<Void> {
        return  firstly {
                    bankConnectionsCoordinator.loadSaltEdgeProviders(topCountry: Locale.preferredLanguageCode.uppercased())
                }.get { providers in
                    self.providerViewModels = providers.map { ProviderViewModel(provider: $0) }
                }.asVoid()
    }
    
    func providerViewModel(at indexPath: IndexPath) -> ProviderViewModel? {        
        return filteredProviderViewModels[safe: indexPath.row]
    }
    
    func loadProviderConnection(for providerId: String) -> Promise<ProviderConnection> {
        return bankConnectionsCoordinator.loadProviderConnection(for: providerId)
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
