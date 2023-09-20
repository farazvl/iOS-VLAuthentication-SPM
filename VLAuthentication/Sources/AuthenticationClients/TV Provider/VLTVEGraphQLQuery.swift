//
//  VLTVEGraphQLQuery.swift
//  VLAuthentication
//
//  Created by Gaurav Vig on 07/02/23.
//

import Foundation

struct VLTVEGraphQLQuery:VLGraphQLQueryProtocol {
    
    func generateGraphQLQuery() -> String {
        let query = """
mutation IdentitySignInTveRequest($site: String!, $input: SignInTveInput!){
    identitySignInTve(site: $site, input: $input){
        authorizationToken
        refreshToken
        userId
        tveUserId
        email
        name
        isSubscribed
        provider
        providers
        idpName
        idpLogo
        planId
    }
}
"""
        return query
    }
}
