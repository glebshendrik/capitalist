//
//  IconsViewModel.swift
//  Capitalist
//
//  Created by Alexander Petropavlovsky on 28/12/2018.
//  Copyright © 2018 Real Tranzit. All rights reserved.
//

import Foundation
import PromiseKit

enum IconsError: Error {
    case categoryIsNotSpecified
}

class IconsViewModel {
    private let iconsCoordinator: IconsCoordinatorProtocol
    
    private var iconViewModels: [IconViewModel] = []
    
    var iconCategory: IconCategory? = nil
    
    var numberOfIcons: Int {
        return iconViewModels.count
    }
    
    init(iconsCoordinator: IconsCoordinatorProtocol) {
        self.iconsCoordinator = iconsCoordinator
    }
    
    func loadIcons() -> Promise<Void> {
        guard let category = iconCategory else {
            return Promise(error: IconsError.categoryIsNotSpecified)
        }
        return  firstly {
                    iconsCoordinator.index(with: category)
                }.done { icons in
                    self.iconViewModels = icons.map { IconViewModel(icon: $0) }
                }
    }
    
    func iconViewModel(at indexPath: IndexPath) -> IconViewModel? {        
        return iconViewModels[safe: indexPath.row]
    }
}
