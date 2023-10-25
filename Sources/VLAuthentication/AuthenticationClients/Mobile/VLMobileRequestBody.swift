//
//  VLMobileRequestBody.swift
//  VLAuthentication
//
//  Created by Gaurav Vig on 04/01/23.
//

import UIKit
import CryptoKit
import os.log

struct VLMobileRequestBody {
    static let deviceName = UIDevice.current.name
    static let deviceModel = UIDevice.current.model
    static let deviceIP = UIDevice.current.getIPAddress()
}

protocol VLMobileRequestBodyProtocol {}
extension VLMobileRequestBodyProtocol {
    
    func getRequestBody() -> [String:Any]? {
        var requestBodyString = ""//VLMobileRequestBody.deviceName
        if let ip = VLMobileRequestBody.deviceIP {
            requestBodyString.append("\(ip)")
        }
        
        if !requestBodyString.isEmpty {
            requestBodyString.append("::")
        }
        requestBodyString.append(VLMobileRequestBody.deviceName)
        
        
        //        if !requestBodyString.isEmpty {
        //            requestBodyString.append("::")
        //        }
                
        
        //        if !requestBodyString.isEmpty {
        //            requestBodyString.append("::")
        //        }
        //
        //        requestBodyString.append("\(VLMobileRequestBody.deviceModel)")
        guard let requestData = requestBodyString.data(using: .utf8) else {return nil}
        let digest = SHA256.hash(data: requestData)
        
#if !os(Linux)
        os_log("Request body for mobile connect: %@", log: OSLog(subsystem: "com.viewlift.mobileconnect", category: "Request body"), type: .debug, requestBodyString)
#endif
        print("value >>>>> \(requestBodyString)")
        return ["key":digest.hexStr.lowercased(), "platform":"appletv", "deviceName":VLMobileRequestBody.deviceName, "bitcode":100]
    }
}

// CryptoKit.Digest utils
extension Digest {
    var bytes: [UInt8] { Array(makeIterator()) }
    var data: Data { Data(bytes) }
    
    var hexStr: String {
        bytes.map { String(format: "%02X", $0) }.joined()
    }
}
