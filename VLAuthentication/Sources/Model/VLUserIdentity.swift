//
//  VLUserIdentity.swift
//  VLAuthentication
//
//  Created by Gaurav Vig on 25/11/22.
//

import Foundation

public struct VLUserIdentity:Decodable {
    public let authorizationToken:String?
    public let refreshToken:String?
    public let userId:String?
    public let email:String?
    public let name:String?
    public let isSubscribed:Bool?
    public let provider:String?
    public let providers:[String]?
    public let passwordEnabled:Bool?
    public let phoneNumber:String?
    public let phoneCode:Int?
    public let profileId:String?
    public let errorCode:String?
    public let errorMessage:String?
    public let countryCode:Int?
    public let existingUser:Bool?
	public let status: Bool?
    
    private enum CodingKeys:String, CodingKey {
        case authorizationToken, refreshToken, userId, email, name, isSubscribed, provider, providers, passwordEnabled, phoneNumber, phoneCode
        case profileId, countryCode, existingUser, status
        case errorCode = "code"
        case errorMessage = "error"
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.authorizationToken = try? container.decodeIfPresent(String.self, forKey: .authorizationToken)
        self.refreshToken = try? container.decodeIfPresent(String.self, forKey: .refreshToken)
        self.userId = try? container.decodeIfPresent(String.self, forKey: .userId)
        self.email = try? container.decodeIfPresent(String.self, forKey: .email)
        self.name = try? container.decodeIfPresent(String.self, forKey: .name)
        self.isSubscribed = try? container.decodeIfPresent(Bool.self, forKey: .isSubscribed)
        self.provider = try? container.decodeIfPresent(String.self, forKey: .provider)
        self.providers = try? container.decodeIfPresent([String].self, forKey: .providers)
        self.passwordEnabled = try? container.decodeIfPresent(Bool.self, forKey: .passwordEnabled)
        self.phoneNumber = try? container.decodeIfPresent(String.self, forKey: .phoneNumber)
        self.phoneCode = try? container.decodeIfPresent(Int.self, forKey: .phoneCode)
        self.profileId = try? container.decodeIfPresent(String.self, forKey: .profileId)
        self.errorCode = try? container.decodeIfPresent(String.self, forKey: .errorCode)
        self.errorMessage = try? container.decodeIfPresent(String.self, forKey: .errorMessage)
        self.countryCode = try? container.decodeIfPresent(Int.self, forKey: .countryCode)
        self.existingUser = try? container.decodeIfPresent(Bool.self, forKey: .existingUser)
		self.status = try? container.decodeIfPresent(Bool.self, forKey: .status)
    }
}
