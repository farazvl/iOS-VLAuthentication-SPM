//
//  VLMobileConnectObject.swift
//  VLAuthentication
//
//  Created by Gaurav Vig on 19/01/23.
//

import Foundation

struct VLMobileConnectObject:Decodable {
    let code:String?
    let status:Bool?
    
    private enum CodingKeys:String, CodingKey {
        case code, status
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.code = try? container.decodeIfPresent(String.self, forKey: .code)
        self.status = try? container.decodeIfPresent(Bool.self, forKey: .status)
    }
}
