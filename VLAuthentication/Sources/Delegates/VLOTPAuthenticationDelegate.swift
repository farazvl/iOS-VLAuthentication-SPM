//
//  VLOTPAuthenticationDelegate.swift
//  VLAuthenticationLib
//
//  Created by Gaurav Vig on 30/11/22.
//


public protocol VLOTPAuthenticationDelegate:AnyObject {
    func otpVerification(callback: @escaping ((_ verificationType:VLOTPVerificationType, _ otp:String?) -> Void))
}
