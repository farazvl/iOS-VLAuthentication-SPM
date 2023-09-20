//
//  FacebookManager.swift
//  VLAuthenticationLib
//
//  Created by Gaurav Vig on 29/11/22.
//

import FBSDKLoginKit
import FBSDKCoreKit
import UIKit

class FacebookManager {
    
    private let loginManager = LoginManager()
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) {
        ApplicationDelegate.shared.application( application, didFinishLaunchingWithOptions: launchOptions)
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any]) -> Bool {
        return ApplicationDelegate.shared.application(app, open: url, options: options)
    }
    
    func loginWithFacebook(facebookLoginDone: @escaping ((_ loginStatus: Bool, _ fbAccessToken: String, _ name: String?, _ email: String?, _ fbID: String?) -> Void), viewController: UIViewController)
    {
        if AccessToken.current != nil {
            loginManager.logOut()
            facebookLoginDone(false, "", nil, nil, nil)
            return
        }
        
        loginManager.logIn(permissions: ["email", "public_profile"], from: viewController) { (loginManagerResult, error) in
            if let _loginManagerResult = loginManagerResult, let accessToken = _loginManagerResult.token {
                if _loginManagerResult.grantedPermissions.count == 2 || _loginManagerResult.grantedPermissions.count == 3
                {
                    self.getFBUserDetails(loginDetails: { (name, email, facebookID) in
                        facebookLoginDone(true, accessToken.tokenString, name, email, facebookID)
                    })
                }
                else {
                    facebookLoginDone(false, "", nil, nil, nil)
                }
            }
            else {
                facebookLoginDone(false, "", nil, nil, nil)
            }
        }
    }
    
    private func getFBUserDetails(loginDetails: @escaping ((_ name: String?, _ email: String?, _ fbID: String) -> Void)) -> Void {
        let graphRequest = GraphRequest(graphPath: "me", parameters: ["fields": "id, name, email"], tokenString: AccessToken.current?.tokenString, version: nil, httpMethod: .get)
        graphRequest.start { (connection, result, error) in
            if error == nil {
                if let responseDictionary = result as? Dictionary<String, Any> {
                    loginDetails(responseDictionary["name"] as? String, responseDictionary["email"] as? String, responseDictionary["id"] as? String ?? "")
                }
            }
        }
    }
    
    func logout() {
        if AccessToken.current != nil {
            loginManager.logOut()
        }
    }
}
