//
//  VLGraphQLResponse.swift
//  VLAuthentication
//
//  Created by Gaurav Vig on 07/02/23.
//

import Foundation

struct VLGraphQLResponse:Decodable {
    let data:VLGraphQLData?
    let errors:[VLGraphQLError]?
}

struct VLGraphQLData:Decodable {
    let identityInitiateSignOtp:VLOTPResponseObject?
    let identitySignOtpPasswordless:VLUserIdentity?
    let identitySignInByEmail:VLUserIdentity?
    let identitySignUpByEmail:VLUserIdentity?
    let identitySignInFacebook:VLUserIdentity?
    let identitySigninGoogle:VLUserIdentity?
    let identitySignInApple:VLUserIdentity?
    let identitySignInTve:VLUserIdentity?
    let identitySignInIos:VLUserIdentity?
}

struct VLGraphQLError:Decodable {
    let message:String?
    let extensions:VLErrorCode?
    
    struct VLErrorCode:Decodable {
        let code:String?
    }
}
