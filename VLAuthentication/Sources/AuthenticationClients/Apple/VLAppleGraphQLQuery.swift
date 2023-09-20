//
//  VLAppleGraphQLQuery.swift
//  VLAuthentication
//
//  Created by Gaurav Vig on 07/02/23.
//

import Foundation

struct VLAppleGraphQLQuery:VLGraphQLQueryProtocol {
    
    func generateGraphQLQuery() -> String {
        let query = """
mutation IdentitySignInAppleRequest($site: String!, $device: EntitlementDevice!, $input: AppleSignInInput!){
  identitySignInApple(site: $site, device :$device, input: $input){
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
}
