//
//  LayoutElementOnboarding.swift
//  Capitalist
//
//  Created by Gleb Shendrik on 18.03.2021.
//  Copyright © 2021 Real Tranzit. All rights reserved.
//

import UIKit
import SnapKit

class LayoutElementOnboarding: UIView {

    override func draw(_ rect: CGRect) {
        guard let image = self.subviews.first(where: {$0 is UIImageView}) else {return}
        guard let label = self.subviews.first(where: {$0 is UILabel}) else {return}
        
        let isSe = frame.height < 667
        let imageTopMargin = isSe ? frame.height * 0.12 : frame.height * 0.14
        let labelTopMargin = isSe ? 10 : frame.height * 0.75
        
        image.snp.makeConstraints { (make) in
            make.top.equalTo(safeAreaLayoutGuide).offset(imageTopMargin)
        }

        label.snp.makeConstraints { (make) in
            make.top.equalTo(image.snp.bottom).offset(labelTopMargin)
        }
    }
}
