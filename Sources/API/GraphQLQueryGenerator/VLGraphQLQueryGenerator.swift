//
//  VLGraphQLQueryGenerator.swift
//  VLAuthentication
//
//  Created by Gaurav Vig on 07/02/23.
//

import Foundation

struct VLGraphQLQueryGenerator {
    
    enum QueryType {
        case google //Only for iOS
        case apple
        case facebook //Only for iOS
        case email
        case otpInitiate
        case otpValidate
        case tve
        case activateDevice
        case restoreSignIn //Only for SVOD application
        case mobileSignIn //Only for Apple TV
        case mobileSignInApprove //Only for iOS
        case logout
        case disconnectDeviceSync //Only for Apple TV
    }
    
    func createQuery(for queryType:QueryType, graphQLQuery:VLGraphQLQueryProtocol) -> String {
        switch queryType {
        case .otpInitiate:
            return VLOTPGraphQLQuery().queryToIntitateOTPAuthentication()
        default:
            return graphQLQuery.generateGraphQLQuery()
        }
    }

    ///TODO:  Missing
//
//    private func queryForDeviceCodeAuthentication() -> String {
//        let query = """
//mutation IdentitySignInFacebookRequest($site: String!, $input: SignInFacebookInput!){
//  identitySignInFacebook(site: $site, input: $input){
//       authorizationToken
//       refreshToken
//       userId
//       email
//       name
//       picture
//       isSubscribed
//       provider
//       passwordEnabled
//       phoneNumber
//       phoneCode
//       providers
//       existingUser
//  }
//}
//"""
//        return query
//    }
//

    
    ///TODO:  Missing
//    private func queryForMobileSignInAuthentication() -> String {
//        let query = """
//mutation IdentitySignInFacebookRequest($site: String!, $input: SignInFacebookInput!){
//  identitySignInFacebook(site: $site, input: $input){
//       authorizationToken
//       refreshToken
//       userId
//       email
//       name
//       picture
//       isSubscribed
//       provider
//       passwordEnabled
//       phoneNumber
//       phoneCode
//       providers
//       existingUser
//  }
//}
//"""
//        return query
//    }
    
    ///TODO:  Missing
//    private func queryToApproveMobileSignIn() -> String {
//        let query = """
//mutation IdentitySignInFacebookRequest($site: String!, $input: SignInFacebookInput!){
//  identitySignInFacebook(site: $site, input: $input){
//       authorizationToken
//       refreshToken
//       userId
//       email
//       name
//       picture
//       isSubscribed
//       provider
//       passwordEnabled
//       phoneNumber
//       phoneCode
//       providers
//       existingUser
//  }
//}
//"""
//        return query
//    }
    

    ///TODO: Missing
//    private func queryForDeleteAccount() -> String {
//        let query = """
//mutation IdentitySignInFacebookRequest($site: String!, $input: SignInFacebookInput!){
//  identitySignInFacebook(site: $site, input: $input){
//       authorizationToken
//       refreshToken
//       userId
//       email
//       name
//       picture
//       isSubscribed
//       provider
//       passwordEnabled
//       phoneNumber
//       phoneCode
//       providers
//       existingUser
//  }
//}
//"""
//        return query
//    }
}
