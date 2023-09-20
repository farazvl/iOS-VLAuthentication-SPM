//
//  VLActivateDeviceCodeDelegate.swift
//  VLAuthentication
//
//  Created by Gaurav Vig on 02/12/22.
//

import UIKit

@objc public protocol VLActivateDeviceCodeDelegate:NSObjectProtocol {
    @objc optional func deviceActivationCode(activationCode:String)
    @objc optional func deviceQRCode(qrCode:UIImage)
    @objc optional func deviceActivationAndQRCode(activationCode:String, qrCode:UIImage)
}
