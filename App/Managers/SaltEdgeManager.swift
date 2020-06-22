//
//  SaltEdgeManager.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 22/06/2019.
//  Copyright © 2019 Real Tranzit. All rights reserved.
//

import Foundation
import PromiseKit
import SaltEdge

class SaltEdgeManager : SaltEdgeManagerProtocol {
    static let applicationURLString: String = "saltedge-api-three-baskets://home.local"
        
    var providersCache: [String: [SEProvider]] = [:]
    var createConnectSessionCache: [String: [String: SEConnectSessionResponse]] = [:]
    var refreshConnectSessionCache: [String: SEConnectSessionResponse] = [:]
    var reconnectConnectSessionCache: [String: SEConnectSessionResponse] = [:]
    private var customerSecret: String? = nil
    
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
                    seal.reject(error)
                }
            }
        }
        
    }
    
    func loadProviders(country: String?) -> Promise<[SEProvider]> {
        return  firstly {
                    when(fulfilled: loadSaltEdgeProviders(country), loadSaltEdgeProviders("XO"))
                }.map { countryProviders, electronicProviders in
                    let providers = country == nil ? countryProviders : (countryProviders + electronicProviders)
                    return self.sortProvidersByCountry(providers,
                                                       startingWith: country)
                }
    }
    
    private func loadSaltEdgeProviders(_ country: String?) -> Promise<[SEProvider]> {
        if let country = country, let providers = providersCache[country] {
            return Promise.value(providers)
        }
        return Promise { seal in
            let params = SEProviderParams(countryCode: country,
                                          mode: "web",
                                          includeFakeProviders: false)
            SERequestManager.shared.getAllProviders(with: params) { [weak self] response in
                switch response {
                case .success(let value):
                    guard let self = self else {
                        seal.reject(SaltEdgeError.cannotLoadProviders)
                        return
                    }
                    if let country = country {
                        self.providersCache[country] = value.data
                    }
                    
                    seal.fulfill(value.data)
                case .failure(let error):
                    seal.reject(error)
                }
            }
        }
    }
    
    func createConnectSession(providerCode: String, countryCode: String, languageCode: String) -> Promise<URL> {
        if  let customerSecret = self.customerSecret,
            let cachedSessionResponse = createConnectSessionCache[customerSecret]?[providerCode],
            let url = URL(string: cachedSessionResponse.connectUrl),
            cachedSessionResponse.expiresAt.isInFuture {
            
            return Promise.value(url)
        }
        let connectSessionsParams = SEConnectSessionsParams(allowedCountries: [countryCode],
                                                            attempt: SEAttempt(automaticFetch: true,
                                                                               dailyRefresh: true,
                                                                               locale: languageCode,
                                                                               returnTo: "http://tempio.app"),
                                                            providerCode: providerCode,
                                                            dailyRefresh: true,
                                                            fromDate: Date(),
                                                            javascriptCallbackType: "iframe",
                                                            includeFakeProviders: true,
                                                            theme: "dark",
                                                            consent: SEConsent(scopes: ["account_details", "transactions_details"],
                                                                               fromDate: Date()))
        
        return Promise { seal in
            SERequestManager.shared.createConnectSession(params: connectSessionsParams) { response in
                switch response {
                case .success(let value):
                    guard let url = URL(string: value.data.connectUrl) else {
                        seal.reject(SaltEdgeError.cannotCreateConnectSession)
                        return
                    }
                    if let customerSecret = self.customerSecret {
                        if self.createConnectSessionCache[customerSecret] == nil {
                            self.createConnectSessionCache[customerSecret] = [:]
                        }
                        self.createConnectSessionCache[customerSecret]?[providerCode] = value.data
                    }
                    
                    seal.fulfill(url)
                case .failure(let error):
                    seal.reject(error)
                }
            }
        }
    }
    
    func createRefreshConnectionSession(connectionSecret: String, languageCode: String) -> Promise<URL> {
        if  let cachedSessionResponse = refreshConnectSessionCache[connectionSecret],
            let url = URL(string: cachedSessionResponse.connectUrl),
            cachedSessionResponse.expiresAt.isInFuture {
            
            return Promise.value(url)
        }
        
        let refreshSessionsParams = SERefreshSessionsParams(attempt: SEAttempt(automaticFetch: true,
                                                                               dailyRefresh: true,
                                                                               locale: languageCode,
                                                                               returnTo: "http://tempio.app"),
                                                            dailyRefresh: true,
                                                            javascriptCallbackType: "iframe",
                                                            theme: "dark")
        
        return Promise { seal in
            SERequestManager.shared.refreshSession(with: connectionSecret, params: refreshSessionsParams) { response in
                switch response {
                case .success(let value):
                    guard let url = URL(string: value.data.connectUrl) else {
                        seal.reject(SaltEdgeError.cannotCreateConnectSession)
                        return
                    }
                    self.refreshConnectSessionCache[connectionSecret] = value.data
                    seal.fulfill(url)
                case .failure(let error):
                    seal.reject(error)
                }
            }
        }
    }
    
    func createReconnectSession(connectionSecret: String, languageCode: String) -> Promise<URL> {
        if  let cachedSessionResponse = reconnectConnectSessionCache[connectionSecret],
            let url = URL(string: cachedSessionResponse.connectUrl),
            cachedSessionResponse.expiresAt.isInFuture {
            
            return Promise.value(url)
        }
        
        let reconnectSessionsParams = SEReconnectSessionsParams(attempt: SEAttempt(automaticFetch: true,
                                                                                   dailyRefresh: true,
                                                                                   locale: languageCode,
                                                                                   returnTo: "http://tempio.app"),
                                                                dailyRefresh: true,
                                                                javascriptCallbackType: "iframe",
                                                                theme: "dark",
                                                                overrideCredentialsStrategy: "override",
                                                                consent: SEConsent(scopes: ["account_details", "transactions_details"],
                                                                                   fromDate: Date()))
        
        return Promise { seal in
            SERequestManager.shared.reconnectSession(with: connectionSecret, params: reconnectSessionsParams) { response in
                switch response {
                case .success(let value):
                    guard let url = URL(string: value.data.connectUrl) else {
                        seal.reject(SaltEdgeError.cannotCreateConnectSession)
                        return
                    }
                    self.reconnectConnectSessionCache[connectionSecret] = value.data
                    seal.fulfill(url)
                case .failure(let error):
                    seal.reject(error)
                }
            }
        }
    }
    
    func getConnection(secret: String) -> Promise<SEConnection> {
        return Promise { seal in
            SERequestManager.shared.getConnection(with: secret) { response in
                switch response {
                case .success(let value):
                    seal.fulfill(value.data)
                case .failure(let error):
                    seal.reject(error)
                }
            }
        }
    }
    
    func removeConnection(secret: String) -> Promise<Void> {
        return Promise { seal in
            SERequestManager.shared.removeConnection(with: secret) { response in
                switch response {
                case .success(let value):
                    guard value.data.removed else {
                        seal.reject(SaltEdgeError.connectionNotRemoved)
                        return
                    }
                    seal.fulfill(())
                case .failure(let error):
                    seal.reject(error)
                }
            }
        }
    }
    
    func refreshConnection(secret: String, fetchingDelegate: SEConnectionFetchingDelegate) -> Promise<Void> {
        let params = SEConnectionRefreshParams(attempt: SEAttempt(returnTo: "AppDelegate.applicationURLString"))
        
        return Promise { seal in
            SERequestManager.shared.refreshConnection(
                with: secret,
                params: params,
                fetchingDelegate: fetchingDelegate
            ) { response in
                switch response {
                case .success:
                    seal.fulfill(())
                case .failure(let error):
                    seal.reject(error)
                }
            }
        }
        
    }
    
    func getProvider(code: String) -> Promise<SEProvider> {
        return Promise { seal in
            SERequestManager.shared.getProvider(code: code) { response in
                switch response {
                case .success(let value):
                    seal.fulfill(value.data)
                case .failure(let error):
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

//class ReconnectSessionsParams: SEReconnectSessionsParams {
//
//    public let overrideCredentialsStrategy: String?
//    public let theme: String?
//
//    public init(excludeAccounts: [Int]? = nil,
//                attempt: SEAttempt? = nil,
//                customFields: String? = nil,
//                dailyRefresh: Bool? = nil,
//                fromDate: Date? = nil,
//                toDate: Date? = nil,
//                returnConnectionId: Bool? = nil,
//                providerModes: [String]? = nil,
//                categorize: Bool? = nil,
//                javascriptCallbackType: String? = nil,
//                includeFakeProviders: Bool? = nil,
//                lostConnectionNotify: Bool? = nil,
//                showConsentConfirmation: Bool? = nil,
//                credentialsStrategy: String? = nil,
//                overrideCredentialsStrategy: String? = "override",
//                theme: String? = "dark",
//                consent: SEConsent) {
//        self.overrideCredentialsStrategy = overrideCredentialsStrategy
//        self.theme = theme
//
//        super.init(excludeAccounts: excludeAccounts,
//                   attempt: attempt,
//                   customFields: customFields,
//                   dailyRefresh: dailyRefresh,
//                   fromDate: fromDate,
//                   toDate: toDate,
//                   returnConnectionId: returnConnectionId,
//                   providerModes: providerModes,
//                   categorize: categorize,
//                   javascriptCallbackType: javascriptCallbackType,
//                   includeFakeProviders: includeFakeProviders,
//                   lostConnectionNotify: lostConnectionNotify,
//                   showConsentConfirmation: showConsentConfirmation,
//                   credentialsStrategy: credentialsStrategy,
//                   consent: consent)
//    }
//
//    private enum CodingKeys: String, CodingKey {
//        case overrideCredentialsStrategy = "override_credentials_strategy"
//        case theme = "theme"
//    }
//
//    public override func encode(to encoder: Encoder) throws {
//        var container = encoder.container(keyedBy: CodingKeys.self)
//        try container.encodeIfPresent(overrideCredentialsStrategy, forKey: .overrideCredentialsStrategy)
//        try container.encodeIfPresent(theme, forKey: .theme)
//
//        try super.encode(to: encoder)
//    }
//}
