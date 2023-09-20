//
//  TokenIdentity.swift
//  VLAuthenticationLib
//
//  Created by Gaurav Vig on 28/11/22.
//

import Foundation

struct TokenIdentity:Decodable {
    var userId:String?
    var emailId:String?
    var phoneNumber:String?
    var siteName:String?
    var siteId:String?
    var countryCode:String?
    var deviceId:String?

    enum CodingKeys:String, CodingKey {
        case userId, siteId, phoneNumber, deviceId
        case emailId = "email"
        case siteName = "site"
    }
}
