//
//  IconViewModel.swift
//  skrudzh
//
//  Created by Alexander Petropavlovsky on 28/12/2018.
//  Copyright © 2018 rubikon. All rights reserved.
//

import Foundation

class IconViewModel {
    public private(set) var icon: Icon
    
    var url: URL {
        return icon.url
    }
    
    var category: IconCategory {
        return icon.category
    }
    
    init(icon: Icon) {
        self.icon = icon
    }
}