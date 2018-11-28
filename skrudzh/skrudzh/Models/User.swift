//
//  User.swift
//  skrudzh
//
//  Created by Alexander Petropavlovsky on 28/11/2018.
//  Copyright © 2018 rubikon. All rights reserved.
//

import Foundation
import ObjectMapper

enum Gender: String {
    case male = "male"
    case female = "female"
    
    var displayName: String {
        switch self {
        case .male:
            return "Male"
        case .female:
            return "Female"
        }
    }
    
    var value: Int {
        return Gender.all().index(of: self)!
    }
    
    static func gender(by index: Int) -> Gender? {
        return Gender.all().item(at: index)
    }
    
    static func all() -> [Gender] {
        return [.male, .female]
    }
    
    static func allOptional() -> [Gender?] {
        return [nil, .male, .female]
    }
}

extension Gender : CustomStringConvertible {
    var description: String {
        return displayName
    }
}

extension Gender : Hashable {
    var hashValue: Int {
        return rawValue.hashValue
    }
    
    static func ==(lhs: Gender, rhs: Gender) -> Bool {
        return lhs.hashValue == rhs.hashValue
    }
}

class User : Codable {
    var id: Int?
    var email: String?
    var firstname: String?
    var lastname: String?
    var city: String?
    var country: String?
    var languages: [String]?
    var gender: Gender?
    var provider: AuthProvider?
    var providerUserId: String?
    var birthday: Date?
    var photoUrl: String?
    
    var fullname: String? {
        if let firstname = firstname, !firstname.isEmpty, let lastname = lastname, !lastname.isEmpty {
            return "\(firstname) \(lastname)"
        }
        
        if let firstname = firstname, !firstname.isEmpty {
            return firstname
        }
        
        return nil
        
    }
    
    init() {
        
    }
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        id              <- map["id"]
        email           <- map["email"]
        firstname       <- map["firstname"]
        lastname        <- map["lastname"]
        city            <- map["city"]
        country         <- map["country"]
        languages       <- map["languages"]
        gender          <- map["gender"]
        provider        <- map["provider"]
        providerUserId  <- map["provider_user_id"]
        birthday        <- (map["birthday"], CustomDateFormatTransform(formatString: "yyyy-MM-dd'T'HH:mm:ss.SSSZ"))
        photoUrl        <- map["photo_url"]
    }
}

class UserCreationForm : Mappable {
    var email: String?
    var password: String?
    var passwordConfirmation: String?
    
    init() {
        
    }
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        email                   <- map["email"]
        password                <- map["password"]
        passwordConfirmation    <- map["password_confirmation"]
    }
}

class ChangePasswordForm : Mappable {
    var userId: Int?
    var oldPassword: String?
    var newPassword: String?
    var newPasswordConfirmation: String?
    
    init() {
        
    }
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        userId                      <- map["user_id"]
        oldPassword                 <- map["old_password"]
        newPassword                 <- map["new_password"]
        newPasswordConfirmation     <- map["new_password_confirmation"]
    }
}

class ResetPasswordForm : Mappable {
    var email: String?
    var confirmationCode: String?
    var newPassword: String?
    var newPasswordConfirmation: String?
    
    init() {
        
    }
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        email                       <- map["email"]
        confirmationCode            <- map["confirmation_code"]
        newPassword                 <- map["new_password"]
        newPasswordConfirmation     <- map["new_password_confirmation"]
    }
}
