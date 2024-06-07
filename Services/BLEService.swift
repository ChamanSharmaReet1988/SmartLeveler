//
//  BLEService.swift
//  BLEApp
//
//  Created by com on 12/09/18.
//  Copyright © 2018 com. All rights reserved.
//

import UIKit
import CoreBluetooth

protocol BLEServiceDelegate {
    func updatedDevice()
    func bleConnected()
    func bleDisconnected()
    func deviceBluetoothOn(on :Bool)
    func updatedData(byteArray : [UInt8])
}

class BLEService: NSObject {
    fileprivate var centralManager: CBCentralManager?
    var discoveredPeripheral: CBPeripheral?
    fileprivate var discoveredCharacteristic: CBCharacteristic?
    var isBLEConnected : Bool = false
    var isBluetoothDeviceOn : Bool = false
    var connectedBLEDeviceModel: BLEDeviceModel?
    private static var bleService: BLEService = {
        let bleService = BLEService()
        return bleService
    }()
    var delegate: BLEServiceDelegate?
    class func shared() -> BLEService {
        return bleService
    }
    var deviceList: [BLEDeviceModel]! = [BLEDeviceModel]()

    override init() {
        super.init()
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }

    func startScan() {
        if centralManager?.state  == .poweredOn {
            centralManager?.scanForPeripherals(
                withServices: nil, options: [
                    CBCentralManagerScanOptionAllowDuplicatesKey : NSNumber(value: true as Bool)
                ]
            )
            print("Scanning started")
            delegate?.deviceBluetoothOn(on: true)
            isBluetoothDeviceOn = true
        } else {
            delegate?.deviceBluetoothOn(on: false)
            isBluetoothDeviceOn = false
        }
    }
    
    func stopScan() {
        centralManager?.stopScan()
    }
    
    func deviceIsExist(bleDeviceModel: BLEDeviceModel) {
        for (index, device) in deviceList.enumerated() {
            if bleDeviceModel.peripheral?.identifier == device.peripheral?.identifier {
                deviceList[index] = bleDeviceModel
                return
            }
        }
        deviceList.append(bleDeviceModel)
    }
    
    func connectPeripheral(bleDeviceModel : BLEDeviceModel) {
        if let _ = discoveredPeripheral {
            centralManager?.cancelPeripheralConnection(discoveredPeripheral!)
        }
        discoveredPeripheral = bleDeviceModel.peripheral
        connectedBLEDeviceModel = bleDeviceModel
        centralManager?.connect(discoveredPeripheral!, options: nil)
    }
    
    func sendMessage(bytesToWrite: [UInt8]) {
        if let _ = discoveredPeripheral {
            let data = Data(bytes: bytesToWrite)
            if discoveredCharacteristic != nil {
                discoveredPeripheral?.writeValue(data, for: discoveredCharacteristic!, type: CBCharacteristicWriteType.withResponse)
            } else {
                print("Failed to Send")
            }
        }
    }
}

extension BLEService: CBCentralManagerDelegate {
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        guard central.state  == .poweredOn else {
            delegate?.deviceBluetoothOn(on: false)
            isBluetoothDeviceOn = false
            discoveredPeripheral = nil
            return
        }
        delegate?.deviceBluetoothOn(on: true)
        isBluetoothDeviceOn = true
        startScan()
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        //print("Discovered \(String(describing: peripheral.name)) at \(RSSI)")
        
        if let _ =  peripheral.name {
            let bleDeviceModel = BLEDeviceModel()
            bleDeviceModel.name = peripheral.name
            bleDeviceModel.peripheral = peripheral
            bleDeviceModel.id = peripheral.identifier.uuidString
            bleDeviceModel.rssi = RSSI.stringValue
            deviceIsExist(bleDeviceModel: bleDeviceModel)
        }
        
        if let _ = delegate {
            delegate?.updatedDevice()
        }
    }
    
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        print("Failed to connect to \(peripheral). (\(error!.localizedDescription))")
        isBLEConnected = false
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("Peripheral Connected")
        delegate?.bleConnected()
        peripheral.delegate = self
        peripheral.discoverServices(nil)
        isBLEConnected = true
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        print("Peripheral Disconnected")
        isBLEConnected = false
        if let _ = delegate {
            delegate?.bleDisconnected()
        }
    }
    
    func centralManager(_ central: CBCentralManager, willRestoreState dict: [String : Any]) {
        
    }
}

extension BLEService: CBPeripheralManagerDelegate, CBPeripheralDelegate {
    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        guard error == nil else {
            print("Error discovering services: \(error!.localizedDescription)")
            return
        }
        
        guard let services = peripheral.services else {
            return
        }
        
        for service in services {
            print(service.uuid.uuidString)
            peripheral.discoverCharacteristics(nil, for: service)
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        guard error == nil else {
            print("Error discovering services: \(error!.localizedDescription)")
            return
        }
        
        guard let characteristics = service.characteristics else {
            return
        }
        discoveredCharacteristic = characteristics[1]

        for characteristic in characteristics {
            print(characteristic)
            if characteristic.properties == CBCharacteristicProperties.notify {
                peripheral.setNotifyValue(true, for: characteristic)
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateNotificationStateFor characteristic: CBCharacteristic, error: Error?) {
        print("Error changing notification state: \(String(describing: error?.localizedDescription))")
        if (characteristic.isNotifying) {
            print("Notification began on \(characteristic)")
        } else {
            print("Notification stopped on (\(characteristic))  Disconnecting")
            centralManager?.cancelPeripheralConnection(peripheral)
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        print("Error characteristic Data: \(String(describing: error?.localizedDescription))")
        if let data = characteristic.value {
            let numberOfBytes = data.count
            var rxByteArray = [UInt8](repeating: 0, count: numberOfBytes)
            (data as NSData).getBytes(&rxByteArray, length: numberOfBytes)
            if let _ = delegate {
                delegate?.updatedData(byteArray: rxByteArray)
            }
        }
    }

    func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
        print(error ?? "")
    }
    
    func peripheral(_ peripheral: CBPeripheral, didModifyServices invalidatedServices: [CBService]) {
        
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverIncludedServicesFor service: CBService, error: Error?) {
        
    }

    func peripheral(_ peripheral: CBPeripheral, didDiscoverDescriptorsFor characteristic: CBCharacteristic, error: Error?) {
        guard error == nil else {
            print("Error discovering services: \(error!.localizedDescription)")
            return
        }
        
        guard let descriptors = characteristic.descriptors else {
            return
        }
        
        for descriptor in descriptors {
            print(descriptor)
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor descriptor: CBDescriptor, error: Error?) {
        
    }
    
}


