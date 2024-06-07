//
//  Defaults.swift
//  RemoteLight
//
//  Created by I&A on 2/5/18.
//  Copyright © 2018 Chaman. All rights reserved.
//

import UIKit

class Defaults: NSObject {
    
    static var appCurrentVersion: String {
        get {
            if let appCurrentVersionString = UserDefaults.standard.object(forKey: "AppCurrentVersion") as? String {
                return appCurrentVersionString
            }
            return ""
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "AppCurrentVersion")
            UserDefaults.standard.synchronize()
        }
    }
    
    static var smartLevellerCurrentVersion: String {
        get {
            if let smartLevellerCurrentVersionString = UserDefaults.standard.object(forKey: "SmartLevellerCurrentVersion") as? String {
                return smartLevellerCurrentVersionString
            }
            return ""
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "SmartLevellerCurrentVersion")
            UserDefaults.standard.synchronize()
        }
    }
    
    static var smartLevellerCurrentModelNumber: String {
        get {
            if let smartLevellerCurrentModelNumberString = UserDefaults.standard.object(forKey: "SmartLevellerCurrentModelNumber") as? String {
                return smartLevellerCurrentModelNumberString
            }
            return ""
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "SmartLevellerCurrentModelNumber")
            UserDefaults.standard.synchronize()
        }
    }
}


