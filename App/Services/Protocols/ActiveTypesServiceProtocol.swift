//
//  ActiveTypesServiceProtocol.swift
//  Capitalist
//
//  Created by Alexander Petropavlovsky on 12/10/2019.
//  Copyright © 2019 Real Tranzit. All rights reserved.
//

import Foundation
import PromiseKit

protocol ActiveTypesServiceProtocol {
    func indexActiveTypes() -> Promise<[ActiveType]>
}
