//
//  APIClientProtocol.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 28/11/2018.
//  Copyright © 2018 Real Tranzit. All rights reserved.
//

import Foundation
import Alamofire
import PromiseKit

protocol APIClientProtocol {
    func request<T>(_ resource: APIResource) -> Promise<T> where T : Decodable
    func requestCollection<T>(_ resource: APIResource) -> Promise<[T]> where T : Decodable
    func request<T>(_ resource: APIResource) -> Promise<([T], Int?)> where T : Decodable
    func request(_ resource: APIResource) -> Promise<Void>
    func request(_ resource: APIResource) -> Promise<[String : Any]>
}
