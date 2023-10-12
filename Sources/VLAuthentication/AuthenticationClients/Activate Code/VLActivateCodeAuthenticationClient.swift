//
//  VLActivateCodeAuthenticationClient.swift
//  VLAuthenticationLib
//
//  Created by Gaurav Vig on 25/11/22.
//

import UIKit

final class VLActivateCodeAuthenticationClient:VLAuthenticationProtocol, VLAuthenticationDeviceSyncProtocol, VLAuthLogoutProtocol, VLBeaconEventTriggerProtocol {
    
    static let sharedInstance:VLActivateCodeAuthenticationClient = {
        let instance = VLActivateCodeAuthenticationClient()
        return instance
    }()
    
    internal var activateDeviceCodeDelegate: VLActivateDeviceCodeDelegate?
    private var syncDeviceTimer:Timer?
    internal var activationUrl:String?
    private var authClient:VLAuthenticationClient = .activateCode
    
    func initateLoginRequest(authClient:VLAuthenticationClient, userDetails:[String:Any], callback: @escaping ((_ userIdentity:VLUserIdentity?, _ errorCode:VLAuthenticationErrorCode?) -> Void)) {
        self.authClient = authClient
        self.triggerUserBeaconEvent(eventName: .loginInit, type: .viewlift, authType: .activateDevice)
        self.getDeviceActivationCode(userDetails: userDetails, callback: callback)
    }
    
    func initateSignUpRequest(authClient: VLAuthenticationClient, userDetails:[String:Any], callback: @escaping ((_ userIdentity:VLUserIdentity?, _ errorCode:VLAuthenticationErrorCode?) -> Void)) {
        self.triggerUserBeaconEvent(eventName: .signupInit, type: .viewlift, authType: .activateDevice)
        self.getDeviceActivationCode(userDetails: userDetails, callback: callback)
    }
    
    func verifyAuthenticationRequest(authClient: VLAuthenticationClient, userDetails:[String:Any], callback: @escaping ((_ userIdentity:VLUserIdentity?, _ errorCode:VLAuthenticationErrorCode?) -> Void)) {
        
    }
    
    func logout(authClient:VLAuthenticationClient, callback: @escaping ((_ logoutSuccessfully:Bool) ->())) {
        self.authClient = authClient
        self.invokeLogoutRequest(requestType: .delete, requestEndPoint: APIUrlEndPoint.deviceDesyncEndPoint.rawValue + "?" + VLAPIRequestParamBuilder().getRequestParam()) { logoutSuccessfully in
            if logoutSuccessfully{
                self.triggerUserBeaconEvent(eventName: .logout, type: .viewlift, authType: .activateDevice)
            }
            callback(logoutSuccessfully)
        }
    }
    
    func disconnectDeviceSync(authenticationClient:VLAuthenticationClient, callback: @escaping ((_ logoutSuccessful:Bool) ->())) {
        self.invalidateTimer()
    }
}


extension VLActivateCodeAuthenticationClient {

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
                callback(nil, .errorInFetchingDeviceCode)
            }
        }
    }
    
    private func syncDeviceViaActivationCode(activationCode:String, userDetails:[String:Any], callback: @escaping ((_ userIdentity:VLUserIdentity?, _ errorCode:VLAuthenticationErrorCode?) -> Void)) {
        self.setCallbackForActivationCode(activationCode: activationCode)
        self.proceedForDeviceSync(activationCode: activationCode, userDetails: userDetails, callback: callback)
    }
    
    private func setCallbackForActivationCode(activationCode:String) {
        switch authClient {
        case .activateCode:
            if let activateDeviceCodeDelegate {
                activateDeviceCodeDelegate.deviceActivationCode?(activationCode: activationCode)
            }
        case .qrcode:
            if let qrImage = generateQRCode(activationCode: activationCode) {
                if let activateDeviceCodeDelegate {
                    activateDeviceCodeDelegate.deviceQRCode?(qrCode: qrImage)
                }
            }
            break
        case .activateCodeWithQRCode:
            if let qrImage = generateQRCode(activationCode: activationCode) {
                if let activateDeviceCodeDelegate {
                    activateDeviceCodeDelegate.deviceActivationAndQRCode?(activationCode: activationCode, qrCode: qrImage)
                }
            }
            else {
                if let activateDeviceCodeDelegate {
                    activateDeviceCodeDelegate.deviceActivationCode?(activationCode: activationCode)
                }
            }
            break
        default:
            break
        }
    }
    
    private func proceedForDeviceSync(activationCode:String, userDetails:[String:Any], callback: @escaping ((_ userIdentity:VLUserIdentity?, _ errorCode:VLAuthenticationErrorCode?) -> Void)) {
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
                let response = try await VLAPIService().makeAuthenticationRequestViaRestAPI(requestString: apiRequest, requestBody: userDetails, requestType: .get)
                guard response.1 == nil, (response.0?.errorMessage == nil && response.0?.errorCode == nil) else {
                    self.triggerUserBeaconEvent(eventName: .loginFailure, type: .viewlift, authType: .activateDevice)
                    return
                }
                self.invalidateTimer()
                self.triggerUserBeaconEvent(eventName: .loginSuccess, type: .viewlift, authType: .activateDevice, existingUser: response.0?.existingUser)
                callback(response.0, nil)
            }
            catch {
				self.invalidateTimer()
                self.triggerUserBeaconEvent(eventName: .loginFailure, type: .viewlift, authType: .activateDevice)
                callback(nil, .verificationFailed)
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

extension VLActivateCodeAuthenticationClient {
    
    private func generateQRCode(activationCode:String) -> UIImage? {
        guard let activationUrl else { return nil }
        return QRCodeGenerator().generateQRCode(activationUrl: activationUrl, activationCode: activationCode)
    }
}
