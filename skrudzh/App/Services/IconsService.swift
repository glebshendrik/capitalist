//
//  IconsService.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 28/12/2018.
//  Copyright © 2018 Real Tranzit. All rights reserved.
//

import Foundation
import PromiseKit

class IconsService : Service, IconsServiceProtocol {
    func index(with category: IconCategory) -> Promise<[Icon]> {
        return requestCollection(APIResource.indexIcons(category: category))
    }
}
