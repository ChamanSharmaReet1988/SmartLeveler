//
//  CommandUtility.swift
//  smartleveler
//
//  Created by com on 27/01/19.
//  Copyright © 2019 com. All rights reserved.
//

import UIKit


class CommandUtility: NSObject {
    static let PBI_CMD_LEN : Int = 6
    static let WC_OH_LEN : Int = 3
    static let WCF_OH_LEN : Int = 3
    static let WA_PKT_LEN : Int = 9
    
    static func sendProgramUpdateImage(size : Int) {
        var bytesToWrite = [UInt8]()
        bytesToWrite.append(0x5A)
        bytesToWrite.append(0xA5)
        bytesToWrite.append(0x0A)
        bytesToWrite.append(0xD2)
        bytesToWrite.append(UInt8(size>>24 & 0xFF))
        bytesToWrite.append(UInt8(size>>16 & 0xFF))
        bytesToWrite.append(UInt8(size>>8 & 0xFF))
        bytesToWrite.append(UInt8(size & 0xFF))
        let checksum : Int = getChecksum(byteArray: bytesToWrite)
        bytesToWrite.append(UInt8(checksum>>8 & 0xFF))
        bytesToWrite.append(UInt8(checksum & 0xFF))
        BLEService.shared().sendMessage(bytesToWrite: bytesToWrite)
    }
    
    static func sendWriteChunkFull(seqNum : UInt8, chunk : [UInt8]) {
        var bytesToWrite = [UInt8]()
        bytesToWrite.append(0xDE)
        bytesToWrite.append(UInt8(WC_OH_LEN + chunk.count))
        bytesToWrite.append(seqNum)
        bytesToWrite.append(contentsOf: chunk)
        BLEService.shared().sendMessage(bytesToWrite: bytesToWrite)
    }

    static func sendWriteChunkCompleteMsg() {
        var bytesToWrite = [UInt8]()
        bytesToWrite.append(0x5A)
        bytesToWrite.append(0xA5)
        bytesToWrite.append(0x06)
        bytesToWrite.append(0xDD)
        let checksum : Int = getChecksum(byteArray: bytesToWrite)
        bytesToWrite.append(UInt8(checksum>>8 & 0xFF))
        bytesToWrite.append(UInt8(checksum & 0xFF))
        BLEService.shared().sendMessage(bytesToWrite: bytesToWrite)
    }
    
    static func sendProgramCompleteMsg() {
        var bytesToWrite = [UInt8]()
        bytesToWrite.append(0x5A)
        bytesToWrite.append(0xA5)
        bytesToWrite.append(0x06)
        bytesToWrite.append(0xD6)
        let checksum : Int = getChecksum(byteArray: bytesToWrite)
        bytesToWrite.append(UInt8(checksum>>8 & 0xFF))
        bytesToWrite.append(UInt8(checksum & 0xFF))
        BLEService.shared().sendMessage(bytesToWrite: bytesToWrite)
    }
    
    static func sendCancelProgramMsg() {
        var bytesToWrite = [UInt8]()
        bytesToWrite.append(0x5A)
        bytesToWrite.append(0xA5)
        bytesToWrite.append(0x06)
        bytesToWrite.append(0xDB)
        let checksum : Int = getChecksum(byteArray: bytesToWrite)
        bytesToWrite.append(UInt8(checksum>>8 & 0xFF))
        bytesToWrite.append(UInt8(checksum & 0xFF))
        BLEService.shared().sendMessage(bytesToWrite: bytesToWrite)
    }
    
    static func getChecksum(byteArray : [UInt8]) -> Int {
        var trancatedByteArray = byteArray
        trancatedByteArray.removeFirst()
        trancatedByteArray.removeFirst()
        trancatedByteArray.removeFirst()
        return trancatedByteArray.map { Int($0) }.reduce(0, +)
    }
    
    static func getArrayOfBytesFromFile(fileName : String,  fileType : String) -> [UInt8] {
        let saveFileUtility = SaveFileUtility()
        let path = "\(saveFileUtility.getDirectoryPath())/\(fileName)\(fileType)"
        var fileData = Data()
        if FileManager.default.fileExists(atPath: path){
            fileData = NSData(contentsOfFile: path)! as Data
            print(fileData)
        }
        let bytes : [UInt8] = [UInt8](fileData)
        return bytes
    }
}
