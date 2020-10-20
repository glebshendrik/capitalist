//
//  SaltEdgeManager.swift
//  Capitalist
//
//  Created by Alexander Petropavlovsky on 22/06/2019.
//  Copyright © 2019 Real Tranzit. All rights reserved.
//

import Foundation
import PromiseKit
import SaltEdge
import SwiftyBeaver

class SaltEdgeManager : SaltEdgeManagerProtocol {
    static let applicationURLString: String = "saltedge-api-three-baskets://home.local"
        
    var providersCache: [String: [SEProvider]] = [:]
    var createConnectSessionCache: [String: [String: SEConnectSessionResponse]] = [:]
//    var refreshConnectSessionCache: [String: SEConnectSessionResponse] = [:]
    var reconnectConnectSessionCache: [String: SEConnectSessionResponse] = [:]
    private var customerSecret: String? = nil
    
    var includeFakeProviders: Bool {
        return UIApplication.shared.inferredEnvironment != .appStore
    }
    
    func set(appId: String, appSecret: String) {
        SERequestManager.shared.set(appId: appId, appSecret: appSecret)
    }
    
    func set(customerSecret: String) {
        self.customerSecret = customerSecret
        SERequestManager.shared.set(customerSecret: customerSecret)
    }
    
    func createCustomer(identifier: String) -> Promise<String> {
        let params = SECustomerParams(identifier: identifier)
        return Promise { seal in
            SERequestManager.shared.createCustomer(with: params) { response in
                switch response {
                case .success(let value):
                    seal.fulfill(value.data.secret)
//                    SERequestManager.shared.set(customerSecret: value.data.secret)
                case .failure(let error):
                    SwiftyBeaver.error(error)
                    seal.reject(error)
                }
            }
        }
        
    }
    
    func loadProviders(country: String?) -> Promise<[SEProvider]> {
        return  firstly {
                    when(fulfilled: loadSaltEdgeProviders(country),
                                    loadSaltEdgeProviders("XO"),
                                    loadSaltEdgeProviders("XF"))
                }.map { countryProviders, electronicProviders, fakeProviders in
                                                            
                    var providers = country == nil ? countryProviders : (countryProviders + electronicProviders)
                    if self.includeFakeProviders {
                        providers = providers + fakeProviders
                    }
                    return self.sortProvidersByCountry(providers,
                                                       startingWith: country)
                }
    }
    
    private func loadSaltEdgeProviders(_ country: String?) -> Promise<[SEProvider]> {
        if let country = country,
           let providers = providersCache[country] {
            return Promise.value(providers)
        }
        return
            firstly {
                when(fulfilled: loadSaltEdgeProviders(country, mode: "web"),
                     loadSaltEdgeProviders(country, mode: "oauth"))
            }.map { web, oauth in
                let providers = web + oauth
                if let country = country {
                    self.providersCache[country] = providers
                }
                return providers
            }
    }
    
    private func loadSaltEdgeProviders(_ country: String?, mode: String) -> Promise<[SEProvider]> {
        return Promise { seal in
            let params = SEProviderParams(countryCode: country,
                                          mode: mode,
                                          includeFakeProviders: includeFakeProviders)
            SERequestManager.shared.getAllProviders(with: params) { response in
                switch response {
                case .success(let value):
                    seal.fulfill(value.data)
                case .failure(let error):
                    SwiftyBeaver.error(error)
                    seal.reject(error)
                }
            }
        }
    }
    
    func createCreatingConnectionSession(providerCode: String,
                                         countryCode: String,
                                         fromDate: Date,
                                         languageCode: String) -> Promise<ConnectionSession> {
        if  let customerSecret = self.customerSecret,
            let cachedSessionResponse = createConnectSessionCache[customerSecret]?[providerCode],
            let url = URL(string: cachedSessionResponse.connectUrl),
            cachedSessionResponse.expiresAt.isInFuture {

            return Promise.value(ConnectionSession(url: url,
                                                   type: .creating,
                                                   expiresAt: cachedSessionResponse.expiresAt))
        }
        let connectSessionsParams = SEConnectSessionsParams(allowedCountries: [countryCode],
                                                            attempt: SEAttempt(automaticFetch: true,
                                                                               dailyRefresh: true,
                                                                               locale: languageCode,
                                                                               returnTo: "https://capitalistapp.net"),
                                                            providerCode: providerCode,
                                                            dailyRefresh: true,
                                                            fromDate: fromDate,
                                                            javascriptCallbackType: "iframe",
                                                            includeFakeProviders: includeFakeProviders,
                                                            theme: "dark",
                                                            consent: SEConsent(scopes: ["account_details",
                                                                                        "transactions_details"],
                                                                               fromDate: fromDate))
        
        return
            Promise { seal in
                SERequestManager.shared.createConnectSession(params: connectSessionsParams) { response in
                    switch response {
                        case .success(let value):
                            guard
                                let url = URL(string: value.data.connectUrl)
                            else {
                                seal.reject(SaltEdgeError.cannotCreateConnectSession)
                                return
                            }
                            if let customerSecret = self.customerSecret {
                                if self.createConnectSessionCache[customerSecret] == nil {
                                    self.createConnectSessionCache[customerSecret] = [:]
                                }
                                self.createConnectSessionCache[customerSecret]?[providerCode] = value.data
                            }
                            
                            seal.fulfill(ConnectionSession(url: url,
                                                           type: .creating,
                                                           expiresAt: value.data.expiresAt))
                        case .failure(let error):
                            SwiftyBeaver.error(error)
                            seal.reject(error)
                    }
                }
            }
    }
    
    func createRefreshingConnectionSession(connectionSecret: String,
                                           fromDate: Date,
                                           languageCode: String) -> Promise<ConnectionSession> {
//        if  let cachedSessionResponse = refreshConnectSessionCache[connectionSecret],
//            let url = URL(string: cachedSessionResponse.connectUrl),
//            cachedSessionResponse.expiresAt.isInFuture {
//
//            return Promise.value(url)
//        }
        
        let refreshSessionsParams = SERefreshSessionsParams(attempt: SEAttempt(automaticFetch: true,
                                                                               dailyRefresh: true,
                                                                               locale: languageCode,
                                                                               returnTo: "https://capitalistapp.net",
                                                                               fromDate: fromDate),
                                                            dailyRefresh: true,
                                                            fromDate: fromDate,
                                                            javascriptCallbackType: "iframe",
                                                            includeFakeProviders: includeFakeProviders,
                                                            theme: "dark")
        
        return
            Promise { seal in
                SERequestManager.shared.refreshSession(with: connectionSecret, params: refreshSessionsParams) { response in
                    switch response {
                        case .success(let value):
                            guard let url = URL(string: value.data.connectUrl) else {
                                seal.reject(SaltEdgeError.cannotCreateConnectSession)
                                return
                            }
                            //                    self.refreshConnectSessionCache[connectionSecret] = value.data
                            seal.fulfill(ConnectionSession(url: url,
                                                           type: .refreshing,
                                                           expiresAt: value.data.expiresAt))
                        case .failure(let error):
                            SwiftyBeaver.error(error)
                            seal.reject(error)
                    }
                }
            }
    }
    
    func createReconnectingConnectionSession(connectionSecret: String,
                                             fromDate: Date,
                                             languageCode: String) -> Promise<ConnectionSession> {
        if  let cachedSessionResponse = reconnectConnectSessionCache[connectionSecret],
            let url = URL(string: cachedSessionResponse.connectUrl),
            cachedSessionResponse.expiresAt.isInFuture {

            return Promise.value(ConnectionSession(url: url,
                                                   type: .reconnecting,
                                                   expiresAt: cachedSessionResponse.expiresAt))
        }
        
        let reconnectSessionsParams = SEReconnectSessionsParams(attempt: SEAttempt(automaticFetch: true,
                                                                                   dailyRefresh: true,
                                                                                   locale: languageCode,
                                                                                   returnTo: "https://capitalistapp.net"),
                                                                dailyRefresh: true,
                                                                javascriptCallbackType: "iframe",
                                                                includeFakeProviders: includeFakeProviders,
                                                                theme: "dark",
                                                                overrideCredentialsStrategy: "override",
                                                                consent: SEConsent(scopes: ["account_details",
                                                                                            "transactions_details"],
                                                                                   fromDate: fromDate))
        
        return
            Promise { seal in
                SERequestManager.shared.reconnectSession(with: connectionSecret, params: reconnectSessionsParams) { response in
                    switch response {
                        case .success(let value):
                            guard let url = URL(string: value.data.connectUrl) else {
                                seal.reject(SaltEdgeError.cannotCreateConnectSession)
                                return
                            }
                            self.reconnectConnectSessionCache[connectionSecret] = value.data
                            seal.fulfill(ConnectionSession(url: url,
                                                           type: .reconnecting,
                                                           expiresAt: value.data.expiresAt))
                        case .failure(let error):
                            SwiftyBeaver.error(error)
                            seal.reject(error)
                    }
                }
            }
    }
    
    func getConnection(secret: String) -> Promise<SEConnection> {
        return
            Promise { seal in
                SERequestManager.shared.getConnection(with: secret) { response in
                    switch response {
                        case .success(let value):
                            seal.fulfill(value.data)
                        case .failure(let error):
                            SwiftyBeaver.error(error)
                            seal.reject(error)
                    }
                }
            }
    }
    
    func removeConnection(secret: String) -> Promise<Void> {
        return
            Promise { seal in
                SERequestManager.shared.removeConnection(with: secret) { response in
                    switch response {
                        case .success(let value):
                            guard value.data.removed else {
                                seal.reject(SaltEdgeError.connectionNotRemoved)
                                return
                            }
                            seal.fulfill(())
                        case .failure(let error):
                            SwiftyBeaver.error(error)
                            seal.reject(error)
                    }
                }
            }
    }
        
    func getProvider(code: String) -> Promise<SEProvider> {
        return
            Promise { seal in
                SERequestManager.shared.getProvider(code: code) { response in
                    switch response {
                        case .success(let value):
                            seal.fulfill(value.data)
                        case .failure(let error):
                            SwiftyBeaver.error(error)
                            seal.reject(error)
                    }
                }
            }        
    }
    
    func loadAccounts(for connectionSecret: String) -> Promise<[SEAccount]> {
        return Promise { seal in
            SERequestManager.shared.getAllAccounts(for: connectionSecret, params: nil) { response in
                switch response {
                case .success(let value):
                    seal.fulfill(value.data)
                case .failure(let error):
                    SwiftyBeaver.error(error)
                    seal.reject(error)
                }
            }
            
        }
        
    }
    
    private func sortProvidersByCountry(_ providers: [SEProvider], startingWith topCountry: String? = nil) -> [SEProvider] {
        return providers.sorted(by: {
            if $0.countryCode != $1.countryCode {
                if let topCountry = topCountry {
                    if $1.countryCode == topCountry {
                        return false
                    }
                    if $0.countryCode == topCountry {
                        return true
                    }
                }
                return $0.countryCode < $1.countryCode
            } else {
                return $0.name < $1.name
            }
        })
    }
}
