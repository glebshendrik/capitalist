//
//  Colors.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 05/07/2019.
//  Copyright © 2019 Real Tranzit. All rights reserved.
//

import UIKit
import SwifterSwift

enum ColorAsset : String {
    case blue6A92FA = "blue 6A92FA"
    case blue6B93FB = "blue 6B93FB"
    case blue5B86F7 = "blue 5B86F7"
    case blue5B7BD1 = "blue 5B7BD1"
    
    case dark333D5B = "dark 333D5B"
    case dark374262 = "dark 374262"
    case dark1F263E = "dark 1F263E"
    case dark374467 = "dark 374467"
    case dark2A314B = "dark 2A314B"
    case dark404B6F = "dark 404B6F"
    case dark283455 = "dark 283455"
    
    case delimeter333D5B = "delimeter 333D5B"
    case delimeterAFC1FF = "delimeter AFC1FF"
    case delimeter2F3854 = "delimeter 2F3854"
    
    case gray7984A4 = "gray 7984A4"
    
    case text435585 = "text 435585"
    case text8792B2 = "text 8792B2"
    case text9EAACC = "text 9EAACC"    
    case text606B8A = "text 606B8A"
    case textAFC1FF = "text AFC1FF"
    case textFFFFFF = "text FFFFFF"
    
    case redE5487C = "red E5487C"
    case redFE3745 = "red FE3745"
    case green68E79B = "green 68E79B"
    case green295C5B = "green 295C5B"
    
    case joy4828D1 = "joy 4828D1"
    case joyC2C9E2 = "joy C2C9E2"
    case safe6EEC99 = "safe 6EEC99"
    case safeD7F6E6 = "safe D7F6E6"
    case riskC765F0 = "risk C765F0"
    case riskF2D6FE = "risk F2D6FE"    
}

extension UIColor {
    static func by(_ asset: ColorAsset) -> UIColor {
        return UIColor(named: asset.rawValue) ?? .purple
    }
}
