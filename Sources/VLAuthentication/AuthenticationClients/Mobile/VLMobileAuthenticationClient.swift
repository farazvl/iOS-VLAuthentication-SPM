//
//  VLMobileAuthenticationClient.swift
//  VLAuthenticationLib
//
//  Created by Gaurav Vig on 25/11/22.
//

import Foundation

final class VLMobileAuthenticationClient:VLAuthenticationProtocol, VLAuthenticationDeviceSyncProtocol, VLAuthLogoutProtocol, VLBeaconEventTriggerProtocol {
    
    static let sharedInstance:VLMobileAuthenticationClient = {
        let instance = VLMobileAuthenticationClient()
        return instance
    }()
    
    private var syncDeviceTimer:Timer?
    private var securedKey:String?
    
    func initateLoginRequest(authClient:VLAuthenticationClient, userDetails:[String:Any], callback: @escaping ((_ userIdentity:VLUserIdentity?, _ errorCode:VLAuthenticationErrorCode?) -> Void)) {
        self.triggerUserBeaconEvent(eventName: .loginInit, type: .viewlift, authType: .loginWithMobile)
        self.makeConnectionRequestToServer(eventName: .signin, callback: callback)
    }
    
    func initateSignUpRequest(authClient: VLAuthenticationClient, userDetails:[String:Any], callback: @escaping ((_ userIdentity:VLUserIdentity?, _ errorCode:VLAuthenticationErrorCode?) -> Void)) {
        self.triggerUserBeaconEvent(eventName: .signupInit, type: .viewlift, authType: .loginWithMobile)
        self.makeConnectionRequestToServer(eventName: .signup, callback: callback)
    }
    
    func verifyAuthenticationRequest(authClient: VLAuthenticationClient, userDetails:[String:Any], callback: @escaping ((_ userIdentity:VLUserIdentity?, _ errorCode:VLAuthenticationErrorCode?) -> Void)) {
        
    }
    
    func logout(authClient:VLAuthenticationClient, callback: @escaping ((_ logoutSuccessfully:Bool) ->())) {
        self.invokeLogoutRequest(requestType: .post) { logoutSuccessfully in
            if logoutSuccessfully{
                self.triggerUserBeaconEvent(eventName: .logout, type: .viewlift, authType: .loginWithMobile)
            }
            callback(logoutSuccessfully)
        }
    }
    
    func disconnectDeviceSync(authenticationClient:VLAuthenticationClient, callback: @escaping ((_ logoutSuccessful:Bool) ->())) {
        self.invalidateTimer()
        self.makeDisconnectRequestForMobileSignIn(callback: callback)
    }
}

#if os(iOS)
extension VLMobileAuthenticationClient {
    internal func approveConnectionRequest(userDetails:[String:String], callback: @escaping ((_ success:Bool, _ errorCode:VLAuthenticationErrorCode?) -> Void)) {
        let apiRequest = APIUrl.getAPIBaseUrl() + APIUrlEndPoint.mobileSignInApproveEndPoint.rawValue
		let requestBody = (["approve":true] as [String : Any]).merging(userDetails, uniquingKeysWith: {(_, new) in new})
        Task {
            do {
                let response = try await VLAPIService().makeDeviceConnectRequest(requestString: apiRequest, requestBody: requestBody, requestType: .post)
                guard response.success else {
                    return callback(false, .mobileConnectApproveFailed)
                }
                if let responseCode = response.mobileConnectObject?.code {
                    callback(false, VLAuthenticationErrorCode(rawValue: responseCode) ?? .mobileConnectApproveFailed)
                }
                else {
                    callback(true, nil)
                }
            }
            catch {
                callback(false, .mobileConnectApproveFailed)
            }
        }
    }
}
#endif

///Device connection and polling
extension VLMobileAuthenticationClient:VLMobileRequestBodyProtocol {
    
    private func makeConnectionRequestToServer(eventName: VLAuthenticationType, callback: @escaping ((_ userIdentity:VLUserIdentity?, _ errorCode:VLAuthenticationErrorCode?) -> Void)) {
        let apiRequest = APIUrl.getAPIBaseUrl() + APIUrlEndPoint.connectMobileSignInEndPoint.rawValue
        Task {
            do {
                let requestBody = self.getRequestBody()
                if let securedKey = requestBody?["key"] as? String {
                    self.securedKey = securedKey
                }
                let response = try await VLAPIService().makeDeviceConnectRequest(requestString: apiRequest, requestBody: requestBody, requestType: .post)
                guard response.success || response.mobileConnectObject?.code == "DEVICE_ALREADY_ACTIVE" else {
                    return callback (nil, .mobileSyncFailed)
                }
                self.proceedForDeviceSync(eventName: eventName, callback: callback)
            }
            catch {
                callback(nil, .mobileSyncFailed)
            }
        }
    }
    
    private func proceedForDeviceSync(eventName: VLAuthenticationType, callback: @escaping ((_ userIdentity:VLUserIdentity?, _ errorCode:VLAuthenticationErrorCode?) -> Void)) {
        self.pollDeviceActivationAPI(eventName: eventName, callback: callback)
        
        DispatchQueue.main.async {
            self.syncDeviceTimer = Timer.scheduledTimer(withTimeInterval: 10.0, repeats: true, block: { timer in
                self.pollDeviceActivationAPI(eventName: eventName, callback: callback)
            })
        }
    }
    
    private func pollDeviceActivationAPI(eventName: VLAuthenticationType, callback: @escaping ((_ userIdentity:VLUserIdentity?, _ errorCode:VLAuthenticationErrorCode?) -> Void)) {
        let apiRequest = APIUrl.getAPIBaseUrl() + APIUrlEndPoint.activateDeviceSyncEndPoint.rawValue + "?" + VLAPIRequestParamBuilder().getRequestParam()
        Task {
            do {
                let response = try await VLAPIService().makeAuthenticationRequestViaRestAPI(requestString: apiRequest, requestBody: nil, requestType: .get)
                guard response.1 == nil, (response.0?.errorMessage == nil && response.0?.errorCode == nil) else {
                    self.triggerUserBeaconEvent(eventName: eventName == .signup ? .signupFailure : .loginFailure, type: .viewlift, authType: .loginWithMobile)
                    return 
                }
                self.invalidateTimer()
                self.triggerUserBeaconEvent(eventName: eventName == .signup ? .signupSuccess : .loginSuccess, type: .viewlift, authType: .loginWithMobile, existingUser:response.0?.existingUser)
                callback(response.0, nil)
            }
            catch {
				self.invalidateTimer()
                self.triggerUserBeaconEvent(eventName: eventName == .signup ? .signupFailure : .loginFailure, type: .viewlift, authType: .loginWithMobile)
                callback(nil, .verificationFailed)
            }
        }
    }
    
    private func invalidateTimer() {
        if self.syncDeviceTimer != nil {
            self.syncDeviceTimer?.invalidate()
            self.syncDeviceTimer = nil
        }
    }
}

extension VLMobileAuthenticationClient {
    
    private func makeDisconnectRequestForMobileSignIn(callback: @escaping ((_ logoutSuccessful:Bool) ->())) {
        guard let securedKey else {return callback(false)}
        let apiRequest = APIUrl.getAPIBaseUrl() + APIUrlEndPoint.connectMobileSignInEndPoint.rawValue + "/\(securedKey)"
        Task {
            do {
                let response = try await VLAPIService().makeDeviceConnectRequest(requestString: apiRequest, requestBody: nil, requestType: .delete)
                guard response.success else {
                    return callback (false)
                }
                self.triggerUserBeaconEvent(eventName: .logout, type: .viewlift, authType: .loginWithMobile)
                callback(true)
            }
            catch {
                callback (false)
            }
        }
    }
}
