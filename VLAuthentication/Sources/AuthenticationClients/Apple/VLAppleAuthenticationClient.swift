//
//  VLAppleAuthenticationClient.swift
//  VLAuthenticationLib
//
//  Created by Gaurav Vig on 25/11/22.
//

import Foundation

final class VLAppleAuthenticationClient:VLAuthenticationProtocol, VLAuthLogoutProtocol, VLBeaconEventTriggerProtocol {
    
    static let sharedInstance:VLAppleAuthenticationClient = {
        let instance = VLAppleAuthenticationClient()
        return instance
    }()
    
    private let appleAuthenticationManager = AppleAuthenticationManager.sharedInstance
    
    func initateLoginRequest(authClient:VLAuthenticationClient, userDetails:[String:Any], callback: @escaping ((_ userIdentity:VLUserIdentity?, _ errorCode:VLAuthenticationErrorCode?) -> Void)) {
        self.triggerUserBeaconEvent(eventName: .loginInit, type: .social, authType: .apple)
        self.invokeAppleAuthentication(userDetails: userDetails, eventName: .signin, callback: callback)
    }
    
    func initateSignUpRequest(authClient: VLAuthenticationClient, userDetails:[String:Any], callback: @escaping ((_ userIdentity:VLUserIdentity?, _ errorCode:VLAuthenticationErrorCode?) -> Void)) {
        self.triggerUserBeaconEvent(eventName: .signupInit, type: .social, authType: .apple)
        self.invokeAppleAuthentication(userDetails: userDetails, eventName: .signup, callback: callback)
    }
    
    func verifyAuthenticationRequest(authClient: VLAuthenticationClient, userDetails:[String:Any], callback: @escaping ((_ userIdentity:VLUserIdentity?, _ errorCode:VLAuthenticationErrorCode?) -> Void)) {
        
    }
    
    func logout(authClient:VLAuthenticationClient, callback: @escaping ((_ logoutSuccessfully:Bool) ->())) {
        self.invokeLogoutRequest(requestType: .post) { logoutSuccessfully in
            if logoutSuccessfully {
                self.triggerUserBeaconEvent(eventName: .logout, type: .social, authType: .apple)
            }
            callback(logoutSuccessfully)
        }
    }
}

extension VLAppleAuthenticationClient {
    
    private func invokeAppleAuthentication(userDetails:[String:Any], eventName: VLAuthenticationType, callback: @escaping ((_ userIdentity:VLUserIdentity?, _ errorCode:VLAuthenticationErrorCode?) -> Void)) {
        self.appleAuthenticationManager.performAuthentication(presenter: VLAuthentication.sharedInstance.presentingViewController?.view) { appleUserDetails, isSuccess, errorCode in
            guard let appleUserDetails, isSuccess else {
                callback(nil, errorCode)
                return
            }
            let updatedUserDetails = userDetails.merging(appleUserDetails, uniquingKeysWith: {(_, new) in new})
            self.invokeAuthenticationRequest(userDetails: updatedUserDetails, eventName: eventName, callback: callback)
        }
    }
    
    private func invokeAuthenticationRequest(userDetails:[String:Any], eventName: VLAuthenticationType, callback: @escaping ((_ userIdentity:VLUserIdentity?, _ errorCode:VLAuthenticationErrorCode?) -> Void)) {
        let apiRequest = APIUrl.getAPIBaseUrl() + APIUrlEndPoint.graphQLEndPoint.rawValue
        let query = VLGraphQLQueryGenerator().createQuery(for: .apple, graphQLQuery: VLAppleGraphQLQuery())
        let inputVariables = VLGraphQLInputVariableBuilder().getGraphQLInputVariables(customVariable: userDetails)
        let variables = VLGraphQLVariableBuilder(customVariable: inputVariables).getGraphQLVariables()
        let requestBody:[String:Any] = ["query": query, "variables": variables]
        Task {
            do {
                let loginResponse = try await VLAPIService().makeAuthenticationRequest(requestString: apiRequest, requestBody: requestBody, requestType: .post)
                guard loginResponse.1 == nil, let loginResponseObj = loginResponse.0?.data?.identitySignInApple else {
                    self.triggerUserBeaconEvent(eventName: eventName == .signup ? .signupFailure : .loginFailure, type: .social, authType: .apple)
                    callback(nil, loginResponse.1)
                    return
                }
                triggerUserBeaconEvent(eventName: eventName == .signup ? .signupSuccess : .loginSuccess, type: .social, authType: .apple, existingUser: loginResponseObj.existingUser)
                callback(loginResponseObj, loginResponse.1)
            }
            catch {
                self.triggerUserBeaconEvent(eventName: eventName == .signup ? .signupFailure : .loginFailure, type: .social, authType: .apple)
                callback(nil, .verificationFailed)
            }
        }
    }
}
/////////////
