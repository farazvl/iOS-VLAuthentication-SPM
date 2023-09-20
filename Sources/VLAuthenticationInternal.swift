//
//  VLAuthenticationInternal.swift
//  VLAuthentication
//
//  Created by Gaurav Vig on 25/11/22.
//

import UIKit

final class VLAuthenticationInternal {
    
    static let sharedInstance:VLAuthenticationInternal = {
        let instance = VLAuthenticationInternal()
        instance.setupConfiguration()
        return instance
    }()
    private let bundleIdentifier = "com.viewlift.authenticationsdk"
    internal var apiUrl:String?
        
    internal func initiateAuthentication(authenticationType:VLAuthenticationType, authenticationObject:VLAuthenticationObject?, authenticationClient:VLAuthenticationClient, callback: @escaping ((_ userIdentity:VLUserIdentity?, _ errorCode:VLAuthenticationErrorCode?) -> Void)) {
        let authenticationDict = getUserDetails(from: authenticationObject) ?? [:]
        switch authenticationClient {
        case .emailWithPassword:
            self.initiateAuthenticationService(authClient: authenticationClient, authenticaitonType: authenticationType, userDetails: authenticationDict, authenticationService: VLEmailAuthenticationClient.sharedInstance, callback: callback)
        case .facebook:
            #if os(iOS)
            self.initiateAuthenticationService(authClient: authenticationClient, authenticaitonType: authenticationType, userDetails: authenticationDict, authenticationService: VLFacebookAuthenticationClient.sharedInstance, callback: callback)
            #endif
            break
        case .google:
            #if os(iOS)
            self.initiateAuthenticationService(authClient: authenticationClient, authenticaitonType: authenticationType, userDetails: authenticationDict, authenticationService: VLGoogleAuthenticationClient.sharedInstance, callback: callback)
            #endif
            break
        case .apple:
            self.initiateAuthenticationService(authClient: authenticationClient, authenticaitonType: authenticationType, userDetails: authenticationDict, authenticationService: VLAppleAuthenticationClient.sharedInstance, callback: callback)
        case .otp, .emailWithOtp:
            #if os(iOS)
            self.initiateAuthenticationService(authClient: authenticationClient, authenticaitonType: authenticationType, userDetails: authenticationDict, authenticationService: VLOTPAuthenticationClient.sharedInstance, callback: callback)
            #endif
            break
        case .activateCode, .qrcode:
            break
        case .mobile:
            #if os(tvOS)
            self.initiateAuthenticationService(authClient: authenticationClient, authenticaitonType: authenticationType, userDetails: authenticationDict, authenticationService: VLMobileAuthenticationClient.sharedInstance, callback: callback)
            #endif
            break
        case .tvProvider(provider: let provider):
            self.initiateTVEAuthentication(authClient: authenticationClient, tveProvider: provider ?? .adobe, userDetails: authenticationDict, authenticationService: VLTVAuthenticationClient.sharedInstance, callback: callback)
        case .activateCodeWithQRCode, .activateDeviceViaCode:
            break
        case .restorePurchaseSignIn:
            self.initiateAuthenticationService(authClient: authenticationClient, authenticaitonType: authenticationType, userDetails: authenticationDict, authenticationService: VLRestorePurchaseAuthenticationClient.sharedInstance, callback: callback)
        }
    }
    
    internal func logout(client:VLAuthenticationClient, callback: @escaping ((_ logoutSuccessfully:Bool) ->())) {
        switch client {
        case .emailWithPassword, .emailWithOtp:
            self.invokeLogout(authClient: client, authenticationService: VLEmailAuthenticationClient.sharedInstance, callback: callback)
        case .facebook:
            #if os(iOS)
            self.invokeLogout(authClient: client, authenticationService: VLFacebookAuthenticationClient.sharedInstance, callback: callback)
            #endif
            break
        case .google:
            #if os(iOS)
            self.invokeLogout(authClient: client, authenticationService: VLGoogleAuthenticationClient.sharedInstance, callback: callback)
            #endif
            break
        case .apple:
			self.invokeLogout(authClient: client, authenticationService: VLAppleAuthenticationClient.sharedInstance, callback: callback)
			break
        case .qrcode, .activateCode, .activateCodeWithQRCode:
            #if os(tvOS)
            self.invokeLogout(authClient: client, authenticationService: VLActivateCodeAuthenticationClient.sharedInstance, callback: callback)
            #endif
            break
        case .otp:
            #if os(iOS)
            self.invokeLogout(authClient: client, authenticationService: VLOTPAuthenticationClient.sharedInstance, callback: callback)
            #endif
            break
        case .activateDeviceViaCode:
            #if os(iOS)
            VLActivateDeviceAuthClient.sharedInstance.logout(authClient: client, callback: callback)
            #endif
			break
        case .mobile:
			#if os(tvOS)
			self.invokeLogout(authClient: client, authenticationService: VLMobileAuthenticationClient.sharedInstance, callback: callback)
			#endif
			break
        case .tvProvider(provider: _):
            self.invokeLogout(authClient: client, authenticationService: VLTVAuthenticationClient.sharedInstance, callback: callback)
        case .restorePurchaseSignIn:
            self.invokeLogout(authClient: client, authenticationService: VLRestorePurchaseAuthenticationClient.sharedInstance, callback: callback)
        }
    }
}

extension VLAuthenticationInternal {
    private func initiateAuthenticationService(authClient:VLAuthenticationClient, authenticaitonType:VLAuthenticationType, activateDeviceUrl:String? = nil, userDetails:[String:Any], authenticationService:VLAuthenticationProtocol, callback: @escaping ((_ userIdentity:VLUserIdentity?, _ errorCode:VLAuthenticationErrorCode?) -> Void)) {
        switch authenticaitonType {
        case .signin:
            initiateLoginAuthentication(authClient: authClient, activateDeviceUrl: activateDeviceUrl, userDetails: userDetails, authenticationService: authenticationService, callback: callback)
            break
        case .signup:
            initiateSignUpAuthentication(authClient: authClient, userDetails: userDetails, authenticationService: authenticationService, callback: callback)
            break
        case .verify:
			authenticationService.verifyAuthenticationRequest(authClient: authClient, userDetails: userDetails, callback: callback)
            break
        default:
            break
        }
    }
    
    private func initiateSignUpAuthentication(authClient: VLAuthenticationClient, userDetails:[String:Any], authenticationService:VLAuthenticationProtocol, callback: @escaping ((_ userIdentity:VLUserIdentity?, _ errorCode:VLAuthenticationErrorCode?) -> Void)) {
        authenticationService.initateSignUpRequest(authClient: authClient, userDetails: userDetails, callback: callback)
    }
    
    private func invokeLogout(authClient:VLAuthenticationClient, authenticationService:VLAuthenticationProtocol, callback:@escaping ((_ logoutSuccessfully:Bool) ->())) {
        authenticationService.logout(authClient: authClient, callback: callback)
    }
}

//MARK: For Facebook
#if os(iOS)
extension VLAuthenticationInternal {
    internal func initateDeviceActivation(authenticationType:VLAuthenticationType, authenticationObject:VLAuthenticationObject?, authenticationClient:VLAuthenticationClient, presentingViewController:UIViewController?, callback: @escaping ((_ success:Bool?, _ errorCode:VLAuthenticationErrorCode?) -> Void)) {
        let authenticationDict = getUserDetails(from: authenticationObject) ?? [:]
        VLActivateDeviceAuthClient.sharedInstance.initateDeviceActivationRequest(authClient: authenticationClient, userDetails: authenticationDict, callback: callback)
    }
    
    internal func approveMobileSignInRequest(withApprovalDetails details:[String:String], callback: @escaping ((_ success:Bool, _ errorCode:VLAuthenticationErrorCode?) -> Void)) {
        VLMobileAuthenticationClient.sharedInstance.approveConnectionRequest(userDetails: details, callback: callback)
    }
    
    internal func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) {
        VLFacebookAuthenticationClient.sharedInstance.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
    
    internal func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any]) -> Bool {
        return VLFacebookAuthenticationClient.sharedInstance.application(app, open: url, options: options)
    }
    
    private func initiateLoginAuthentication(authClient:VLAuthenticationClient, activateDeviceUrl:String?, userDetails:[String:Any], authenticationService:VLAuthenticationProtocol, callback: @escaping ((_ userIdentity:VLUserIdentity?, _ errorCode:VLAuthenticationErrorCode?) -> Void)) {
        authenticationService.initateLoginRequest(authClient: authClient, userDetails: userDetails, callback: callback)
    }
}
#else
extension VLAuthenticationInternal {
    internal func initiateAuthenticateUsingDeviceCode(authenticationType:VLAuthenticationType, activateDeviceUrl:String, authenticationObject:VLAuthenticationObject?, authenticationClient:VLAuthenticationClient, callback: @escaping ((_ userIdentity:VLUserIdentity?, _ errorCode:VLAuthenticationErrorCode?) -> Void)) {
        let authenticationDict = getUserDetails(from: authenticationObject) ?? [:]
        switch authenticationClient {
        case .activateCode, .qrcode, .activateCodeWithQRCode:
            self.initiateAuthenticationService(authClient: authenticationClient, authenticaitonType: authenticationType, activateDeviceUrl: activateDeviceUrl, userDetails: authenticationDict, authenticationService: VLActivateCodeAuthenticationClient.sharedInstance, callback: callback)
        default:
            break
        }
    }
    
    private func initiateLoginAuthentication(authClient:VLAuthenticationClient, activateDeviceUrl:String?, userDetails:[String:Any], authenticationService:VLAuthenticationProtocol, callback: @escaping ((_ userIdentity:VLUserIdentity?, _ errorCode:VLAuthenticationErrorCode?) -> Void)) {
        if authenticationService is VLActivateCodeAuthenticationClient {
            (authenticationService as! VLActivateCodeAuthenticationClient).activationUrl = activateDeviceUrl
        }
        authenticationService.initateLoginRequest(authClient: authClient, userDetails: userDetails, callback: callback)
    }
    
    internal func disconnectDeviceSync(authenticationClient:VLAuthenticationClient, callback: @escaping ((_ logoutSuccessful:Bool) ->())) {
        switch authenticationClient {
        case .mobile:
            initiateDisconnectRequest(authClient: authenticationClient, authenticationService: VLMobileAuthenticationClient.sharedInstance, callback: callback)
        case .activateCode, .activateCodeWithQRCode, .qrcode:
            initiateDisconnectRequest(authClient: authenticationClient, authenticationService: VLActivateCodeAuthenticationClient.sharedInstance, callback: callback)
        default:
            break
        }
    }
    
    private func initiateDisconnectRequest(authClient:VLAuthenticationClient, authenticationService:VLAuthenticationDeviceSyncProtocol, callback: @escaping ((_ logoutSuccessful:Bool) -> Void)) {
        authenticationService.disconnectDeviceSync(authenticationClient: authClient, callback: callback)
    }
}
#endif

///For TVE
extension VLAuthenticationInternal {
    
    private func initiateTVEAuthService(authClient:VLAuthenticationClient, authenticaitonType:VLAuthenticationType, tveProvider:VLAuthenticationClient.TVProvider, userDetails:[String:Any], authenticationService:VLAuthenticationProtocol, callback: @escaping ((_ userIdentity:VLUserIdentity?, _ errorCode:VLAuthenticationErrorCode?) -> Void)) {
        switch authenticaitonType {
        case .signin, .signup:
            initiateTVEAuthentication(authClient: authClient, tveProvider: tveProvider, userDetails: userDetails, authenticationService: authenticationService, callback: callback)
            break
        case .verify:
            break
        default:
            break
        }
    }
    
    private func initiateTVEAuthentication(authClient:VLAuthenticationClient, tveProvider:VLAuthenticationClient.TVProvider,  userDetails:[String:Any], authenticationService:VLAuthenticationProtocol, callback: @escaping ((_ userIdentity:VLUserIdentity?, _ errorCode:VLAuthenticationErrorCode?) -> Void)) {
        if authenticationService is VLTVAuthenticationClient {
            (authenticationService as! VLTVAuthenticationClient).tveProvider = tveProvider
        }
        authenticationService.initateLoginRequest(authClient: authClient, userDetails: userDetails, callback: callback)
    }
}

extension VLAuthenticationInternal {
    
    func getUserDetails(from authenticationObject:VLAuthenticationObject?) -> [String:Any]? {
        guard let authenticationObject else {return nil}
        do {
            let encodedResponseData = try JSONEncoder().encode(authenticationObject)
            if let encodedResponseDict = try JSONSerialization.jsonObject(with: encodedResponseData) as? [String:Any] {
                return encodedResponseDict
            }
        }
        catch {
            return nil
        }
        return nil
    }
}

extension VLAuthenticationInternal {
	
    private func setupConfiguration() {
		if let apiUrl = self.getBaseUrl() {
			self.apiUrl = apiUrl
		}
		else {
			var filePath:String?
			let classBundle = Bundle(for: type(of: self))
			if let classBundlePath = classBundle.path(forResource: "VLAuthenticationLib", ofType: "bundle"), let bundle = Bundle(path: classBundlePath) {
				filePath = bundle.path(forResource: "Configuration", ofType: "plist")
			}
			if filePath == nil {
				guard let bundle = Bundle(identifier: bundleIdentifier) else {
					return
				}
				filePath = bundle.path(forResource: "Configuration", ofType: "plist")
			}
			
			guard let filePath else { return }
			if let configData = try? Data(contentsOf: URL(fileURLWithPath: filePath)), let configuration = try? PropertyListDecoder().decode(VLConfiguration.self, from: configData),
			   let apiUrl = configuration.apiUrl {
				self.apiUrl = apiUrl
			}
		}
    }
	
	private func getBaseUrl() -> String? {
		guard let bundlePath = Bundle.main.path(forResource: "SiteConfig", ofType: "plist"),
			  let dict = NSDictionary.init(contentsOfFile: bundlePath),
			  let apiEndpoint = dict["APIEndPoint"] as? String else {return nil}
		return apiEndpoint
	}
}
