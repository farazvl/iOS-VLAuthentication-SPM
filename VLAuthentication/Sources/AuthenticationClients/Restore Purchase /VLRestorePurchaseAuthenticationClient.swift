//
//  VLRestorePurchaseAuthenticationClient.swift
//  VLAuthentication
//
//  Created by Gaurav Vig on 15/12/22.
//

import Foundation

final class VLRestorePurchaseAuthenticationClient:VLAuthenticationProtocol, VLAuthLogoutProtocol {
    
    static let sharedInstance:VLRestorePurchaseAuthenticationClient = {
        let instance = VLRestorePurchaseAuthenticationClient()
        return instance
    }()
    
    func initateLoginRequest(authClient:VLAuthenticationClient, userDetails:[String:Any], callback: @escaping ((_ userIdentity:VLUserIdentity?, _ errorCode:VLAuthenticationErrorCode?) -> Void)) {
        self.triggerUserBeaconEvent(eventName: .loginInit, type: .viewlift, authType: .custom(eventName: "restore-purchase"))
        self.makeLoginRequest(userDetails: userDetails, eventName: .signin, callback: callback)
    }
    
    func initateSignUpRequest(authClient: VLAuthenticationClient, userDetails:[String:Any], callback: @escaping ((_ userIdentity:VLUserIdentity?, _ errorCode:VLAuthenticationErrorCode?) -> Void)) {
        self.triggerUserBeaconEvent(eventName: .signupInit, type: .viewlift, authType: .custom(eventName: "restore-purchase"))
        self.makeLoginRequest(userDetails: userDetails, eventName: .signup, callback: callback)
    }
    
    func verifyAuthenticationRequest(authClient: VLAuthenticationClient, userDetails:[String:Any], callback: @escaping ((_ userIdentity:VLUserIdentity?, _ errorCode:VLAuthenticationErrorCode?) -> Void)) {
        
    }
    
    func logout(authClient:VLAuthenticationClient, callback: @escaping ((_ logoutSuccessfully:Bool) ->())) {
        self.invokeLogoutRequest(requestType: .post) { logoutSuccessfully in
            if logoutSuccessfully {
                self.triggerUserBeaconEvent(eventName: .logout, type: .viewlift, authType: .custom(eventName: "restore-purchase"))
            }
            callback(logoutSuccessfully)
        }
    }
}

extension VLRestorePurchaseAuthenticationClient: VLBeaconEventTriggerProtocol {
    
    private func makeLoginRequest(userDetails:[String:Any], eventName: VLAuthenticationType, callback: @escaping ((_ userIdentity:VLUserIdentity?, _ errorCode:VLAuthenticationErrorCode?) -> Void)) {
        let apiRequest = APIUrl.getAPIBaseUrl() + APIUrlEndPoint.restorePurchaseSignInEndPoint.rawValue + "?" + VLAPIRequestParamBuilder().getRequestParam()
        Task {
            do {
                let loginResponse = try await VLAPIService().makeAuthenticationRequestViaRestAPI(requestString: apiRequest, requestBody: userDetails, requestType: .post)
                //triggerUserBeaconEvent(eventName: eventName == .signup ? .signupSuccess : .loginSuccess, type: .viewlift, authType: .custom(eventName: "restore-purchase"), existingUser: loginResponse.0?.existingUser)
                callback(loginResponse.0, loginResponse.1)
            }
            catch {
                //triggerUserBeaconEvent(eventName: eventName == .signup ? .signupFailure : .loginFailure, type: .viewlift, authType: .custom(eventName: "restore-purchase"))
                callback(nil, .verificationFailed)
            }
        }
    }
    
//    private func makeLoginRequest(userDetails:[String:Any], callback: @escaping ((_ userIdentity:VLUserIdentity?, _ errorCode:VLAuthenticationErrorCode?) -> Void)) {
//        let apiRequest = APIUrl.getAPIBaseUrl() + APIUrlEndPoint.graphQLEndPoint.rawValue
//        let query = VLGraphQLQueryGenerator().createQuery(for: .restoreSignIn, graphQLQuery: VLRestorePurchaseGraphQLQuery())
//        let inputVariables = VLGraphQLInputVariableBuilder().getGraphQLInputVariables(customVariable: userDetails)
//        let variables = VLGraphQLVariableBuilder(customVariable: inputVariables).getGraphQLVariables()
//        let requestBody:[String:Any] = ["query": query, "variables": variables]
//        Task {
//            do {
//                let loginResponse = try await VLAPIService().makeAuthenticationRequest(requestString: apiRequest, requestBody: requestBody, requestType: .post)
//                guard loginResponse.1 == nil, let loginResponseObj = loginResponse.0?.data?.identitySignInIos else {
//                    callback(nil, loginResponse.1)
//                    return
//                }
//
//                callback(loginResponseObj, loginResponse.1)
//            }
//            catch {
//                callback(nil, .noUserDetailsFound)
//            }
//        }
//    }
}
