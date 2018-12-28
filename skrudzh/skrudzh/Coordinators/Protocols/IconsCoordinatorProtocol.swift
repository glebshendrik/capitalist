//
//  IconsCoordinatorProtocol.swift
//  skrudzh
//
//  Created by Alexander Petropavlovsky on 28/12/2018.
//  Copyright © 2018 rubikon. All rights reserved.
//

import Foundation
import PromiseKit

protocol IconsCoordinatorProtocol {
    func index(with category: IconCategory) -> Promise<[Icon]>
}
