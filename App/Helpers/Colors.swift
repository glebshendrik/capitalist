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
    case black1 = "black 1"
    case black2 = "black 2"
    case black3 = "black 3"
    case blue1 = "blue 1"
    case gray1 = "gray 1"
    case gray2 = "gray 2"
    case green1 = "green 1"
    case green2 = "green 2"
    case green24 = "green 0.24"
    case green64 = "green 0.64"
    case red1 = "red 1"
    case red2 = "red 2"
    case white4 = "white 0.04"
    case white12 = "white 0.12"
    case white40 = "white 0.4"
    case white64 = "white 0.64"
    case white100 = "white 1.0"
    case brandExpense = "brand expense"
    case brandRisk = "brand risk"
    case brandSafe = "brand safe"
    case purple24 = "purple 0.24"
    case purple64 = "purple 0.64"
    case yellow1 = "yellow 1"
}

extension UIColor {
    static func by(_ asset: ColorAsset) -> UIColor {
        return UIColor(named: asset.rawValue) ?? .purple
    }
}
