//
//  ActiveTypesService.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 12/10/2019.
//  Copyright © 2019 Real Tranzit. All rights reserved.
//

import Foundation
import PromiseKit

class ActiveTypesService : Service, ActiveTypesServiceProtocol {
    func indexActiveTypes() -> Promise<[ActiveType]> {
        return requestCollection(APIRoute.indexActiveTypes)
    }
}
