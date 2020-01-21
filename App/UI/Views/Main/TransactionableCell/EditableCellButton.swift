//
//  EditableCellButton.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 20/10/2019.
//  Copyright © 2019 Real Tranzit. All rights reserved.
//

import UIKit
import SnapKit

class EditableCellButton : UIButton {
    private var didTap: (() -> Void)? = nil
    private var didSetupConstraints = false
        
    convenience init() {
        self.init(frame: CGRect.zero)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    func didTap(_ didTap: @escaping () -> Void) {
        self.didTap = didTap
    }
    
    override func updateConstraints() {
        if !didSetupConstraints {
            setupConstraints()
            didSetupConstraints = true
        }
        super.updateConstraints()
    }
    
    func setup() {
        translatesAutoresizingMaskIntoConstraints = false
        
        backgroundColor = UIColor.by(.black1)
        cornerRadius = 8
        tintColor = UIColor.by(.white100)
        addTarget(self, action: #selector(didTapButton(_:)), for: .touchUpInside)
    }
    
    func setupConstraints() {
        self.snp.makeConstraints { make in
            make.width.height.equalTo(16)
        }
    }
    
    @objc func didTapButton(_ sender: UIButton) {
        didTap?()
    }
}
