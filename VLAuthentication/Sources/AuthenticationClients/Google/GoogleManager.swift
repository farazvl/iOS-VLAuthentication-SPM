//
//  GoogleManager.swift
//  VLAuthenticationLib
//
//  Created by Gaurav Vig on 29/11/22.
//

import UIKit
import GoogleSignIn

class GoogleManager {
    
    func loginWithGoogle(googleLoginDone: @escaping ((_ loginStatus: Bool, _ googleAccessToken: String?, _ name: String?, _ email: String?, _ googleID: String?) -> Void), viewController: UIViewController)
    {
        guard let bundleInfoDict = Bundle.main.infoDictionary, let googleClientId = bundleInfoDict["GoogleClientId"] as? String else { return googleLoginDone(false, nil, nil, nil, nil) }
        GIDSignIn.sharedInstance.configuration = GIDConfiguration(clientID: googleClientId)
        GIDSignIn.sharedInstance.signIn(withPresenting: viewController) { authUser, error in
            guard error == nil, let authUser, let googleToken = authUser.user.idToken?.tokenString else {
                googleLoginDone(false, nil, nil, nil, nil)
                return
            }
            googleLoginDone(true, googleToken, authUser.user.profile?.name, authUser.user.profile?.email, authUser.user.userID)
        }
    }
    
    func logout() {
        GIDSignIn.sharedInstance.signOut()
    }
}
    
