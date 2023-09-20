//
//  VLAuthLogoutProtocol.swift
//  VLAuthentication
//
//  Created by Gaurav Vig on 05/12/22.
//

protocol VLAuthLogoutProtocol {}
extension VLAuthLogoutProtocol {
    func invokeLogoutRequest(requestType:HTTPRequestType, requestEndPoint:String = APIUrlEndPoint.emailLogoutEndPoint.rawValue, callback: @escaping ((_ logoutSuccessfully:Bool) ->())) {
        let apiRequest = APIUrl.getAPIBaseUrl() + requestEndPoint
        Task {
            do {
                let _ = try await VLAPIService().makeAuthenticationRequest(requestString: apiRequest, requestBody: nil, requestType: requestType)
                callback(true)
            }
            catch {
                callback(false)
            }
        }
    }
}
