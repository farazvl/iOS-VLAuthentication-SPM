//
//  VLOTPResponseObject.swift
//  VLAuthentication
//
//  Created by Gaurav Vig on 08/12/22.
//

import Foundation

struct VLOTPResponseObject:Codable {
    let key:String?
    let email:String?
    let phoneNumber:String?
    let code:String?
    let error:String?
}
