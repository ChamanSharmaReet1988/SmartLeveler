//
//  FirmwareDownloadService.swift
//  smartleveler
//
//  Created by com on 16/01/19.
//  Copyright © 2019 com. All rights reserved.
//

import UIKit
import Alamofire

protocol FirmwareDownloadServiceDelegate {
    func downloadedDone(index : Int, firmware : Firmware)
}

class FirmwareDownloadService: NSObject {
    var delegate: FirmwareDownloadServiceDelegate?
    var currentIndex: Int?
    var currentFirmware: Firmware?

    @objc func downloadVersion(firmware : Firmware, index : Int) {
        currentFirmware = firmware
        currentIndex = index
        let destination: DownloadRequest.DownloadFileDestination = { _, _ in
            let saveFileUtility = SaveFileUtility()
            let path = "\(saveFileUtility.getDirectoryPath())/\(firmware.fileName)\(firmware.fileType)"
            return (URL(fileURLWithPath: path), [.removePreviousFile, .createIntermediateDirectories])
        }
        let url = "\(baseUrl)download?id=\(firmware.id)"
        Alamofire.download(url, to: destination).response { response in
            print(response)
            self.currentFirmware?.downloadStatus = "2"
            self.delegate?.downloadedDone(index: self.currentIndex!, firmware: self.currentFirmware!)
        }
    }
}
