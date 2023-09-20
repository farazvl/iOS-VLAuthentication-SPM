//
//  VLOTPAuthenticationClient.swift
//  VLAuthenticationLib
//
//  Created by Gaurav Vig on 25/11/22.
//

import UIKit

final class VLOTPAuthenticationClient:VLAuthenticationProtocol, VLAuthLogoutProtocol, VLBeaconEventTriggerProtocol {
    
    static let sharedInstance:VLOTPAuthenticationClient = {
        let instance = VLOTPAuthenticationClient()
        return instance
    }()
    
    internal var otpVerificationDelegate: VLOTPAuthenticationDelegate?
    private var authClient:VLAuthenticationClient = .otp
    
    func initateLoginRequest(authClient:VLAuthenticationClient, userDetails:[String:Any], callback: @escaping ((_ userIdentity:VLUserIdentity?, _ errorCode:VLAuthenticationErrorCode?) -> Void)) {
        self.authClient = authClient
        self.triggerUserBeaconEvent(eventName: .loginInit, type: .viewlift, authType: authClient == .emailWithOtp ? .email : .phoneNo)
        self.makeLoginRequest(userDetails: userDetails, eventName: .signin, callback: callback)
    }
    
    func initateSignUpRequest(authClient: VLAuthenticationClient, userDetails:[String:Any], callback: @escaping ((_ userIdentity:VLUserIdentity?, _ errorCode:VLAuthenticationErrorCode?) -> Void)) {
        self.authClient = authClient
        self.triggerUserBeaconEvent(eventName: .signupInit, type: .viewlift, authType: authClient == .emailWithOtp ? .email : .phoneNo)
        self.makeLoginRequest(userDetails: userDetails, eventName: .signup, callback: callback)
    }
    
    func verifyAuthenticationRequest(authClient: VLAuthenticationClient, userDetails:[String:Any], callback: @escaping ((_ userIdentity:VLUserIdentity?, _ errorCode:VLAuthenticationErrorCode?) -> Void)) {
		self.authClient = authClient
		self.verifyUserDetails(userDetails: userDetails, callback: callback)
    }
    
    func logout(authClient:VLAuthenticationClient, callback: @escaping ((_ logoutSuccessfully:Bool) ->())) {
        self.invokeLogoutRequest(requestType: .post) { logoutSuccessfully in
            if logoutSuccessfully {
                self.triggerUserBeaconEvent(eventName: .logout, type: .viewlift, authType: authClient == .emailWithOtp ? .email : .phoneNo)
            }
            callback(logoutSuccessfully)
        }
    }
}

extension VLOTPAuthenticationClient {
    
    private func makeLoginRequest(userDetails:[String:Any], eventName: VLAuthenticationType? = nil, otpType: VLOTPVerificationType? = nil, callback: @escaping ((_ userIdentity:VLUserIdentity?, _ errorCode:VLAuthenticationErrorCode?) -> Void)) {
        let apiRequest = APIUrl.getAPIBaseUrl() + APIUrlEndPoint.graphQLEndPoint.rawValue
        let query = VLGraphQLQueryGenerator().createQuery(for: .otpInitiate, graphQLQuery: VLOTPGraphQLQuery())
        let _userDetails = getUpdatedUserDetails(userDetails: userDetails)
        let variables = VLGraphQLVariableBuilder(customVariable: _userDetails).getGraphQLVariables()
        let requestBody:[String:Any] = ["query": query, "variables": variables]
        Task {
            do {
                let loginResponse = try await VLAPIService().makeOTPInitateRequest(requestString: apiRequest, requestBody: requestBody, requestType: .post)
                guard loginResponse.1 == nil, let loginResponseObj = loginResponse.0?.data?.identityInitiateSignOtp else {
                    self.triggerUserBeaconEvent(eventName: eventName == .signup ? .signupFailure : .loginFailure, type: .viewlift, authType: authClient == .emailWithOtp ? .email : .phoneNo)
                    callback(nil, loginResponse.1)
                    return
                }
                
                if let eventName{
                    self.triggerUserBeaconEvent(eventName: eventName == .signup ? .signupSuccess : .loginSuccess, type: .viewlift, authType: authClient == .emailWithOtp ? .email : .phoneNo)
                } else if let otpType {
                    self.triggerUserBeaconEvent(eventName: otpType == .resend ? .resendVerificationCode : .getVerificationCode, type: .viewlift, authType: authClient == .emailWithOtp ? .email : .phoneNo)
                }
                
                self.proceedForOTPVerification(responseObj: loginResponseObj, userDetails: userDetails, callback: callback)
            }
            catch {
                self.triggerUserBeaconEvent(eventName: eventName == .signup ? .signupFailure : .loginFailure, type: .viewlift, authType: authClient == .emailWithOtp ? .email : .phoneNo)
                callback(nil, .verificationFailed)
            }
        }
    }
    
    private func getUpdatedUserDetails(userDetails:[String:Any]) -> [String:Any] {
        
        var _userDetails = userDetails.filter({$0.key == "email" || $0.key == "phoneNumber"})
        if let token = VLAuthentication.sharedInstance.authorizationToken {
            _userDetails["deviceId"] = JWTTokenParser().jwtTokenParser(jwtToken: token)?.deviceId
        }
        else {
            _userDetails["deviceId"] = VLAuthenticationHelper.getUUID()
        }
        _userDetails["deviceName"] = UIDevice.current.name
#if os(iOS)
		if UIDevice.current.userInterfaceIdiom == UIUserInterfaceIdiom.pad {
			_userDetails["platform"] = "ios_ipad"
		}
		else {
			_userDetails["platform"] = "ios_phone"
		}
#else
		_userDetails["platform"] = "ios_apple_tv"
#endif
        
        return _userDetails
    }
    
    private func proceedForOTPVerification(responseObj:VLOTPResponseObject, userDetails:[String:Any], callback: @escaping ((_ userIdentity:VLUserIdentity?, _ errorCode:VLAuthenticationErrorCode?) -> Void)) {
        guard let otpVerificationDelegate else {
            callback(nil, .otpDelegateNotRegistered)
            return
        }
        self.triggerUserBeaconEvent(eventName: .getVerificationCode, type: .viewlift, authType: authClient == .emailWithOtp ? .email : .phoneNo)
        var _userDetails:[String:Any] = userDetails
        do {
            let encodedResponseData = try JSONEncoder().encode(responseObj)
            if let encodedResponseDict = try JSONSerialization.jsonObject(with: encodedResponseData) as? [String:Any] {
                _userDetails = encodedResponseDict
            }
        }
        catch {
        }
        otpVerificationDelegate.otpVerification { verificationType, otp in
            if verificationType == .verify {
                self.verifyOTP(userDetails: _userDetails, otp: otp, callback: callback)
            }
            else if verificationType == .resend {
                self.resendOTP(userDetails:userDetails, callback: callback)
            }
        }
    }
}

extension VLOTPAuthenticationClient {
    
    private func verifyOTP(userDetails:[String:Any], otp:String?, callback: @escaping ((_ userIdentity:VLUserIdentity?, _ errorCode:VLAuthenticationErrorCode?) -> Void)) {
        guard let otp else {
            callback(nil, .invalidOTP)
            return
        }
        let apiRequest = APIUrl.getAPIBaseUrl() + APIUrlEndPoint.graphQLEndPoint.rawValue
        let query = VLGraphQLQueryGenerator().createQuery(for: .otpValidate, graphQLQuery: VLOTPGraphQLQuery())
        let _verifyParams = ["otpValue":otp].merging(userDetails, uniquingKeysWith: {(_, new) in new})
        let inputVariables = VLGraphQLInputVariableBuilder().getGraphQLInputVariables(customVariable: _verifyParams)
        let variables = VLGraphQLVariableBuilder(customVariable: inputVariables).getGraphQLVariables()
        let requestBody:[String:Any] = ["query": query, "variables": variables]
        Task {
            do {
                let loginResponse = try await VLAPIService().makeAuthenticationRequest(requestString: apiRequest, requestBody: requestBody, requestType: .post)
                self.triggerUserBeaconEvent(eventName: .submitVerificationCode, type: .viewlift, authType: authClient == .emailWithOtp ? .email : .phoneNo)
                guard loginResponse.1 == nil, let loginResponseObj = loginResponse.0?.data?.identitySignOtpPasswordless else {
                    self.triggerUserBeaconEvent(eventName: .loginFailure, type: .viewlift, authType: authClient == .emailWithOtp ? .email : .phoneNo)
                    callback(nil,loginResponse.1)
                    return
                }
                self.triggerUserBeaconEvent(eventName: .loginSuccess, type: .viewlift, authType: authClient == .emailWithOtp ? .email : .phoneNo, existingUser: loginResponseObj.existingUser)
                callback(loginResponseObj, loginResponse.1)
            }
            catch {
                self.triggerUserBeaconEvent(eventName: .loginFailure, type: .viewlift, authType: authClient == .emailWithOtp ? .email : .phoneNo)
                callback(nil, .verificationFailed)
            }
        }
    }
    
    private func resendOTP(userDetails:[String:Any], callback: @escaping ((_ userIdentity:VLUserIdentity?, _ errorCode:VLAuthenticationErrorCode?) -> Void)) {
        self.triggerUserBeaconEvent(eventName: .resendVerificationCode, type: .viewlift, authType: authClient == .emailWithOtp ? .email : .phoneNo)
        self.makeLoginRequest(userDetails: userDetails, otpType: .resend, callback: callback)
    }
}

extension VLOTPAuthenticationClient {
	
	private func verifyUserDetails(userDetails:[String:Any], callback: @escaping ((_ userIdentity:VLUserIdentity?, _ errorCode:VLAuthenticationErrorCode?) -> Void)) {
		let apiRequest = APIUrl.getAPIBaseUrl() + (authClient == .emailWithOtp ? APIUrlEndPoint.verifyEmailId.rawValue : APIUrlEndPoint.verifyMobileNumber.rawValue)
		Task {
			do {
				let response = try await VLAPIService().makeOTPInitateRequestViaRestAPI(requestString: apiRequest, requestBody: userDetails, requestType: .put)
				guard response.1 == nil, let responseObj = response.0 else {
					callback(nil, response.1)
					return
				}
				self.proceedForOTPValidation(responseObj: responseObj, userDetails: userDetails, callback: callback)
			}
			catch {
				callback(nil, .verificationFailed)
			}
		}
	}
	
	private func proceedForOTPValidation(responseObj:VLOTPResponseObject, userDetails:[String:Any], callback: @escaping ((_ userIdentity:VLUserIdentity?, _ errorCode:VLAuthenticationErrorCode?) -> Void)) {
		guard let otpVerificationDelegate else {
			callback(nil, .otpDelegateNotRegistered)
			return
		}
		var _userDetails:[String:Any] = userDetails
		do {
			let encodedResponseData = try JSONEncoder().encode(responseObj)
			if let encodedResponseDict = try JSONSerialization.jsonObject(with: encodedResponseData) as? [String:Any] {
				_userDetails = encodedResponseDict
			}
		}
		catch {
		}
		otpVerificationDelegate.otpVerification { verificationType, otp in
			if verificationType == .verify {
				self.validateOTP(userDetails: _userDetails, otp: otp, callback: callback)
			}
			else if verificationType == .resend {
				self.resendOTPVerification(userDetails:userDetails, callback: callback)
			}
		}
	}
	
	private func validateOTP(userDetails:[String:Any], otp:String?, callback: @escaping ((_ userIdentity:VLUserIdentity?, _ errorCode:VLAuthenticationErrorCode?) -> Void)) {
		guard let otp else {
			callback(nil, .invalidOTP)
			return
		}
		let apiRequest = APIUrl.getAPIBaseUrl() + (authClient == .emailWithOtp ? APIUrlEndPoint.validateEmailId.rawValue : APIUrlEndPoint.validateMobileNumber.rawValue)
		let _verifyParams = ["otp":otp].merging(userDetails, uniquingKeysWith: {(_, new) in new})
		Task {
			do {
				let loginResponse = try await VLAPIService().makeAuthenticationRequestViaRestAPI(requestString: apiRequest, requestBody: _verifyParams, requestType: .put)
				guard loginResponse.1 == nil, let loginResponseObj = loginResponse.0 else {
					callback(nil, loginResponse.1)
					return
				}
				callback(loginResponseObj, loginResponse.1)
			}
			catch {
				callback(nil, .verificationFailed)
			}
		}
	}
	
	private func resendOTPVerification(userDetails:[String:Any], callback: @escaping ((_ userIdentity:VLUserIdentity?, _ errorCode:VLAuthenticationErrorCode?) -> Void)) {
		self.verifyUserDetails(userDetails: userDetails, callback: callback)
	}
}
