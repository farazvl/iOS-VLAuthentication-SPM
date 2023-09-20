//
//  VLFacebookGraphQLQuery.swift
//  VLAuthentication
//
//  Created by Gaurav Vig on 07/02/23.
//

import Foundation

struct VLFacebookGraphQLQuery:VLGraphQLQueryProtocol {
    
    func generateGraphQLQuery() -> String {
        let query = """
mutation IdentitySignInFacebookRequest($site: String!, $input: SignInFacebookInput!){
  identitySignInFacebook(site: $site, input: $input){
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
