//
//  VLAPIRequestParamBuilder.swift
//  VLAuthenticationLib
//
//  Created by Gaurav Vig on 28/11/22.
//

import UIKit

final class VLAPIRequestParamBuilder:NSObject, PropertyNames {
    @objc let deviceName:String?
    @objc var deviceId:String?
    @objc let platform:String
    @objc let device:String
    @objc let site:String?
    
    override init() {
        self.site = VLAuthentication.sharedInstance.siteName
        self.deviceName = UIDevice.current.name
        #if os(iOS)
        self.platform = "ios"
		if UIDevice.current.userInterfaceIdiom == UIUserInterfaceIdiom.pad {
			self.device = "ios_ipad"
		}
		else {
			self.device = "ios_phone"
		}
        #else
        self.platform = "ios_apple_tv"
        self.device = "ios_apple_tv"
        #endif
        if let token = VLAuthentication.sharedInstance.authorizationToken {
            self.deviceId = JWTTokenParser().jwtTokenParser(jwtToken: token)?.deviceId
        }
        if self.deviceId == nil {
            self.deviceId = VLAuthenticationHelper.getUUID()
        }
        super.init()
    }
    
    func getRequestParam() -> String {
        var requestParam:String = ""
        let propertyNames = self.propertyNames()
        for key in propertyNames {
            if let _value = self.value(forKey: key) as? String {
                requestParam = requestParam.appending("\(key)=\(_value)&")
            }
        }
        requestParam.removeLast()
        return requestParam
    }
    
    func getSiteAsParam() -> String {
        var requestParam:String = ""
        let propertyNames = self.propertyNames()
        for key in propertyNames {
            if key == "site", let _value = self.value(forKey: key) as? String {
                requestParam = requestParam.appending("\(key)=\(_value)&")
            }
        }
        requestParam.removeLast()
        return requestParam
    }
}

protocol PropertyNames {
    func propertyNames() -> [String]
}

extension PropertyNames
{
    func propertyNames() -> [String] {
        return Mirror(reflecting: self).children.compactMap { $0.label }
    }
    
    func mirror() -> Mirror {
        return Mirror(reflecting: self)
    }
}
