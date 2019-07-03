//
//  ProviderViewModel.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 28/06/2019.
//  Copyright © 2019 Real Tranzit. All rights reserved.
//

import Foundation
import SaltEdge

class ProviderViewModel {    
    private let provider: SEProvider
    
    var name: String {
        return provider.name
    }
    
    var logoURL: URL {
        return provider.logoURL
    }
    
    init(provider: SEProvider) {
        self.provider = provider
    }
}
