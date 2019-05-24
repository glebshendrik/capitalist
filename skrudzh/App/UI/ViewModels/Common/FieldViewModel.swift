//
//  FieldViewModel.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 19/12/2018.
//  Copyright © 2018 Real Tranzit. All rights reserved.
//

import UIKit

protocol Field {
    var fieldId: Int { get }
}

extension UITextField : Field {
    var fieldId : Int {
        return hashValue
    }
}

class FieldViewModel {
    let field: Field
    let attributeName: String
    let codingKey: CodingKey
    
    public private(set) var errors: [String] = []
    
    var valid: Bool {
        return errors.isEmpty
    }
    
    init(field: Field, attributeName: String, codingKey: CodingKey) {
        self.field = field
        self.attributeName = attributeName
        self.codingKey = codingKey
    }
    
    func set(errors: [String]) {
        self.errors = errors
    }
    
    func removeErrors() {
        errors = []
    }
}
