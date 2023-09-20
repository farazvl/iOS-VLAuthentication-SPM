//
//  VLFacebookAuthenticationClient.swift
//  VLAuthenticationLib
//
//  Created by Gaurav Vig on 25/11/22.
//

import Foundation
import UIKit

final class VLFacebookAuthenticationClient:VLAuthenticationProtocol, VLAuthLogoutProtocol, VLBeaconEventTriggerProtocol {

    static let sharedInstance:VLFacebookAuthenticationClient = {
        let instance = VLFacebookAuthenticationClient()
        return instance
    }()

    private let facebookManager = FacebookManager()

    func initateLoginRequest(authClient:VLAuthenticationClient, userDetails:[String:Any], callback: @escaping ((_ userIdentity:VLUserIdentity?, _ errorCode:VLAuthenticationErrorCode?) -> Void)) {
        self.triggerUserBeaconEvent(eventName: .loginInit, type: .social, authType: .facebook)
        self.invokeFBSdkForLoginRequest(userDetails: userDetails, eventName: .signin, callback: callback)
    }

    func initateSignUpRequest(authClient: VLAuthenticationClient, userDetails:[String:Any], callback: @escaping ((_ userIdentity:VLUserIdentity?, _ errorCode:VLAuthenticationErrorCode?) -> Void)) {
        self.triggerUserBeaconEvent(eventName: .signupInit, type: .social, authType: .facebook)
        self.invokeFBSdkForLoginRequest(userDetails: userDetails, eventName: .signup, callback: callback)
    }

    func verifyAuthenticationRequest(authClient: VLAuthenticationClient, userDetails:[String:Any], callback: @escaping ((_ userIdentity:VLUserIdentity?, _ errorCode:VLAuthenticationErrorCode?) -> Void)) {

    }

    func logout(authClient:VLAuthenticationClient, callback: @escaping ((_ logoutSuccessfully:Bool) ->())) {
        self.invokeLogoutRequest(requestType: .post) { logoutSuccessfully in
            if logoutSuccessfully {
                self.triggerUserBeaconEvent(eventName: .logout, type: .social, authType: .facebook)
            }
            callback(logoutSuccessfully)
        }
        facebookManager.logout()
    }

    internal func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) {
        facebookManager.application(application, didFinishLaunchingWithOptions: launchOptions)
    }

    internal func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any]) -> Bool {
        return facebookManager.application(app, open: url, options: options)
    }
}

extension VLFacebookAuthenticationClient {

    private func invokeFBSdkForLoginRequest(userDetails:[String:Any], eventName: VLAuthenticationType, callback: @escaping ((_ userIdentity:VLUserIdentity?, _ errorCode:VLAuthenticationErrorCode?) -> Void)) {
        guard let _ = Bundle.main.infoDictionary?["FacebookAppID"], let _ = Bundle.main.infoDictionary?["FacebookClientToken"] else {
            callback(nil, .missingFacebookConfiguration)
            return
        }
        guard let presentingViewController = VLAuthentication.sharedInstance.presentingViewController else {
            callback(nil, .missingPresentingView)
            return
        }
        facebookManager.loginWithFacebook(facebookLoginDone: { loginStatus, fbAccessToken, name, email, fbID in
            guard loginStatus || !fbAccessToken.isEmpty else {
                callback(nil, .facebookAuthenticationFailed)
                return
            }
            var updatedUserDetails = userDetails
            updatedUserDetails["facebookToken"] = fbAccessToken
//            updatedUserDetails["userId"] = fbID
//            if let email {
//                updatedUserDetails["email"] = email
//            }
            self.makeLoginRequest(userDetails: updatedUserDetails, eventName: eventName, callback: callback)
        }, viewController: presentingViewController)

    }

    private func makeLoginRequest(userDetails:[String:Any], eventName: VLAuthenticationType, callback: @escaping ((_ userIdentity:VLUserIdentity?, _ errorCode:VLAuthenticationErrorCode?) -> Void)) {
        let apiRequest = APIUrl.getAPIBaseUrl() + APIUrlEndPoint.graphQLEndPoint.rawValue
        let query = VLGraphQLQueryGenerator().createQuery(for: .facebook, graphQLQuery: VLFacebookGraphQLQuery())
        let inputVariables:[String:Any] = VLGraphQLInputVariableBuilder().getGraphQLInputVariables(customVariable: userDetails)
        let variables = VLGraphQLVariableBuilder(customVariable: inputVariables).getGraphQLVariables()
        let requestBody:[String:Any] = ["query": query, "variables": variables]

        Task {
            do {
                let loginResponse = try await VLAPIService().makeAuthenticationRequest(requestString: apiRequest, requestBody: requestBody, requestType: .post)
                guard loginResponse.1 == nil, let loginResponseObj = loginResponse.0?.data?.identitySignInFacebook else {
                    self.triggerUserBeaconEvent(eventName: eventName == .signup ? .signupFailure : .loginFailure, type: .social, authType: .facebook)
                    callback(nil, loginResponse.1)
                    return
                }
                //triggerUserBeaconEvent(eventName: eventName == .signup ? .signupSuccess : .loginSuccess, type: .social, authType: .facebook, existingUser: loginResponseObj.existingUser)
                callback(loginResponseObj, loginResponse.1)
            }
            catch {
                self.triggerUserBeaconEvent(eventName: eventName == .signup ? .signupFailure : .loginFailure, type: .social, authType: .facebook)
                callback(nil, .verificationFailed)
            }
        }
    }
}
