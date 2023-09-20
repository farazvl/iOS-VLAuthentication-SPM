//
//  VLActivateDeviceResponse.swift
//  VLAuthenticationLib
//
//  Created by NexG on 27/03/23.
//

import Foundation

public struct VLActivateDeviceResponse:Decodable {
    public let code:String?
    public let status:String?
    public let errorMessage:String?
}
