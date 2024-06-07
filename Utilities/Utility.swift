//
//  Utility.swift
//  smartleveler
//
//  Created by com on 21/01/19.
//  Copyright © 2019 com. All rights reserved.
//

import UIKit

class Utility: NSObject {
    static func updateDetial() {
        let apiServices = ApiServices()
        let params = ["deviceToken" : DeviceToken, "deviceType" :  DeviceModel, "deviceId" :  DeviceId, "osVersion" : Defaults.smartLevellerCurrentVersion, "model" : Defaults.smartLevellerCurrentModelNumber, "appType": "Smart_Leveler"]
        apiServices.postservice(Url: "deviceDetails", params) { (dictionary, error) in
            print(dictionary ?? "")
        }
    }
    
    static func gotoVersionList() {
        AppDelegate.getAppDelegate().navigationController!.popToRootViewController(animated: false)
        let versionUpdate = AppDelegate.getAppDelegate().storyboard?.instantiateViewController(withIdentifier: "VersionUpdateVC") as! VersionUpdateVC
        AppDelegate.getAppDelegate().navigationController!.pushViewController(versionUpdate, animated: false)
    }

}
