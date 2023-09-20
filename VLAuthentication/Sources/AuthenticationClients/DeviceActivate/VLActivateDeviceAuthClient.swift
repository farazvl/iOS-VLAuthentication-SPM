//
//  VLActivateDeviceByQR.swift
//  VLAuthenticationLib
//
//  Created by NexG on 27/03/23.
//

import Foundation

final class VLActivateDeviceAuthClient: VLAuthLogoutProtocol, VLBeaconEventTriggerProtocol {
    
    static let sharedInstance:VLActivateDeviceAuthClient = {
        let instance = VLActivateDeviceAuthClient()
        return instance
    }()
    
    func initateDeviceActivationRequest(authClient: VLAuthenticationClient, userDetails: [String : Any], callback: @escaping ((_ success:Bool?, VLAuthenticationErrorCode?) -> Void)) {
        self.triggerUserBeaconEvent(eventName: .loginInit, type: .viewlift, authType: .custom(eventName: "qr-code"))
        self.activateDeviceViaCodeServiceCall(userDetails: userDetails , callback: callback)
    }

    func logout(authClient: VLAuthenticationClient, callback: @escaping ((Bool) -> ())) {
        self.invokeLogoutRequest(requestType: .post) { logoutSuccessfully in
            if logoutSuccessfully {
                self.triggerUserBeaconEvent(eventName: .logout, type: .tve, authType: .activateDevice)
            }
            callback(logoutSuccessfully)
        }
    }
}

extension VLActivateDeviceAuthClient {
    private func activateDeviceViaCodeServiceCall(userDetails: [String : Any] , callback: @escaping ((_ success:Bool?, _ errorCode:VLAuthenticationErrorCode?) -> Void)) {
        let apiRequest = APIUrl.getAPIBaseUrl() + APIUrlEndPoint.activateDeviceByCodeEndPoint.rawValue + "?" + VLAPIRequestParamBuilder().getSiteAsParam()
        var requestBodyParams = userDetails
        if let token = VLAuthentication.sharedInstance.authorizationToken,
           let userId = JWTTokenParser().jwtTokenParser(jwtToken: token)?.userId {
            requestBodyParams["userId"] = userId
        }
        let _requestBodyParams = requestBodyParams
        Task {
            do {
                let response = try await VLAPIService().makeActivateDeviceViaCode(requestString: apiRequest, requestBody: _requestBodyParams, requestType: .post)
                if (response.0?.code) != nil {
                    self.triggerUserBeaconEvent(eventName: .loginFailure, type: .tve, authType: .activateDevice)
                    callback(false, VLAuthenticationErrorCode(rawValue: response.0?.errorMessage ?? ""))
                }else{
                    self.triggerUserBeaconEvent(eventName: .loginSuccess, type: .tve, authType: .activateDevice)
                    callback(true, nil)
                }
            }
            catch {
                self.triggerUserBeaconEvent(eventName: .loginFailure, type: .tve, authType: .activateDevice)
                callback(false, .noDataFound)
            }
        }
    }
}
