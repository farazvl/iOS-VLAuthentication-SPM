//
//  VLBeaconEventTriggerProtocols.swift
//  VLAuthentication
//
//  Created by NEXGEN on 05/04/23.
//

import Foundation
import VLBeaconLib

internal protocol VLBeaconEventTriggerProtocol{
    func triggerUserBeaconEvent(eventName: UserBeaconEventEnum, type: AuthType, authType: AuthSubType, existingUser: Bool?, userEmail: String?, userPhoneNumber: String?)
}

extension VLBeaconEventTriggerProtocol {

    internal func triggerUserBeaconEvent(eventName: UserBeaconEventEnum, type: AuthType, authType: AuthSubType, existingUser: Bool? = nil, userEmail: String? = nil, userPhoneNumber: String? = nil){

        let userEventBody = UserBeaconEventStruct(eventName: eventName, source: "VLAuthentication", eventData: AuthenticationPayload(type: type, subType: authType, email: userEmail, phoneNumber: userPhoneNumber, existingUser: existingUser))

            VLBeacon.sharedInstance.triggerBeaconEvent(userEventBody)
    }
}
