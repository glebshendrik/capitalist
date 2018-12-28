//
//  APIResourceQueryParameters.swift
//  skrudzh
//
//  Created by Alexander Petropavlovsky on 28/11/2018.
//  Copyright © 2018 rubikon. All rights reserved.
//

import Foundation

struct APIResourceQueryParameters {
    static func queryParameters(for resource: APIResource) -> [String : String] {
        let params = [String : String]()
        switch resource {
        case .indexIcons(let category):
            return ["category" : category.rawValue]
        default:
            break
        }
        return params
    }
}
