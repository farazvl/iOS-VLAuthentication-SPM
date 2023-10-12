//
//  VLRestorePurchaseGraphQLQuery.swift
//  VLAuthentication
//
//  Created by Gaurav Vig on 07/02/23.
//

import Foundation

struct VLRestorePurchaseGraphQLQuery:VLGraphQLQueryProtocol {
    
    func generateGraphQLQuery() -> String {
        let query = """
mutation IdentitySignInByEmail($site: String!, $input: SignInIosInput) {
  identitySignInIos(site: $site, input: $input){
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
