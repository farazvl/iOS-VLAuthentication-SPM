//
//  NetworkRequest.swift
//  VLAuthentication
//
//  Created by Gaurav Vig on 25/11/22.
//

import Foundation

actor NetworkRequest {
    func makeNetworkRequest(requestString:String, requestHeaders:[String:String], requestBody:[String:Any]?, requestType:String) async throws -> (Data?, VLAuthenticationErrorCode?) {
        guard let apiUrl = URL(string: requestString) else { return (nil, .invalidRequestUrl) }
        var urlRequest = URLRequest(url: apiUrl)
        urlRequest.httpMethod = requestType
        urlRequest.cachePolicy = .reloadIgnoringLocalAndRemoteCacheData
        urlRequest.allHTTPHeaderFields = requestHeaders
        if let requestBody, !requestBody.isEmpty, let data = try? JSONSerialization.data(withJSONObject: requestBody) {
            urlRequest.httpBody = data
        }
        getCURLRequest(request: urlRequest)
        let (data, response) = try await URLSession.shared.data(for: urlRequest)
        guard (response as? HTTPURLResponse)?.statusCode == 200 else { return (data, .noDataFound) }
        return (data, nil)
    }
    
    private func getCURLRequest(request: URLRequest) {
        var curlString = "VLAUTHENTICATIONLIB CURL REQUEST:\n"
        curlString += "curl -X \(request.httpMethod!) \\\n"
        
        request.allHTTPHeaderFields?.forEach({ (key, value) in
            let headerKey = self.escapeQuotesInString(str: key)
            let headerValue = self.escapeQuotesInString(str: value)
            curlString += " -H \'\(headerKey): \(headerValue)\' \n"
        })
        
        guard let requestUrl = request.url else {return}
        curlString += " \(requestUrl.absoluteString) \\\n"
        
        if let body = request.httpBody, body.count > 0 {
            if let str = String(data: body, encoding: String.Encoding.utf8) {
                let bodyDataString = self.escapeQuotesInString(str: str)
                curlString += " -d \'\(bodyDataString)\'"
            }
        }
        
        print(curlString)
    }
    
    private func escapeQuotesInString(str:String) -> String {
        return str.replacingOccurrences(of: "\\", with: "")
    }
}
