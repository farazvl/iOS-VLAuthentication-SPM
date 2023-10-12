//
//  VLAPIEnums.swift
//  VLAuthentication
//
//  Created by Gaurav Vig on 08/12/22.
//

enum APIUrl {
    static func getAPIBaseUrl() -> String {
        return VLAuthenticationInternal.sharedInstance.apiUrl ?? ""
    }
}

enum APIUrlEndPoint:String {
    case signinEndPoint = "/identity/signin"
    case signupEndPoint = "/identity/signup"
    case facebookSigninEndPoint = "/identity/signin/facebook"
    case googleSigninEndPoint = "/identity/signin/google"
    case emailLogoutEndPoint = "/identity/signout"
    case appleSigninEndPoint = "/identity/signin/apple"
    case activateCodeEndPoint = "/user/device/code"
    case activateDeviceSyncEndPoint = "/user/device/details"
    case deviceDesyncEndPoint = "/user/device/desync"
    case initiateAuthOtpEndPoint = "/identity/authOtp/initiate"
    case validateAuthOtpEndPoint = "/identity/authOtp/validate"
    case tveSignInEndpoint = "/identity/signin/tve"
    case restorePurchaseSignInEndPoint = "/identity/signin/ios"
    case connectMobileSignInEndPoint = "/v2/identity/auth/connect"
    case disconnectMobileSignInEndPoint = "/v2/identity/auth/disconnect"
    case mobileSignInApproveEndPoint = "/v2/identity/auth/connect/approve"
    case activateDeviceByCodeEndPoint =  "/user/device/sync"
    case graphQLEndPoint = "/graphql"
	case verifyMobileNumber = "/v2/identity/phoneNumber/initiate"
	case verifyEmailId = "/v2/identity/email/initiate"
	case validateMobileNumber = "/v2/identity/phoneNumber/validate"
	case validateEmailId = "/v2/identity/email/validate"
}

