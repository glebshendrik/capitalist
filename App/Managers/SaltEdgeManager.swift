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
    
    func set(appId: String, appSecret: String) {
        SERequestManager.shared.set(appId: appId, appSecret: appSecret)
    }
    
    func set(customerSecret: String) {
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
    
    func createConnectSession(provider: SEProvider, languageCode: String) -> Promise<URL> {
        
        let connectSessionsParams = SEConnectSessionsParams(allowedCountries: [provider.countryCode],        
                                                            attempt: SEAttempt(locale: languageCode, returnTo: "http://tempio.app"),
                                                            providerCode: provider.code,
                                                            javascriptCallbackType: "iframe",
                                                            consent: SEConsent(scopes: ["account_details", "transactions_details"]))
        
        return Promise { seal in
            SERequestManager.shared.createConnectSession(params: connectSessionsParams) { response in
                switch response {
                case .success(let value):
                    
                    guard let url = URL(string: value.data.connectUrl) else {
                        seal.reject(SaltEdgeError.cannotCreateConnectSession)
                        return
                    }
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
    
    func refreshConnection(secret: String, provider: SEProvider, fetchingDelegate: SEConnectionFetchingDelegate) -> Promise<Void> {
        let params = SEConnectionRefreshParams(attempt: SEAttempt(returnTo: "AppDelegate.applicationURLString"))

        return Promise { seal in
            SERequestManager.shared.refreshConnection(
                with: secret,
                params: provider.isOAuth ? params : nil,
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
