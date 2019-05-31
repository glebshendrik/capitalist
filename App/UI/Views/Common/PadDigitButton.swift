//
//  PadButton.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 29/05/2019.
//  Copyright © 2019 Real Tranzit. All rights reserved.
//

import UIKit

class PadDigitButton : UIButton {
    var digit: Int? {
        guard let title = titleForNormal,
              let int = Int(title),
              case 0...9 = int else { return nil }
        return int
    }
}
