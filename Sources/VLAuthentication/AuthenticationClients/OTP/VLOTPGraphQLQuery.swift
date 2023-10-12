//
//  VLOTPGraphQLQuery.swift
//  VLAuthentication
//
//  Created by Gaurav Vig on 07/02/23.
//

import Foundation

struct VLOTPGraphQLQuery: VLGraphQLQueryProtocol, VLOTPGraphQLQueryProtocol {
    
    func generateGraphQLQuery() -> String {
        let query = """
mutation SignOtpPasswordless($site: String!, $device: EntitlementDevice!, $input: SignInByPhoneOrEmailInput!){
  identitySignOtpPasswordless(site: $site, device :$device, input: $input){
       authorizationToken
      refreshToken
      userId
      email
      name
      picture
      isSubscribed
      provider
      passwordEnabled
      phoneNumber
      phoneCode
      providers
      existingUser
  }
}
"""
        return query
    }
    
    func queryToIntitateOTPAuthentication() -> String {
        let query = """
mutation InitiateSignOtpRequest($site: String!, $device: EntitlementDevice!, $input: InitiatePasswordlessSignInput!){
  identityInitiateSignOtp(site: $site, device :$device, input: $input){
    key
  }
}
"""
        return query
    }
    
}
