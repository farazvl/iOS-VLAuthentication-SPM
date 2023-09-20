//
//  VLAuthenticationHelper.swift
//  VLAuthenticationLib
//
//  Created by Gaurav Vig on 28/11/22.
//

import UIKit

final class VLAuthenticationHelper {
    
    static func getUserAgent() -> String {
        let bundleDict = Bundle.main.infoDictionary!
        let appName = bundleDict["CFBundleName"] as! String
        let appVersion = bundleDict["CFBundleShortVersionString"] as! String
        let appDescriptor = appName + "/" + appVersion
        let currentDevice = UIDevice.current
        var osDescriptor = "iOS/" + currentDevice.systemVersion
        #if os(tvOS)
        osDescriptor = "tvOS/" + currentDevice.systemVersion
        #endif
        return appDescriptor + " " + osDescriptor + " (" + UIDevice.current.model + ")"
    }
    
    static func getUUID() -> String {
        do {
            let keychainData = try KeychainHelper.readPassword(service: Bundle.main.bundleIdentifier ?? "service", account: "user")
            if let retrieveUUID = String(data: keychainData, encoding: .utf8) {
                return retrieveUUID
            }
            else {
                return generateUUID()
            }
        }
        catch {
            return generateUUID()
        }
    }
    
    private static func generateUUID() -> String {
        let theUUID:CFUUID = CFUUIDCreate(kCFAllocatorDefault)
        let string:CFString = CFUUIDCreateString(kCFAllocatorDefault, theUUID)
        let uuid:String = string as String
        if let data = uuid.data(using: .utf8) {
            try? KeychainHelper.save(password: data, service: Bundle.main.bundleIdentifier ?? "service", account: "user")
        }
        return uuid
    }
}
