//
//  VLAuthenticationProtocol.swift
//  VLAuthentication
//
//  Created by Gaurav Vig on 25/11/22.
//


protocol VLAuthenticationProtocol {
    func initateLoginRequest(authClient:VLAuthenticationClient, userDetails:[String:Any], callback: @escaping ((_ userIdentity:VLUserIdentity?, _ errorCode:VLAuthenticationErrorCode?) -> Void))
    func initateSignUpRequest(authClient: VLAuthenticationClient, userDetails:[String:Any], callback: @escaping ((_ userIdentity:VLUserIdentity?, _ errorCode:VLAuthenticationErrorCode?) -> Void))
	func verifyAuthenticationRequest(authClient: VLAuthenticationClient, userDetails:[String:Any], callback: @escaping ((_ userIdentity:VLUserIdentity?, _ errorCode:VLAuthenticationErrorCode?) -> Void))
    func logout(authClient:VLAuthenticationClient, callback: @escaping ((_ logoutSuccessfully:Bool) ->()))
}

protocol VLAuthenticationDeviceSyncProtocol {
    func disconnectDeviceSync(authenticationClient:VLAuthenticationClient, callback: @escaping ((_ logoutSuccessful:Bool) ->()))
}
