//
//  UserSessionManager.swift
//  skrudzh
//
//  Created by Alexander Petropavlovsky on 28/11/2018.
//  Copyright © 2018 rubikon. All rights reserved.
//

import Locksmith

private enum SessionKeys : String {
    ///ProviderName key for saving Provider.name which is a string representation of auth provider
    case Account, Tokens, AccessToken, UserId
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
    }
    
    func loadStoredSession() -> Session? {
        if let data = accountDataInStorageInService(SessionKeys.Tokens.rawValue),
            let token = data[SessionKeys.AccessToken.rawValue] as? String,
            let userId = data[SessionKeys.UserId.rawValue] as? Int {
            
            return Session(token: token, userId: userId)
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
