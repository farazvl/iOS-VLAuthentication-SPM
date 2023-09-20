//
//  VLEmailAuthenticationClient.swift
//  VLAuthentication
//
//  Created by Gaurav Vig on 25/11/22.
//

import Foundation

final class VLEmailAuthenticationClient: VLAuthenticationProtocol, VLAuthLogoutProtocol, VLBeaconEventTriggerProtocol {
    
    static let sharedInstance:VLEmailAuthenticationClient = {
        let instance = VLEmailAuthenticationClient()
        return instance
    }()
    
    func initateLoginRequest(authClient:VLAuthenticationClient, userDetails:[String:Any], callback: @escaping ((_ userIdentity:VLUserIdentity?, _ errorCode:VLAuthenticationErrorCode?) -> Void)) {
        self.triggerUserBeaconEvent(eventName: .loginInit, type: .viewlift, authType: .email)
        self.makeLoginRequest(userDetails: userDetails, callback: callback)
    }
    
    func initateSignUpRequest(authClient: VLAuthenticationClient, userDetails:[String:Any], callback: @escaping ((_ userIdentity:VLUserIdentity?, _ errorCode:VLAuthenticationErrorCode?) -> Void)) {
        self.triggerUserBeaconEvent(eventName: .signupInit, type: .viewlift, authType: .email)
        self.makeSignUpRequest(userDetails: userDetails, callback: callback)
    }
    
    func verifyAuthenticationRequest(authClient: VLAuthenticationClient, userDetails:[String:Any], callback: @escaping ((_ userIdentity:VLUserIdentity?, _ errorCode:VLAuthenticationErrorCode?) -> Void)) {
        
    }
    
    func logout(authClient:VLAuthenticationClient, callback: @escaping ((_ logoutSuccessfully:Bool) ->())) {
        self.invokeLogoutRequest(requestType: .post) { logoutSuccessfully in
            if logoutSuccessfully {
                self.triggerUserBeaconEvent(eventName: .logout, type: .viewlift, authType: .email)
            }
            callback(logoutSuccessfully)
        }
    }
}

extension VLEmailAuthenticationClient {
    
    private func makeLoginRequest(userDetails:[String:Any], callback: @escaping ((_ userIdentity:VLUserIdentity?, _ errorCode:VLAuthenticationErrorCode?) -> Void)) {
        let apiRequest = APIUrl.getAPIBaseUrl() + APIUrlEndPoint.graphQLEndPoint.rawValue
        let query = VLGraphQLQueryGenerator().createQuery(for: .email, graphQLQuery: VLEmailSignInGraphQLQuery())
        let inputVariables:[String:Any] = VLGraphQLInputVariableBuilder().getGraphQLInputVariables(customVariable: userDetails)
        let variables = VLGraphQLVariableBuilder(customVariable: inputVariables).getGraphQLVariables()
        let requestBody:[String:Any] = ["query": query, "variables": variables]
        
        Task {
            do {
                let loginResponse = try await VLAPIService().makeAuthenticationRequest(requestString: apiRequest, requestBody: requestBody, requestType: .post)
                guard loginResponse.1 == nil, let loginResponseObj = loginResponse.0?.data?.identitySignInByEmail else {
                    self.triggerUserBeaconEvent(eventName: .loginFailure, type: .viewlift, authType: .email)
                    callback(nil, loginResponse.1)
                    return
                }
                self.triggerUserBeaconEvent(eventName: .loginSuccess, type: .viewlift, authType: .email,existingUser: loginResponseObj.existingUser)
                callback(loginResponseObj, loginResponse.1)
            }
            catch {
                self.triggerUserBeaconEvent(eventName: .loginFailure, type: .viewlift, authType: .email)
                callback(nil, .verificationFailed)
            }
        }
    }
    
    private func makeSignUpRequest(userDetails:[String:Any], callback: @escaping ((_ userIdentity:VLUserIdentity?, _ errorCode:VLAuthenticationErrorCode?) -> Void)) {
        let apiRequest = APIUrl.getAPIBaseUrl() + APIUrlEndPoint.graphQLEndPoint.rawValue
        let query = VLGraphQLQueryGenerator().createQuery(for: .email, graphQLQuery: VLEmailSignUpGraphQLQuery())
        let inputVariables = VLGraphQLInputVariableBuilder().getGraphQLInputVariables(customVariable: userDetails)
        let variables = VLGraphQLVariableBuilder(customVariable: inputVariables).getGraphQLVariables()
        let requestBody:[String:Any] = ["query": query, "variables": variables]
        
        Task {
            do {
                let loginResponse = try await VLAPIService().makeAuthenticationRequest(requestString: apiRequest, requestBody: requestBody, requestType: .post)
                guard loginResponse.1 == nil, let loginResponseObj = loginResponse.0?.data?.identitySignUpByEmail else {
                    self.triggerUserBeaconEvent(eventName: .signupFailure, type: .viewlift, authType: .email)
                    callback(nil, loginResponse.1)
                    return
                }
                self.triggerUserBeaconEvent(eventName: .signupSuccess, type: .viewlift, authType: .email, existingUser: loginResponseObj.existingUser)
                callback(loginResponseObj, loginResponse.1)
            }
            catch {
                self.triggerUserBeaconEvent(eventName: .signupFailure, type: .viewlift, authType: .email)
                callback(nil, .verificationFailed)
            }
        }
    }
}
