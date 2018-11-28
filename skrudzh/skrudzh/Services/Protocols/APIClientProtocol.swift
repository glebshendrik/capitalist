//
//  APIClientProtocol.swift
//  skrudzh
//
//  Created by Alexander Petropavlovsky on 28/11/2018.
//  Copyright © 2018 rubikon. All rights reserved.
//

import Foundation
import Alamofire
import PromiseKit

protocol APIClientProtocol {
    func request<T>(_ resource: APIResource) -> Promise<T> where T : Codable
    func request<T>(_ resource: APIResource) -> Promise<[T]> where T : Codable
    func request<T>(_ resource: APIResource) -> Promise<([T], Int?)> where T : Codable
    func request(_ resource: APIResource) -> Promise<Void>
    func request(_ resource: APIResource) -> Promise<[String : Any]>
}
