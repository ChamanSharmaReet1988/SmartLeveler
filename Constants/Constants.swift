//
//  Constants.swift
//  RemoteLight
//
//  Created by I&A on 2/5/18.
//  Copyright © 2018 Chaman. All rights reserved.
//

import UIKit

let AppVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"]  as? String
let DeviceId = UIDevice.current.identifierForVendor!.uuidString
var DeviceToken = ""
let DeviceModel = UIDevice.current.model
var CheckForUpdateDetails = true
let baseUrl = "http://3.84.59.60:8080/v1/"
let SendingFileAck = "SendingFileAck"
var BatteryLevel: Int {
    return Int(round(UIDevice.current.batteryLevel * 100))
}

class userID {
    struct user {
        static var type : Bool!  = UIDevice.current.userInterfaceIdiom == .pad
    }
}
