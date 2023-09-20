//
//  VLGraphQLVariableBuilder.swift
//  VLAuthentication
//
//  Created by Gaurav Vig on 07/02/23.
//

import UIKit

struct VLGraphQLVariableBuilder {
    
    let site = VLAuthentication.sharedInstance.siteName
#if os(iOS)
    var device = "ios_phone"
#else
    let device = "ios_apple_tv"
#endif
    let input:[String:Any]?

	init(customVariable:[String : Any]) {
		#if os(iOS)
		if UIDevice.current.userInterfaceIdiom == UIUserInterfaceIdiom.pad {
			self.device = "ios_ipad"
		}
		else {
			self.device = "ios_phone"
		}
		#endif
		self.input = customVariable
	}
    
    func getGraphQLVariables() -> [String:Any] {
        var variables:[String:Any] = [:]
        let mirror = Mirror(reflecting: self)
        mirror.children.forEach { child in
            if let label = child.label {
                variables[label] = child.value
            }
            
        }
        return variables
    }
}
