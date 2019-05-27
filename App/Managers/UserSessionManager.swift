//
//  UserSessionManager.swift
//  Three Baskets
//
//  Created by Alexander Petropavlovsky on 28/11/2018.
//  Copyright © 2018 Real Tranzit. All rights reserved.
//

import Locksmith

private enum SessionKeys : String {
    ///ProviderName key for saving Provider.name which is a string representation of auth provider
    case Account, Tokens, AccessToken, UserId, JoyBasketId, RiskBasketId, SafeBasketId
}

class UserSessionManager: UserSessionManagerProtocol {
    
    var currentSession: Session? {
        return loadStoredSession()
    }
    
    var isUserAuthenticated: Bool {
        get {
            return currentSession != nil
        }
    }
    
    func save(session: Session) {
        saveData(session.token, withKey: SessionKeys.AccessToken.rawValue, inService: SessionKeys.Tokens.rawValue)
        saveData(session.userId, withKey: SessionKeys.UserId.rawValue, inService: SessionKeys.Tokens.rawValue)
        saveData(session.joyBasketId, withKey: SessionKeys.JoyBasketId.rawValue, inService: SessionKeys.Tokens.rawValue)
        saveData(session.riskBasketId, withKey: SessionKeys.RiskBasketId.rawValue, inService: SessionKeys.Tokens.rawValue)
        saveData(session.safeBasketId, withKey: SessionKeys.SafeBasketId.rawValue, inService: SessionKeys.Tokens.rawValue)
    }
    
    func loadStoredSession() -> Session? {
        if let data = accountDataInStorageInService(SessionKeys.Tokens.rawValue),
            let token = data[SessionKeys.AccessToken.rawValue] as? String,
            let userId = data[SessionKeys.UserId.rawValue] as? Int,
            let joyBasketId = data[SessionKeys.JoyBasketId.rawValue] as? Int,
            let riskBasketId = data[SessionKeys.RiskBasketId.rawValue] as? Int,
            let safeBasketId = data[SessionKeys.SafeBasketId.rawValue] as? Int {
            
            return Session(token: token,
                           userId: userId,
                           joyBasketId: joyBasketId,
                           riskBasketId: riskBasketId,
                           safeBasketId: safeBasketId)
        }
        return nil
    }
    
    func forgetSession() {
        do {
            try Locksmith.deleteDataForUserAccount(userAccount: SessionKeys.Account.rawValue, inService: SessionKeys.Tokens.rawValue)
        }
        catch {}
    }
    
    fileprivate func saveData(_ data: Any?, withKey key: String, inService service: String) {
        do {
            guard var accountData = accountDataInStorageInService(service) else {
                if let data = data {
                    try Locksmith.saveData(data: [key: data], forUserAccount: SessionKeys.Account.rawValue, inService: service)
                }
                return
            }
            if let data = data {
                accountData[key] = data as AnyObject?
            }
            else {
                accountData.removeValue(forKey: key)
            }
            try Locksmith.updateData(data: accountData, forUserAccount: SessionKeys.Account.rawValue, inService: service)
        }
        catch {
            print("Failed to save \(key) with value \(String(describing: data))")
        }
    }
    
    fileprivate func accountDataInStorageInService(_ service: String) -> Dictionary<String, AnyObject>? {
        guard let dict = Locksmith.loadDataForUserAccount(userAccount: SessionKeys.Account.rawValue, inService: service) as Dictionary<String, AnyObject>? else {
            return nil
        }
        return dict
    }
}
