//
//  VLAPIService.swift
//  VLAuthentication
//
//  Created by Gaurav Vig on 25/11/22.
//

import Foundation

protocol VLAPIServiceProtocol {
    func makeAuthenticationRequest(requestString:String, requestBody:[String:Any]?, requestType:HTTPRequestType) async throws -> (VLGraphQLResponse?, VLAuthenticationErrorCode?)
    func makeOTPInitateRequest(requestString:String, requestBody:[String:Any]?, requestType:HTTPRequestType) async throws -> (VLGraphQLResponse?, VLAuthenticationErrorCode?)
    #if os(tvOS)
    func getDeviceCodeRequest(requestString:String, requestBody:[String:Any]?, requestType:HTTPRequestType) async throws -> (VLActivateCodeObject?, VLAuthenticationErrorCode?)
    #endif
}

protocol VLRestAPIService {
    func makeAuthenticationRequestViaRestAPI(requestString:String, requestBody:[String:Any]?, requestType:HTTPRequestType) async throws -> (VLUserIdentity?, VLAuthenticationErrorCode?)
	func makeOTPInitateRequestViaRestAPI(requestString:String, requestBody:[String:Any]?, requestType:HTTPRequestType) async throws -> (VLOTPResponseObject?, VLAuthenticationErrorCode?)
}

struct VLAPIService:VLAPIServiceProtocol, VLRestAPIService {
    
    func makeAuthenticationRequest(requestString:String, requestBody:[String:Any]?, requestType:HTTPRequestType) async throws -> (VLGraphQLResponse?, VLAuthenticationErrorCode?) {
        let networkResponse = try await NetworkRequest().makeNetworkRequest(requestString: requestString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? requestString, requestHeaders: createRequestHeaders(), requestBody: requestBody, requestType: requestType.rawValue)
        guard let data = networkResponse.0 else {
            return (nil, networkResponse.1)
        }
        do {
            let graphQLResponse = try JSONDecoder().decode(VLGraphQLResponse.self, from: data)
            return checkForErrorInGraphQLError(responseObject: graphQLResponse)
        }
        catch {
            return (nil, .verificationFailed)
        }
    }
    
    func makeAuthenticationRequestViaRestAPI(requestString: String, requestBody: [String : Any]?, requestType: HTTPRequestType) async throws -> (VLUserIdentity?, VLAuthenticationErrorCode?) {
        let networkResponse = try await NetworkRequest().makeNetworkRequest(requestString: requestString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? requestString, requestHeaders: createRequestHeaders(), requestBody: requestBody, requestType: requestType.rawValue)
        guard let data = networkResponse.0 else {
            return (nil, networkResponse.1)
        }
        do {
            let userIdentity = try JSONDecoder().decode(VLUserIdentity.self, from: data)
            return checkForErrorInUserIdentity(userIdentity: userIdentity)
        }
        catch {
            return (nil, .verificationFailed)
        }
    }
    
    func makeOTPInitateRequest(requestString:String, requestBody:[String:Any]?, requestType:HTTPRequestType) async throws -> (VLGraphQLResponse?, VLAuthenticationErrorCode?) {
        let networkResponse = try await NetworkRequest().makeNetworkRequest(requestString: requestString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? requestString, requestHeaders: createRequestHeaders(), requestBody: requestBody, requestType: requestType.rawValue)
        guard let data = networkResponse.0 else {
            return (nil, networkResponse.1)
        }
        do {
            let graphQLResponse = try JSONDecoder().decode(VLGraphQLResponse.self, from: data)
            return checkForErrorInGraphQLError(responseObject: graphQLResponse)
        }
        catch {
            return (nil, .incorrectCredentials)
        }
    }
	
	func makeOTPInitateRequestViaRestAPI(requestString:String, requestBody:[String:Any]?, requestType:HTTPRequestType) async throws -> (VLOTPResponseObject?, VLAuthenticationErrorCode?) {
		let networkResponse = try await NetworkRequest().makeNetworkRequest(requestString: requestString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? requestString, requestHeaders: createRequestHeaders(), requestBody: requestBody, requestType: requestType.rawValue)
		guard let data = networkResponse.0 else {
			return (nil, networkResponse.1)
		}
		do {
			let otpResponse = try JSONDecoder().decode(VLOTPResponseObject.self, from: data)
			return checkForErrorInOTPRequest(otpRequest: otpResponse)
		}
		catch {
			return (nil, .incorrectCredentials)
		}
	}
    
    func makeDeviceConnectRequest(requestString:String, requestBody:[String:Any]?, requestType:HTTPRequestType) async throws -> (success:Bool, mobileConnectObject:VLMobileConnectObject?) {
        let networkResponse = try await NetworkRequest().makeNetworkRequest(requestString: requestString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? requestString, requestHeaders: createRequestHeaders(), requestBody: requestBody, requestType: requestType.rawValue)
        guard let data = networkResponse.0 else {
            return (false, nil)
        }
        do {
            let response = try JSONDecoder().decode(VLMobileConnectObject.self, from: data)
            return (true, response)
        }
        catch {
            return (false, nil)
        }
    }
    
    #if os(tvOS)
    func getDeviceCodeRequest(requestString:String, requestBody:[String:Any]?, requestType:HTTPRequestType) async throws -> (VLActivateCodeObject?, VLAuthenticationErrorCode?) {
        let networkResponse = try await NetworkRequest().makeNetworkRequest(requestString: requestString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? requestString, requestHeaders: createRequestHeaders(), requestBody: requestBody, requestType: requestType.rawValue)
        guard let data = networkResponse.0 else {
            return (nil, networkResponse.1)
        }
        do {
            let activateCodeObj = try JSONDecoder().decode(VLActivateCodeObject.self, from: data)
            return (activateCodeObj, nil)
        }
        catch {
            return (nil, .errorInFetchingDeviceCode)
        }
    }
    #else
    func makeActivateDeviceViaCode(requestString: String, requestBody: [String : Any]?, requestType: HTTPRequestType) async throws -> (VLActivateDeviceResponse?, VLAuthenticationErrorCode?){
        let networkResponse = try await NetworkRequest().makeNetworkRequest(requestString: requestString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? requestString, requestHeaders: createRequestHeaders(), requestBody: requestBody, requestType: requestType.rawValue)
        guard let data = networkResponse.0 else {
            return (nil, networkResponse.1)
        }
        do {
            let responseObject = try JSONDecoder().decode(VLActivateDeviceResponse.self, from: data)
            return checkForErrorInDeviceActivation(responseObject: responseObject)
        }
        catch {
            return (nil, .noDataFound)
        }
    }
    #endif
}

extension VLAPIService {
    
    private func createRequestHeaders() -> [String:String] {
        var requestHeaders = ["Accept-Encoding": "gzip", "Content-Type": "application/json", "x-api-key": VLAuthentication.sharedInstance.xApiKey ?? "", "Accept":"application/json", "User-Agent": VLAuthenticationHelper.getUserAgent()]
        if let authToken = VLAuthentication.sharedInstance.authorizationToken {
            requestHeaders["Authorization"] = authToken
        }
        return requestHeaders
    }
    
    private func checkForErrorInUserIdentity(userIdentity:VLUserIdentity) -> (VLUserIdentity, VLAuthenticationErrorCode?) {
        guard let code = userIdentity.errorCode else {
            if userIdentity.errorMessage != nil {
                return (userIdentity, .verificationFailed)
            }
            else {
                return (userIdentity, nil)
            }
        }
        var errorCode:VLAuthenticationErrorCode = .noUserDetailsFound
        if let errorCodeValue = VLAuthenticationErrorCode(rawValue: code) {
            errorCode = errorCodeValue
        }
        return (userIdentity, errorCode)
    }
	
	private func checkForErrorInOTPRequest(otpRequest:VLOTPResponseObject) -> (VLOTPResponseObject, VLAuthenticationErrorCode?) {
		guard let code = otpRequest.error else {
			return (otpRequest, nil)
		}
		var errorCode:VLAuthenticationErrorCode = .verificationFailed
		if let errorCodeValue = VLAuthenticationErrorCode(rawValue: code) {
			errorCode = errorCodeValue
		}
		return (otpRequest, errorCode)
	}
    
    private func checkForErrorInGraphQLError(responseObject:VLGraphQLResponse) -> (VLGraphQLResponse, VLAuthenticationErrorCode?) {
        guard let errors = responseObject.errors, errors.count > 0 else {
            return (responseObject, nil)
        }
        guard let code = errors[0].extensions?.code else {
            if errors[0].message != nil {
                return (responseObject, .verificationFailed)
            }
            else {
                return (responseObject, nil)
            }
        }
        var errorCode:VLAuthenticationErrorCode = .verificationFailed
        if let errorCodeValue = VLAuthenticationErrorCode(rawValue: code) {
            errorCode = errorCodeValue
        }
        return (responseObject, errorCode)
    }
    
    #if os(iOS)
    private func checkForErrorInDeviceActivation(responseObject:VLActivateDeviceResponse) -> (VLActivateDeviceResponse, VLAuthenticationErrorCode?) {
        guard let code = responseObject.code else {
            if responseObject.errorMessage != nil {
                return (responseObject, .verificationFailed)
            }
            else {
                return (responseObject, nil)
            }
        }
        var errorCode:VLAuthenticationErrorCode = .noDataFound
        if let errorCodeValue = VLAuthenticationErrorCode(rawValue: code) {
            errorCode = errorCodeValue
        }
        return (responseObject, errorCode)
    }
    #endif
}
