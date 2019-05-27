//
//  IconsCoordinator.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 28/12/2018.
//  Copyright © 2018 Real Tranzit. All rights reserved.
//

import Foundation
import PromiseKit

class IconsCoordinator : IconsCoordinatorProtocol {
    private let iconsService: IconsServiceProtocol
    
    init(iconsService: IconsServiceProtocol) {
        self.iconsService = iconsService
    }
    
    func index(with category: IconCategory) -> Promise<[Icon]> {
        return iconsService.index(with: category)
    }
}
