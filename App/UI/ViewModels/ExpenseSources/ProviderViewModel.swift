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
    
    var logoURL: URL {
        return provider.logoURL
    }
    
    var connectURL: URL? = nil
    
    init(provider: SEProvider) {
        self.provider = provider
    }
}
