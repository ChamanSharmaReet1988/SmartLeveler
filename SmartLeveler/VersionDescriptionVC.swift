//
//  VersionDescriptionVC.swift
//  smartleveler
//
//  Created by Apple on 14/01/19.
//  Copyright © 2019 com. All rights reserved.
//

import UIKit

class VersionDescriptionVC: UIViewController {
    @IBOutlet weak var versionLabel: UILabel!
    @IBOutlet weak var fileNameLabel: UILabel!
    @IBOutlet weak var updatedOn: UILabel!
    @IBOutlet weak var fileType: UILabel!
    @IBOutlet weak var descriptionlabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    var firmware = Firmware()
    @IBOutlet var myScrollView : UIScrollView?
    @IBOutlet weak var downloadButton: UIButton?
    var index  : Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    func setupUI(){
        titleLabel.text = "VERSION \(firmware.version)"
        versionLabel.text = "Version: \(firmware.version)"
        fileNameLabel.text = "File Name: \(firmware.fileName)"
        fileType.text = "File Type: \(firmware.fileType)"
        let date = DateFormatters.getDateFromString(dateString: firmware.createdOn)
        let dateString = DateFormatters.getDateStringFromString(date: date!, dateFormat: "dd MMM, yyyy")
        updatedOn.text = "Created On: \(dateString)"
        descriptionlabel.text = "Description: \(firmware.longDescription)"
        
        versionLabel .sizeToFit()
        fileNameLabel .sizeToFit()
        fileType .sizeToFit()
        updatedOn .sizeToFit()
        descriptionlabel .sizeToFit()
        
        fileNameLabel.frame.origin.y = versionLabel.frame.origin.y + versionLabel.frame.size.height + 10
        fileType.frame.origin.y = fileNameLabel.frame.origin.y + fileNameLabel.frame.size.height + 10
        updatedOn.frame.origin.y = fileType.frame.origin.y + fileType.frame.size.height + 10
        descriptionlabel.frame.origin.y = updatedOn.frame.origin.y + updatedOn.frame.size.height + 10
        
        myScrollView?.contentSize = CGSize(width: ScreenWidth, height: descriptionlabel.frame.origin.y + descriptionlabel.frame.size.height + 10)
        checkButtonStatus()
    }
    
    @IBAction func backBtn(_ sender: Any) {
        _ = navigationController?.popViewController(animated: true)
    }
    
    func checkButtonStatus() {
        if firmware.downloadStatus == "0" {
            downloadButton!.tintColor = UIColor.white
        } else if firmware.downloadStatus == "1" {
            downloadButton!.tintColor = UIColor(red: 1.0/255.0, green:  182.0/255.0, blue:  238.0/255.0, alpha : 1.0)
        } else if firmware.downloadStatus == "2" {
            downloadButton!.tintColor = UIColor(red: 11.0/255.0, green:  102.0/255.0, blue:  35.0/255.0, alpha: 1.0)
        } else if firmware.downloadStatus == "2" {
        }
    }
    
    @IBAction func downloadAction(index: Int) {
        if firmware.downloadStatus == "0" {
            firmware.downloadStatus = "1"
            let firmwareDownloadService = FirmwareDownloadService()
            firmwareDownloadService.delegate = self
            firmwareDownloadService.downloadVersion(firmware: firmware, index: index)
        } else if firmware.downloadStatus == "1" {
            firmware.downloadStatus = "0"
        } else if firmware.downloadStatus == "2" {
        }
        checkButtonStatus()
    }
}

extension VersionDescriptionVC: FirmwareDownloadServiceDelegate {
    func downloadedDone(index: Int, firmware: Firmware) {
        self.firmware.downloadStatus = "2"
        checkButtonStatus()
    }
}
