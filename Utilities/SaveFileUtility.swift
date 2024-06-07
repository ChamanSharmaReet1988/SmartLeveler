//
//  SaveFileUtility.swift
//  smartleveler
//
//  Created by com on 21/01/19.
//  Copyright © 2019 com. All rights reserved.
//

import UIKit

class SaveFileUtility: NSObject {
    func getDirectoryPath() -> String {
        var paths: [Any] = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let documentsDir: String? = (paths[0] as? String)
        let folderDir: String = documentsDir! + "/Firmwares"
        return folderDir
    }
    
   func isFirmwareDownloaded(fileName : String, fileType : String) -> Bool {
        let directoryPath = getDirectoryPath()
        let filePath: String = directoryPath + "/\(fileName)\(fileType)"
        let fileManager = FileManager()
        if fileManager.fileExists(atPath: filePath) {
            return true
        } else {
            return false
        }
    }
    
    func deleteFirmware(fileName : String, fileType : String) {
        let fileManager = FileManager()
        let directoryPath = getDirectoryPath()
        let filePath: String = directoryPath + "/\(fileName)\(fileType)"
        do {
            try fileManager.removeItem(atPath: filePath)
        }
        catch let error as NSError {
            print("Ooops! Something went wrong: \(error)")
        }
    }

}
