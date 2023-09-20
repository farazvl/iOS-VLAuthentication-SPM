//
//  VLTVAuthenticationClient.swift
//  VLAuthenticationLib
//
//  Created by Gaurav Vig on 25/11/22.
//

import Foundation

final class VLTVAuthenticationClient:VLAuthenticationProtocol, VLAuthLogoutProtocol, VLBeaconEventTriggerProtocol {
    
    static let sharedInstance:VLTVAuthenticationClient = {
        let instance = VLTVAuthenticationClient()
        return instance
    }()
    
    var tveProvider:VLAuthenticationClient.TVProvider = .adobe
    
    func initateLoginRequest(authClient:VLAuthenticationClient, userDetails:[String:Any], callback: @escaping ((_ userIdentity:VLUserIdentity?, _ errorCode:VLAuthenticationErrorCode?) -> Void)) {
        self.triggerUserBeaconEvent(eventName: .loginInit, type: .tve, authType: .activateDevice)
        self.makeLoginRequest(userDetails: userDetails, eventName: .signin, callback: callback)
    }
    
    func initateSignUpRequest(authClient: VLAuthenticationClient, userDetails:[String:Any], callback: @escaping ((_ userIdentity:VLUserIdentity?, _ errorCode:VLAuthenticationErrorCode?) -> Void)) {
        self.triggerUserBeaconEvent(eventName: .signupInit, type: .tve, authType: .activateDevice)
        self.makeLoginRequest(userDetails: userDetails, eventName: .signup, callback: callback)
    }
    
    func verifyAuthenticationRequest(authClient: VLAuthenticationClient, userDetails:[String:Any], callback: @escaping ((_ userIdentity:VLUserIdentity?, _ errorCode:VLAuthenticationErrorCode?) -> Void)) {
        
    }
    
    func logout(authClient:VLAuthenticationClient, callback: @escaping ((_ logoutSuccessfully:Bool) ->())) {
        self.invokeLogoutRequest(requestType: .post) { logoutSuccessfully in
            if logoutSuccessfully {
                self.triggerUserBeaconEvent(eventName: .logout, type: .tve, authType: .activateDevice)
            }
            callback(logoutSuccessfully)
        }
    }
}

extension VLTVAuthenticationClient {
    
    private func makeLoginRequest(userDetails:[String:Any], eventName: VLAuthenticationType, callback: @escaping ((_ userIdentity:VLUserIdentity?, _ errorCode:VLAuthenticationErrorCode?) -> Void)) {
        let apiRequest = APIUrl.getAPIBaseUrl() + APIUrlEndPoint.graphQLEndPoint.rawValue
        let query = VLGraphQLQueryGenerator().createQuery(for: .tve, graphQLQuery: VLTVEGraphQLQuery())
        let inputVariables = VLGraphQLInputVariableBuilder().getGraphQLInputVariables(customVariable: userDetails)
        let variables = VLGraphQLVariableBuilder(customVariable: inputVariables).getGraphQLVariables()
        let requestBody:[String:Any] = ["query": query, "variables": variables]
        Task {
            do {
                let loginResponse = try await VLAPIService().makeAuthenticationRequest(requestString: apiRequest, requestBody: requestBody, requestType: .post)
                guard loginResponse.1 == nil, let loginResponseObj = loginResponse.0?.data?.identitySignInTve else {
                    self.triggerUserBeaconEvent(eventName: eventName == .signup ? .signupFailure : .loginFailure, type: .tve, authType: .activateDevice)
                    callback(nil,loginResponse.1)
                    return
                }
               // triggerUserBeaconEvent(eventName: eventName == .signup ? .signupSuccess : .loginSuccess, type: .tve, authType: .activateDevice, existingUser: loginResponseObj.existingUser)
                callback(loginResponseObj, loginResponse.1)
            }
            catch {
                self.triggerUserBeaconEvent(eventName: eventName == .signup ? .signupFailure : .loginFailure, type: .tve, authType: .activateDevice)
                callback(nil, .verificationFailed)
            }
        }
    }
}
