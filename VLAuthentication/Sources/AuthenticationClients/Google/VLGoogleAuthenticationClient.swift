//
//  VLGoogleAuthenticationClient.swift
//  VLAuthenticationLib
//
//  Created by Gaurav Vig on 25/11/22.
//

import Foundation

final class VLGoogleAuthenticationClient:VLAuthenticationProtocol, VLAuthLogoutProtocol, VLBeaconEventTriggerProtocol {
    static let sharedInstance:VLGoogleAuthenticationClient = {
        let instance = VLGoogleAuthenticationClient()
        return instance
    }()
    
    private let googleManager = GoogleManager()
    
    func initateLoginRequest(authClient:VLAuthenticationClient, userDetails:[String:Any], callback: @escaping ((_ userIdentity:VLUserIdentity?, _ errorCode:VLAuthenticationErrorCode?) -> Void)) {
        self.triggerUserBeaconEvent(eventName: .loginInit, type: .social, authType: .google)
        self.invokeGoogleSdkForLoginRequest(userDetails: userDetails, eventName: .signin, callback: callback)
    }
    
    func initateSignUpRequest(authClient: VLAuthenticationClient, userDetails:[String:Any], callback: @escaping ((_ userIdentity:VLUserIdentity?, _ errorCode:VLAuthenticationErrorCode?) -> Void)) {
        self.triggerUserBeaconEvent(eventName: .signupInit, type: .social, authType: .google)
        self.invokeGoogleSdkForLoginRequest(userDetails: userDetails, eventName: .signup, callback: callback)
    }
    
    func verifyAuthenticationRequest(authClient: VLAuthenticationClient, userDetails:[String:Any], callback: @escaping ((_ userIdentity:VLUserIdentity?, _ errorCode:VLAuthenticationErrorCode?) -> Void)) {
        
    }
    
    func logout(authClient:VLAuthenticationClient, callback: @escaping ((_ logoutSuccessfully:Bool) ->())) {
        self.invokeLogoutRequest(requestType: .post) { logoutSuccessfully in
            if logoutSuccessfully {
                self.triggerUserBeaconEvent(eventName: .logout, type: .social, authType: .google)
            }
            callback(logoutSuccessfully)
        }
        googleManager.logout()
    }
}

extension VLGoogleAuthenticationClient {
    
    private func invokeGoogleSdkForLoginRequest(userDetails:[String:Any], eventName: VLAuthenticationType, callback: @escaping ((_ userIdentity:VLUserIdentity?, _ errorCode:VLAuthenticationErrorCode?) -> Void)) {
        guard let _ = Bundle.main.infoDictionary?["GoogleClientId"] as? String else {
            callback(nil, .missingGoogleConfiguration)
            return
        }
        guard let presentingViewController = VLAuthentication.sharedInstance.presentingViewController else {
            callback(nil, .missingPresentingView)
            return
        }
        googleManager.loginWithGoogle(googleLoginDone: { (loginDone, googleToken, name, email, googleId) in
            guard let googleToken else {
                callback(nil, .googleAuthenticationFailed)
                return
            }
            var updatedUserDetails = userDetails
            updatedUserDetails["googleToken"] = googleToken
            self.makeLoginRequest(userDetails: updatedUserDetails, eventName: eventName, callback: callback)
        }, viewController: presentingViewController)
    }
    
    private func makeLoginRequest(userDetails:[String:Any], eventName: VLAuthenticationType, callback: @escaping ((_ userIdentity:VLUserIdentity?, _ errorCode:VLAuthenticationErrorCode?) -> Void)) {
        let apiRequest = APIUrl.getAPIBaseUrl() + APIUrlEndPoint.graphQLEndPoint.rawValue
        let query = VLGraphQLQueryGenerator().createQuery(for: .google, graphQLQuery: VLGoogleGraphQLQuery())
        let inputVariables = VLGraphQLInputVariableBuilder().getGraphQLInputVariables(customVariable: userDetails)
        let variables = VLGraphQLVariableBuilder(customVariable: inputVariables).getGraphQLVariables()
        let requestBody:[String:Any] = ["query": query, "variables": variables]
        Task {
            do {
                let loginResponse = try await VLAPIService().makeAuthenticationRequest(requestString: apiRequest, requestBody: requestBody, requestType: .post)
                guard loginResponse.1 == nil, let loginResponseObj = loginResponse.0?.data?.identitySigninGoogle else {
                    self.triggerUserBeaconEvent(eventName: eventName == .signup ? .signupFailure : .loginFailure, type: .social, authType: .google)
                    callback(nil, loginResponse.1)
                    return
                }
                triggerUserBeaconEvent(eventName: eventName == .signup ? .signupSuccess : .loginSuccess, type: .social, authType: .google, existingUser: loginResponseObj.existingUser)
                callback(loginResponseObj, loginResponse.1)
            }
            catch {
                self.triggerUserBeaconEvent(eventName: eventName == .signup ? .signupFailure : .loginFailure, type: .social, authType: .google)
                callback(nil, .verificationFailed)
            }
        }
    }
}
