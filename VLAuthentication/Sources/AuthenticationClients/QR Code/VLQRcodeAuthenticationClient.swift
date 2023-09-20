//
//  VLQRcodeAuthenticationClient.swift
//  VLAuthenticationLib
//
//  Created by Gaurav Vig on 25/11/22.
//

import Foundation

final class VLQRcodeAuthenticationClient:VLAuthenticationProtocol {
    
    static let sharedInstance:VLQRcodeAuthenticationClient = {
        let instance = VLQRcodeAuthenticationClient()
        return instance
    }()
    
    internal var activateDeviceCodeDelegate: VLActivateDeviceCodeDelegate?
    private var syncDeviceTimer:Timer?

    func initateLoginRequest(userDetails:[String:Any], callback: @escaping ((_ userIdentity:VLUserIdentity?, _ errorCode:VLAuthenticationErrorCode?) -> Void)) {
        
    }
    
    func initateSignUpRequest(userDetails:[String:Any], callback: @escaping ((_ userIdentity:VLUserIdentity?, _ errorCode:VLAuthenticationErrorCode?) -> Void)) {
        
    }
    
    func verifyAuthenticationRequest(userDetails:[String:Any]) {
        
    }
    
    func logout(callback: @escaping ((_ logoutSuccessfully:Bool) ->())) {
        
    }
}

extension VLQRcodeAuthenticationClient {
    private func getDeviceActivationCode(userDetails:[String:Any], callback: @escaping ((_ userIdentity:VLUserIdentity?, _ errorCode:VLAuthenticationErrorCode?) -> Void)) {
        self.invalidateTimer()
        let apiRequest = APIUrl.getAPIBaseUrl() + APIUrlEndPoint.activateCodeEndPoint.rawValue + "?" + VLAPIRequestParamBuilder().getRequestParam()
        Task {
            do {
                let response = try await VLAPIService().getDeviceCodeRequest(requestString: apiRequest, requestBody: userDetails, requestType: .get)
                if let activationCode = response.0?.activationCode {
                    self.syncDeviceViaActivationCode(activationCode: activationCode, userDetails: userDetails, callback: callback)
                }
                else {
                    callback(nil, .errorInFetchingDeviceCode)
                }
            }
            catch {
                callback(nil, .noUserDetailsFound)
            }
        }
    }
    
    private func syncDeviceViaActivationCode(activationCode:String, userDetails:[String:Any], callback: @escaping ((_ userIdentity:VLUserIdentity?, _ errorCode:VLAuthenticationErrorCode?) -> Void)) {
        if let activateDeviceCodeDelegate {
            activateDeviceCodeDelegate.deviceActivationCode(activationCode: activationCode)
        }
        self.pollDeviceActivationAPI(userDetails: userDetails, callback: callback)
        
        DispatchQueue.main.async {
            self.syncDeviceTimer = Timer.scheduledTimer(withTimeInterval: 10.0, repeats: true, block: { timer in
                self.pollDeviceActivationAPI(userDetails: userDetails, callback: callback)
            })
        }
    }
    
    private func pollDeviceActivationAPI(userDetails:[String:Any], callback: @escaping ((_ userIdentity:VLUserIdentity?, _ errorCode:VLAuthenticationErrorCode?) -> Void)) {
        let apiRequest = APIUrl.getAPIBaseUrl() + APIUrlEndPoint.activateDeviceSyncEndPoint.rawValue + "?" + VLAPIRequestParamBuilder().getRequestParam()
        Task {
            do {
                let response = try await VLAPIService().makeAuthenticationRequest(requestString: apiRequest, requestBody: userDetails, requestType: .get)
                guard response.1 == nil, (response.0?.error == nil && response.0?.code == nil) else {
                    return
                }
                self.invalidateTimer()
                callback(response.0, nil)
            }
            catch {
                callback(nil, .noUserDetailsFound)
            }
        }
    }
    
    private func invalidateTimer() {
        if syncDeviceTimer != nil {
            syncDeviceTimer?.invalidate()
            syncDeviceTimer = nil
        }
    }
}
