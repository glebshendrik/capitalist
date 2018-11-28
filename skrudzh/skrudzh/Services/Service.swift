//
//  Service.swift
//  skrudzh
//
//  Created by Alexander Petropavlovsky on 28/11/2018.
//  Copyright © 2018 rubikon. All rights reserved.
//

import Foundation
import PromiseKit
import ObjectMapper

class Service {
    fileprivate let apiClient: APIClientProtocol
    
    init(apiClient: APIClientProtocol) {
        self.apiClient = apiClient
    }
    
    func request<T>(_ resource: APIResource) -> Promise<T> where T: Mappable {
        return apiClient.request(resource)
    }
    
    func request<T>(_ resource: APIResource) -> Promise<[T]> where T: Mappable {
        return apiClient.request(resource)
    }
    
    func request<T>(_ resource: APIResource) -> Promise<([T], Int?)> where T: Mappable {
        return apiClient.request(resource)
    }
    
    func request(_ resource: APIResource) -> Promise<Void> {
        return apiClient.request(resource)
    }
    
    func request(_ resource: APIResource) -> Promise<[String : Any]> {
        return apiClient.request(resource)
    }
}
