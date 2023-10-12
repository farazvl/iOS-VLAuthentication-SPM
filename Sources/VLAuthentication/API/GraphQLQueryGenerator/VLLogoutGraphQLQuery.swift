//
//  VLLogoutGraphQLQuery.swift
//  VLAuthentication
//
//  Created by Gaurav Vig on 07/02/23.
//

import Foundation

struct VLLogoutGraphQLQuery:VLGraphQLQueryProtocol {
    
    func generateGraphQLQuery() -> String {
        let query = """
mutation SignOutUser($site: String!, $device: EntitlementDevice!){
  identitySignOutUser(site: $site, device :$device) {
    status
  }
}
"""
        return query
    }
}
