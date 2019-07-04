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
    
    var searchQuery: String? {
        didSet {
            guard let searchQuery = searchQuery?.trimmed, !searchQuery.isEmpty else {
                filteredProviderViewModels = providerViewModels
                return
            }
            filteredProviderViewModels = providerViewModels.filter { provider in
                return provider.name.lowercased().contains(searchQuery.lowercased())
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
        return filteredProviderViewModels.item(at: indexPath.row)
    }
}
