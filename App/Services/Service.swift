//
//  Service.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 28/11/2018.
//  Copyright © 2018 Real Tranzit. All rights reserved.
//

import Foundation
import PromiseKit

class Service {
    private let apiClient: APIClientProtocol
    
    init(apiClient: APIClientProtocol) {
        self.apiClient = apiClient
    }
    
    func request<T>(_ resource: APIRoute) -> Promise<T> where T: Decodable {
        return apiClient.request(resource)
    }
    
    func requestCollection<T>(_ resource: APIRoute) -> Promise<[T]> where T: Decodable {
        return apiClient.requestCollection(resource)
    }
    
    func request<T>(_ resource: APIRoute) -> Promise<([T], Int?)> where T: Decodable {
        return apiClient.request(resource)
    }
    
    func request(_ resource: APIRoute) -> Promise<Void> {
        return apiClient.request(resource)
    }
    
    func request(_ resource: APIRoute) -> Promise<[String : Any]> {
        return apiClient.request(resource)
    }
}
