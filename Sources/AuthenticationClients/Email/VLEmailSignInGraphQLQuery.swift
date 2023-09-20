//
//  VLEmailSignInGraphQLQuery.swift
//  VLAuthentication
//
//  Created by Gaurav Vig on 07/02/23.
//

import Foundation

struct VLEmailSignInGraphQLQuery:VLGraphQLQueryProtocol {
    
    func generateGraphQLQuery() -> String {
        let query = """
mutation IdentitySignInByEmail($device: EntitlementDevice!, $site: String!, $input: SignInByEmailInput!) {
  identitySignInByEmail(device: $device, site: $site, input: $input){
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
