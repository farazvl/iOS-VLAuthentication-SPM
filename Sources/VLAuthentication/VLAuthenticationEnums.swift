//
//  VLAuthenticationTypes.swift
//  VLAuthenticationLib
//
//  Created by Gaurav Vig on 25/11/22.
//

/**
 - Important:
 Type of authentication client supported
 
 - Remark:
 This will having constants variables
 
 - Variables:
    - email: Email sign in and sign up
    - facebook: Facebook sign in and Sign up
    - google: Google sign in and Sign up
    - apple: Apple sign in and Sign up
    - qrcode: QRCode authentication
    - otp: OTP sign in and Sign up
    - activateCode: Activate code authenticaiton
    - mobile: Sign in using mobile
    - tvProvider: TVE Sign in
 */
@frozen public enum VLAuthenticationClient:Equatable {
    case emailWithPassword
    case emailWithOtp
    case facebook
    case google
    case apple
    case qrcode
    case otp
    case activateCode
    case mobile
    case tvProvider(provider: TVProvider?)
    case activateCodeWithQRCode
    case restorePurchaseSignIn
    case activateDeviceViaCode
    
    public enum TVProvider {
        case adobe
        case verimatrix
    }
    
    static public func == (_ lhs:VLAuthenticationClient, _ rhs: VLAuthenticationClient) -> Bool {
        switch (lhs,rhs) {
        case (.tvProvider(let a), .tvProvider(let b)):
            return a == b
        case (.emailWithPassword, .emailWithPassword), (.emailWithOtp, .emailWithOtp), (.facebook, .facebook), (.google, .google), (.apple, .apple), (.qrcode, .qrcode), (.otp, .otp), (.activateCode, .activateCode), (.mobile, .mobile), (.activateCodeWithQRCode, .activateCodeWithQRCode) , (.activateDeviceViaCode , .activateDeviceViaCode) :
            return true
        default:
            return false
        }
    }
}

/**
 - Important:
 Type of authentication
 */
@frozen public enum VLAuthenticationType {
    case signin
    case signup
    case verify
//    case logout
    case disconnect
//    case delete
}

@frozen public enum VLOTPVerificationType {
    case verify
    case resend
}

/**
 - Important:
 Enum.with api environment
 */
@frozen public enum VLAuthenticationAPIEnvironment {
    case prod
    case staging
}

public enum VLAuthenticationErrorCode:String {
    case invalidSiteDetails = "SITE_MISSING"
    case invalidRequestUrl
	case internalError = "INTERNAL_ERROR"
    case noDataFound = "NOT_FOUND"
    case noUserDetailsFound
    case invalidEmailId = "EMAIL_NOT_VALID"
    case invalidPhoneNumber = "PHONE_NOT_VALID"
	case notValidOTP = "OTP_NOT_VALID"
	case otpSendingFailed = "OTP_SENT_FAILED"
	case invalidPhone = "PHONE_INVALID"
    case invalidCredentials = "EMAIL_OR_PHONE_NOT_VALID"
    case incorrectCredentials = "EMAIL_OR_PASSWORD_INCORRECT"
	case unverifiedPhone = "UNVERIFIED_PHONE"
	case unverifiedEmail = "UNVERIFIED_EMAIL"
    case verificationFailed
    case authenticationTokenExpired
    case deviceLimitExceeded = "DEVICE_LIMIT_EXCEEDED" 
    case emailNotRegistered = "EMAIL_NOT_REGISTERED"
    case emailAlreadyLinked = "EMAIL_ALREADY_LINKED"
    case mobileAlreadyRegistered
    case errorInFetchingDeviceCode
    case facebookAuthenticationFailed
    case missingFacebookConfiguration
    case googleAuthenticationFailed
    case missingGoogleConfiguration
    case missingPresentingView
    case otpDelegateNotRegistered
    case otpExpired = "OTP_EXPIRED"
    case maxNumberOfOTPExceeded = "MAX_NUMBER_OF_OTP_EXCEEDED"
    case maxOTPVerficationExceeded = "MAX_NUMBER_OF_OTP_VERIFY_ATTEMP_EXCEEDED"
    case invalidOTP = "OTP_MISMATCH"
    case crossCountryPhone = "CROSS_COUNTRY_PHONE"
    case appleAuthenticationFailed
    case appleAuthenticationCancelled
    case mobileSyncFailed
    case mobileConnectApproveFailed
    case mobileConnectRequestExpired = "TV_CONNECT_REQUEST_EXPIRED"
    case mobileConnectRequestRejected = "TV_CONNECT_REQUEST_ALREADY_REJECTED"
    case mobileConnectAlreadyApproved = "TV_CONNECT_REQUEST_ALREADY_APPROVED"
    
    case deviceActivationQRInvalid = "NOT_VALID_ACTIVATION_CODE"
    case deviceActivationQRInvalidParams = "INVALID_PARAMS"
    
}

enum HTTPRequestType:String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
}
