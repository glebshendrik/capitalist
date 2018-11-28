//
//  DevicesServiceProtocol.swift
//  skrudzh
//
//  Created by Alexander Petropavlovsky on 28/11/2018.
//  Copyright © 2018 rubikon. All rights reserved.
//
import PromiseKit

protocol DevicesServiceProtocol {
    func register(deviceToken: Data, userId: Int) -> Promise<Void>
}
