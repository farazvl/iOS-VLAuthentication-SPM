//
//  AppleAuthenticationHandler.swift
//  VLAuthenticationLib
//
//  Created by Gaurav Vig on 02/12/22.
//

import UIKit
import AuthenticationServices

final class AppleAuthenticationManager:NSObject {
    static let sharedInstance = AppleAuthenticationManager()
    var presenterContext : UIView!
    var authenticationCallback:((_ userDetails:[String:Any]?, _ isSuccess:Bool, _ errorCode:VLAuthenticationErrorCode?) -> Void)?
    
    func performAuthentication(presenter:UIView?, callback:@escaping ((_ userDetails:[String:Any]?, _ isSuccess:Bool, _ errorCode:VLAuthenticationErrorCode?) -> Void)) {
        self.presenterContext = presenter
        self.authenticationCallback = callback
        self.performSignIn()
    }
    
    private func performSignIn() {
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]
        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = self
        authorizationController.performRequests()
    }
}

extension AppleAuthenticationManager: ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {
    /// - Tag: provide_presentation_anchor
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return self.presenterContext.window!
    }

    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        print(error.localizedDescription)
        print((error as NSError).code)
        if (error as NSError).code == 1001 {
            authenticationCallback?(nil, false, .appleAuthenticationCancelled)
        } else {
            authenticationCallback?(nil, false, .appleAuthenticationFailed)
        }
        
        ///To check
//        if (error as NSError).code == 1000 || (error as NSError).code == 1001 {
//            authenticationCallback?(false, nil, nil, nil)
//        }
//        else {
//            authenticationCallback?(false, error.localizedDescription, nil, nil)
//        }
    }
        
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        if let credential = authorization.credential as? ASAuthorizationAppleIDCredential {
            DispatchQueue.main.async {
                let appleAuthModel = self.createAppleAuthenicatorModel(credential: credential)
                do {
                    let encodedObject = try JSONEncoder().encode(appleAuthModel)
                    if let userDetails = try? JSONSerialization.jsonObject(with: encodedObject) as? [String: Any] {
                        self.saveUserInKeychain(appleAuthModel.userId ?? "")
                        self.authenticationCallback?(userDetails, true, nil)
                    }
                    else {
                        self.authenticationCallback?(nil, false, .appleAuthenticationFailed)
                    }
                }
                catch {
                    self.authenticationCallback?(nil, false, .appleAuthenticationFailed)
                }
            }
        }
        else {
            #if os(iOS)
            self.authorizeForPasswordCredentials(controller: controller, didCompleteWithAuthorization: authorization)
            #else
            if #available(tvOS 15.0, *) {
                self.authorizeForPasswordCredentials(controller: controller, didCompleteWithAuthorization: authorization)
            }
            #endif
        }
    }
    
    func authorizeForPasswordCredentials(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        if #available(iOS 13.0, tvOS 15.0, *) {
            if let passwordCredential = authorization.credential as? ASPasswordCredential {
                DispatchQueue.main.async {
                    let appleAuthModel = self.createAppleAuthenicatorModel(credential: passwordCredential)
                    do {
                        let encodedObject = try JSONEncoder().encode(appleAuthModel)
                        if let userDetails = try? JSONSerialization.jsonObject(with: encodedObject) as? [String: Any] {
                            self.authenticationCallback?(userDetails, true, nil)
                        }
                        else {
                            self.authenticationCallback?(nil, false, .appleAuthenticationFailed)
                        }
                    }
                    catch {
                        self.authenticationCallback?(nil, false, .appleAuthenticationFailed)
                    }
                }
            }
        } else {
            // Fallback on earlier versions
        }
    }
    
    private func createAppleAuthenicatorModel(credential:Any) -> AppleAuthenticatorModel {
        if #available(iOS 13.0, tvOS 15.0, *) {
            if let passwordCredential = credential as? ASPasswordCredential {
                return AppleAuthenticatorModel(userId: passwordCredential.user)
            }
            else if let userCredential = credential as? ASAuthorizationAppleIDCredential {
                return createAppleAuthenicatorModel(userCredential: userCredential)
            }
            else {
                return AppleAuthenticatorModel()
            }
        }
        else {
            if let userCredential = credential as? ASAuthorizationAppleIDCredential {
                return createAppleAuthenicatorModel(userCredential: userCredential)
            }
            else {
                return AppleAuthenticatorModel()
            }
        }
    }
    
    private func createAppleAuthenicatorModel(userCredential:ASAuthorizationAppleIDCredential) -> AppleAuthenticatorModel {
        print(userCredential.fullName?.givenName ?? "NA")
        print(userCredential.fullName?.familyName ?? "NA")
        print(userCredential.fullName?.middleName ?? "NA")
        
        let firstName = userCredential.fullName?.givenName ?? "NA"
        var idToken = ""
        if let token = userCredential.identityToken, let encodedToken = String(data: token, encoding: .utf8) {
            idToken = encodedToken
        }
        return AppleAuthenticatorModel(userId: userCredential.user, email: userCredential.email, firstName: firstName, idToken: idToken)
    }
    
    private func saveUserInKeychain(_ userIdentifier: String) {
        if let info = Bundle.main.infoDictionary, let identifier = info["CFBundleIdentifier"] as? String{
            do {
                try KeychainItem(service: identifier, account: "userIdentifier").saveItem(userIdentifier)
            } catch {
            }
        }
    }
}
