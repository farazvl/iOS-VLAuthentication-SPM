//
//  AppleAuthenticatorModel.swift
//  VLAuthenticationLib
//
//  Created by Gaurav Vig on 02/12/22.
//

import Foundation

struct AppleAuthenticatorModel:Codable {
    var userId:String?
    var email:String?
    var firstName:String?
//    var lastName:String?
//    var fullName:String?
//    var authCode:String?
    var idToken:String?
    
    private enum CodingKeys:String, CodingKey {
        case userId, email, firstName//, lastName, fullName
//        case authCode = "AuthenticationCode"
        case idToken = "identityToken"
    }
}
