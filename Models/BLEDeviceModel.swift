//
//  BLEDeviceModel.swift
//  BLEApp
//
//  Created by com on 12/09/18.
//  Copyright © 2018 com. All rights reserved.
//

import UIKit
import CoreBluetooth

class BLEDeviceModel: NSObject {
    var icon: String = "living"
    var name: String?
    var id: String?
    var rssi: String?
    var peripheral: CBPeripheral?
}
