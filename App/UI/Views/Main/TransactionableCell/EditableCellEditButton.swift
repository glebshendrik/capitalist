//
//  EditableCellEditButton.swift
//  Capitalist
//
//  Created by Alexander Petropavlovsky on 20/10/2019.
//  Copyright © 2019 Real Tranzit. All rights reserved.
//

import UIKit

class EditableCellEditButton : EditableCellButton {
    override func setup() {
        super.setup()
        setImage(UIImage(named: "pen-icon"), for: .normal)
    }
}
