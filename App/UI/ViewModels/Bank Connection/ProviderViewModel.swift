//
//  ProviderViewModel.swift
//  Capitalist
//
//  Created by Alexander Petropavlovsky on 28/06/2019.
//  Copyright © 2019 Real Tranzit. All rights reserved.
//

import Foundation
import SaltEdge

class ProviderViewModel {    
    let provider: SEProvider
    
    var id: String {
        return provider.id
    }
    
    var code: String {
        return provider.code
    }
    
    var name: String {
        return provider.name
    }
    
    var logoURL: URL? {
        return URL(string: provider.logoURL)
    }
    
    var isOAuth: Bool {
        return provider.isOAuth
    }
    
    var maxFetchInterval: Int {
        return provider.maxFetchInterval
    }
    
    var fetchDataFrom: Date {        
        var interval = maxFetchInterval - 1
        if interval < 0 {
            interval = 0
        }
        return Date().adding(.day, value: interval)
    }
    
    var connectURL: URL? = nil
    
    var interactiveCredentials: [ConnectionInteractiveCredentials] {
        guard
            let interactiveFields = provider.interactiveFields
        else {
            return []
        }
        return interactiveFields.map {
            ConnectionInteractiveCredentials(name: $0.name,
                                             value: nil,
                                             displayName: $0.localizedName,
                                             nature: ConnectionInteractiveFieldNature(rawValue: $0.nature),
                                             options: $0.fieldOptions,
                                             position: $0.position,
                                             optional: $0.purpleOptional) }
    }
    
    init(provider: SEProvider) {
        self.provider = provider
    }
}
