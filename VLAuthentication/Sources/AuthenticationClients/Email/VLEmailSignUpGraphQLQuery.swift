//
//  VLEmailSignUpGraphQLQuery.swift
//  VLAuthentication
//
//  Created by Gaurav Vig on 07/02/23.
//

import Foundation

struct VLEmailSignUpGraphQLQuery:VLGraphQLQueryProtocol {
    
    func generateGraphQLQuery() -> String {
        let query = """
mutation IdentitySignInByEmail($site: String!, $device: EntitlementDevice!, $input: SignUpByEmailInput!) {
  identitySignUpByEmail(site: $site, device: $device, input: $input) {
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
