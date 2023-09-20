//
//  VLGraphQLInputVariableBuilder.swift
//  VLAuthentication
//
//  Created by Gaurav Vig on 07/02/23.
//

import UIKit

struct VLGraphQLInputVariableBuilder {
    
    let deviceName = UIDevice.current.name
#if os(iOS)
    var platform = "ios_phone"
#else
    let platform = "ios_apple_tv"
#endif
    var deviceId:String?

    init() {
		#if os(iOS)
		if UIDevice.current.userInterfaceIdiom == UIUserInterfaceIdiom.pad {
			self.platform = "ios_ipad"
		}
		else {
			self.platform = "ios_phone"
		}
		#endif
        if self.deviceId == nil {
            self.deviceId = VLAuthenticationHelper.getUUID()
        }
    }
    
    func getGraphQLInputVariables(customVariable:[String : Any]) -> [String:Any] {
        var variables = customVariable
        let mirror = Mirror(reflecting: self)
        mirror.children.forEach { child in
            if let label = child.label {
                variables[label] = child.value
            }
            
        }
        return variables
    }
}
