//
//  VLAuthentication.swift
//  VLAuthentication
//
//  Created by Gaurav Vig on 25/11/22.
//

import Foundation
import UIKit
import VLBeacon

public class VLAuthentication {
    
    static public let sharedInstance:VLAuthentication = {
        let instance = VLAuthentication()
        return instance
    }()
        
    public var xApiKey:String?
    public var authorizationToken:String? {
        didSet {
            guard let authorizationToken else { return }
            self.siteName = JWTTokenParser().jwtTokenParser(jwtToken: authorizationToken)?.siteName
            VLBeacon.sharedInstance.authorizationToken = authorizationToken
        }
    }
    
    private weak var _otpVerificationDelegate: VLOTPAuthenticationDelegate?
    public weak var otpVerificationDelegate: VLOTPAuthenticationDelegate? {
        get {
            return _otpVerificationDelegate
        }
        set {
            _otpVerificationDelegate = newValue
            VLOTPAuthenticationClient.sharedInstance.otpVerificationDelegate = _otpVerificationDelegate
        }
    }
    
    public var debugLogs : Bool? {
        didSet{
            guard let debugLogs else { return }
            VLBeacon.sharedInstance.debugLogs = debugLogs
        }
    }
    
    #if os(tvOS)
    private weak var _activateDeviceCodeDelegate: VLActivateDeviceCodeDelegate?
    public weak var activateDeviceCodeDelegate: VLActivateDeviceCodeDelegate? {
        get {
            return _activateDeviceCodeDelegate
        }
        set {
            _activateDeviceCodeDelegate = newValue
            VLActivateCodeAuthenticationClient.sharedInstance.activateDeviceCodeDelegate = _activateDeviceCodeDelegate
        }
    }
    #endif
    
    private(set) internal var siteName:String?
    internal var presentingViewController:UIViewController?
    
    private var supportedAuthenticationMethods:[VLAuthenticationClient] = []
    
    public func initialiseSDK(with authClientSupported:[VLAuthenticationClient], on presentingViewController:UIViewController) {
        self.presentingViewController = presentingViewController
    }
    
    public func initiateAuthentication(authenticationType:VLAuthenticationType, authenticationObject:VLAuthenticationObject?, authenticationClient:VLAuthenticationClient, presentingViewController:UIViewController?, callback: @escaping ((_ userIdentity:VLUserIdentity?, _ errorCode:VLAuthenticationErrorCode?) -> Void)) {
        self.presentingViewController = presentingViewController
        VLAuthenticationInternal.sharedInstance.initiateAuthentication(authenticationType: authenticationType, authenticationObject: authenticationObject, authenticationClient: authenticationClient, callback: callback)
    }
    
    #if os(tvOS)
    public func initiateAuthenticateUsingDeviceCode(authenticationType:VLAuthenticationType, activateDeviceUrl:String, authenticationObject:VLAuthenticationObject?, authenticationClient:VLAuthenticationClient, presentingViewController:UIViewController?, callback: @escaping ((_ userIdentity:VLUserIdentity?, _ errorCode:VLAuthenticationErrorCode?) -> Void)) {
        self.presentingViewController = presentingViewController
        VLAuthenticationInternal.sharedInstance.initiateAuthenticateUsingDeviceCode(authenticationType: authenticationType, activateDeviceUrl: activateDeviceUrl, authenticationObject: authenticationObject, authenticationClient: authenticationClient, callback: callback)
    }

    public func disconnectDeviceSync(authenticationClient:VLAuthenticationClient, callback: @escaping ((_ logoutSuccessful:Bool) ->())) {
        VLAuthenticationInternal.sharedInstance.disconnectDeviceSync(authenticationClient: authenticationClient, callback: callback)
    }
    #endif
    
    public func logout(client:VLAuthenticationClient, callback: @escaping ((_ logoutSuccessful:Bool) ->())) {
        VLAuthenticationInternal.sharedInstance.logout(client: client, callback: callback)
    }
    
    #if os(iOS)
    public func initateDeviceActivation(authenticationType:VLAuthenticationType, authenticationObject:VLAuthenticationObject?, authenticationClient:VLAuthenticationClient, presentingViewController:UIViewController?, callback: @escaping ((_ success:Bool?, _ errorCode:VLAuthenticationErrorCode?) -> Void)) {
        self.presentingViewController = presentingViewController
        VLAuthenticationInternal.sharedInstance.initateDeviceActivation(authenticationType: authenticationType, authenticationObject: authenticationObject, authenticationClient: authenticationClient, presentingViewController: presentingViewController, callback: callback)
    }
    
    public func approveMobileSignInRequest(withApprovalDetails details:[String:String], callback: @escaping ((_ success:Bool, _ errorCode:VLAuthenticationErrorCode?) -> Void)) {
        VLAuthenticationInternal.sharedInstance.approveMobileSignInRequest(withApprovalDetails: details, callback: callback)
    }
    
    public func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) {
        VLAuthenticationInternal.sharedInstance.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
    
    public func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any]) -> Bool {
        return VLAuthenticationInternal.sharedInstance.application(app, open: url, options: options)
    }
    #endif
}
