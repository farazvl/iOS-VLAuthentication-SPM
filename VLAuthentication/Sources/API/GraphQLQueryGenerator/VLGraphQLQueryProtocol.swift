//
//  VLGraphQLQueryProtocol.swift
//  VLAuthentication
//
//  Created by Gaurav Vig on 07/02/23.
//

import Foundation

protocol VLGraphQLQueryProtocol {

    func generateGraphQLQuery() -> String
}

protocol VLOTPGraphQLQueryProtocol {
    func queryToIntitateOTPAuthentication() -> String
}
