//
//  VLAuthenticationObject.swift
//  VLAuthentication
//
//  Created by Gaurav Vig on 09/12/22.
//

import Foundation

public struct VLAuthenticationObject:Encodable {
    public var email:String?
    public var password:String?
    public var phoneNumber:String?
    public var emailConsent:Bool?
    public var accessToken:String?
    public var tveUserId:String?
    
    ///Only for subscription
    public var site:String?
    public var receipt:String?
    public var paymentUniqueId:String?
    public var receiptVersion:String?
    public var activationCode:String?
	
	///Only for verify
	public var value: String?
    public init() {}

}
