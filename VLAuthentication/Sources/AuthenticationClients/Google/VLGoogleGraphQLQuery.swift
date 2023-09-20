//
//  VLGoogleGraphQLQuery.swift
//  VLAuthentication
//
//  Created by Gaurav Vig on 07/02/23.
//

import Foundation

struct VLGoogleGraphQLQuery:VLGraphQLQueryProtocol {
    
    func generateGraphQLQuery() -> String {
        let query = """
mutation IdentitySignInGoogleRequest($site: String!, $device: EntitlementDevice!, $input: SignInGoogleInput!){
  identitySigninGoogle(site: $site, device :$device, input: $input){
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
