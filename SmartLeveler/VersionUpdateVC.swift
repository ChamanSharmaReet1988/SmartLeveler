//
//  VersionUpdateVC.swift
//  smartleveler
//
//  Created by Apple on 14/01/19.
//  Copyright © 2019 com. All rights reserved.
//

import UIKit
import NVActivityIndicatorView

class VersionUpdateVC: UIViewController {
    @IBOutlet weak var versionTable: UITableView!
    var dataArray = NSMutableArray()
    var unangedDataArray = NSArray()
    @IBOutlet weak var noFirmwareFoundLabel: UILabel!
    @IBOutlet weak var installView : UIView!
    var overView = UIButton()
    var selectedIndex : Int = 0
    @IBOutlet var progressView : UIProgressView?
    var currentStep : Int = 0
    @IBOutlet weak var percentageLabel : UILabel!

    var sequnce : UInt8 = 1
    var checkForTimer : Int = 0
    var byteArray = [UInt8]()
    var fileSize : Int = 0
    var chunkArray = [[UInt8]]()
    
    override func viewDidLoad() {
        super.viewDidLoad()        
        getVersionList()
        versionTable.tableFooterView = UIView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.shared.isIdleTimerDisabled = true
        BLEService.shared().delegate = self
        setFirmwareArray()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(false)
        UIApplication.shared.isIdleTimerDisabled = false
    }
    
    @IBAction func backBtn(_ sender: Any) {
        _ = navigationController?.popViewController(animated: true)
    }
    
    func openDescripitionAction(index : Int){
        let versionUpdate = self.storyboard?.instantiateViewController(withIdentifier: "VersionDescriptionVC") as! VersionDescriptionVC
        versionUpdate.firmware = dataArray[index] as! Firmware
        versionUpdate.index = index
        self.navigationController?.pushViewController(versionUpdate, animated: true)
    }
    
    func stopTasks(showToast toast:Bool,  message messageString: String) {
        self.view.isUserInteractionEnabled = true
        self.view.hideToastActivity()
        if toast {
            self.view.makeToast(message: messageString)
        }
    }
    
    func startTasks() {
        self.view.isUserInteractionEnabled = false
        self.view.makeToastActivity()
    }
    
    func getVersionList(){
        let urlStr = baseUrl + "listFiles"
        startTasks()
        let apiServices = ApiServices()
        apiServices.getservice(Urlstr:urlStr) { (Result, error) in
            if (error == nil ) {
                self.stopTasks(showToast: false, message: "")
                if Result?.value(forKey: "status") as! String == "OK" {
                    self.unangedDataArray = Result?.value(forKey: "body") as! NSArray
                    self.setFirmwareArray()
                } else {
                    let errorMessage = error?.localizedDescription
                    print(errorMessage!)
                }
                if self.dataArray.count == 0 {
                    self.noFirmwareFoundLabel.isHidden = false
                }
            }
        }
    }
    
    func setFirmwareArray() {
        if unangedDataArray.count == 0 {
            return
        }
        let descriptor: NSSortDescriptor = NSSortDescriptor(key: "createdOn", ascending: false)
        let tempArray = unangedDataArray.sortedArray(using: [descriptor]) as NSArray
        self.dataArray.removeAllObjects()
        for(_, versionDetail) in tempArray.enumerated() {
            let tempDict : NSDictionary = versionDetail as! NSDictionary
            let firmware = Firmware()
            firmware.activity = tempDict["activity"] as! String
            firmware.createdOn = tempDict["createdOn"] as! String
            firmware.longDescription = tempDict["description"] as? String ?? ""
            firmware.fileName = tempDict["fileName"] as! String
            firmware.fileType = tempDict["fileType"] as! String
            firmware.id = String(tempDict["id"] as! Int)
            firmware.isDeleted = String(tempDict["isDeleted"] as! Int)
            firmware.model = tempDict["model"] as? String ?? ""
            firmware.name = tempDict["name"] as? String ?? ""
            firmware.path = tempDict["path"] as? String ?? ""
            firmware.shortDescription = tempDict["sortDescription"] as! String
            firmware.updatedOn = tempDict["updatedOn"] as? String ?? ""
            firmware.version = tempDict["version"] as? String ?? ""
            firmware.webLink = tempDict["webLink"] as? String ?? ""
            let saveFileUtility = SaveFileUtility()
            if saveFileUtility.isFirmwareDownloaded(fileName: firmware.fileName, fileType: firmware.fileType) {
                firmware.downloadStatus = "2"
            } else {
                firmware.downloadStatus = "0"
            }
            self.dataArray.add(firmware)
        }
        self.versionTable.reloadData()
    }
    
    @IBAction func removeInstallView() {
        commandAction(step: 4)
        overView.removeFromSuperview()
        installView.isHidden = true
    }
    
    func showInstallView() {
        overView = UIButton(frame: CGRect(x: 0, y: 0, width: ScreenWidth, height: ScreenHeight))
        overView.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        self.view.addSubview(overView)
        installView.isHidden = false
        self.view.bringSubview(toFront: installView)
        commandAction(step: 0)
    }
    
    func commandAction(step : Int) {
        currentStep = step
        if step == 0 {
            CommandUtility.sendProgramUpdateImage(size: fileSize)
        } else if step == 1 {
            sendingChunks()
        } else if step == 2 {
            CommandUtility.sendWriteChunkCompleteMsg()
        } else if step == 3 {
            CommandUtility.sendProgramCompleteMsg()
        } else if step == 4 {
            CommandUtility.sendCancelProgramMsg()
        }
    }
    
    func sendingChunks() {
        if chunkArray.count == checkForTimer {
            commandAction(step: 2)
            return
        }
        CommandUtility.sendWriteChunkFull(seqNum: sequnce, chunk: chunkArray[checkForTimer])
        if sequnce > 254 {
            sequnce = 0
        } else {
            sequnce = sequnce + 1
        }
        checkForTimer = checkForTimer + 1
        progressView?.progress = Float(Float(checkForTimer)/Float(chunkArray.count))
        let percentage = Float(checkForTimer)/Float(chunkArray.count)*100
        percentageLabel.text = String(format: "%.1f", percentage) + "%"
    }
    
    func installingStart() {
        let firmware : Firmware! = dataArray[selectedIndex] as? Firmware
        percentageLabel.text = "0.00%"
        progressView?.progress = 0.0
        sequnce = 1
        checkForTimer = 0
        byteArray = CommandUtility.getArrayOfBytesFromFile(fileName: firmware.fileName, fileType: firmware.fileType)
        fileSize = byteArray.count
        chunkArray = byteArray.chunked(into: 16)
        showInstallView()
    }
    
    func updateVersion() {
        let firmware : Firmware! = dataArray[selectedIndex] as? Firmware
        Defaults.smartLevellerCurrentVersion = firmware.version
        Defaults.smartLevellerCurrentModelNumber = firmware.model
    }
}

extension VersionUpdateVC : UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell     {
        let cell = tableView.dequeueReusableCell(withIdentifier: "VersionCell") as! VersionCell
        cell.selectionStyle = UITableViewCellSelectionStyle.none
        cell.updateUI(indexPath: indexPath)
        cell.delegate = self
        let firmware : Firmware! = dataArray[indexPath.row] as? Firmware
        cell.versionNumLabel.text = "Version" + " \(firmware.version)"
        cell.detailLabel.text = firmware.shortDescription
        cell.createdDate.text = DateFormatters.timeAgoSinceDate(date: DateFormatters.getDateFromString(dateString: firmware.createdOn)! as NSDate, numericDates: false)
        
        cell.downloadBtn.titleLabel?.font = UIFont.systemFont(ofSize: 15.0)
        if firmware.downloadStatus == "0" {
            cell.downloadBtn.tintColor = UIColor.darkGray
            cell.deleteButton.isHidden = true
        } else if firmware.downloadStatus == "1" {
            cell.downloadBtn.titleLabel?.font = UIFont.systemFont(ofSize: 13.0)
            cell.downloadBtn.tintColor = UIColor(red: 1.0/255.0, green:  182.0/255.0, blue:  238.0/255.0, alpha: 1.0)
            cell.deleteButton.isHidden = true
        } else if firmware.downloadStatus == "2" {
            cell.downloadBtn.tintColor = UIColor(red: 11.0/255.0, green:  102.0/255.0, blue:  35.0/255.0, alpha: 1.0)
            cell.deleteButton.isHidden = false
        } else if firmware.downloadStatus == "2" {
            cell.downloadBtn.tintColor = UIColor.lightGray
            cell.deleteButton.isHidden = false
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        openDescripitionAction(index: indexPath.row)
    }
}

extension VersionUpdateVC: VersionCellDelegate {
    func deleteAction(index: Int) {
        let firmware : Firmware! = dataArray[index] as? Firmware
        let saveFileUtility = SaveFileUtility()
        saveFileUtility.deleteFirmware(fileName: firmware.fileName, fileType: firmware.fileType)
        firmware.downloadStatus = "0"
        dataArray.replaceObject(at: index, with: firmware)
        versionTable.reloadData()
    }
    
    func downloadAction(index: Int) {
        selectedIndex = index
        let firmware : Firmware! = dataArray[index] as? Firmware
        if firmware.downloadStatus == "0" {
            firmware.downloadStatus = "1"
            dataArray.replaceObject(at: index, with: firmware)
            versionTable.reloadData()
            let firmwareDownloadService = FirmwareDownloadService()
            firmwareDownloadService.delegate = self
            firmwareDownloadService.downloadVersion(firmware: firmware, index: index)
        } else if firmware.downloadStatus == "1" {
            firmware.downloadStatus = "0"
            dataArray.replaceObject(at: index, with: firmware)
            versionTable.reloadData()
        } else if firmware.downloadStatus == "2" {
            guard let _ = BLEService.shared().discoveredPeripheral, BLEService.shared().isBluetoothDeviceOn else {
                let alert = UIAlertController(title: "Alert", message: "Please connect your iPhone/iPad to Smart-Leveller first.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (alert) in
                }))
                self.present(alert, animated: true, completion: nil)
                return
            }
            
            UIDevice.current.isBatteryMonitoringEnabled = true
            if BatteryLevel < 40 {
                let alert = UIAlertController(title: "Alert", message: "Please keep your iPhone's battery level more than 40%", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (alert) in
                }))
                self.present(alert, animated: true, completion: nil)
                return
            }
            let alert = UIAlertController(title: "Alert", message: "Do you want to update the firmware?", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "No", style: .default, handler: { (alert) in
            }))
            alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (alert) in
               self.installingStart()
            }))
            self.present(alert, animated: true, completion: nil)
        }
    }
}

extension VersionUpdateVC: FirmwareDownloadServiceDelegate {
    func downloadedDone(index: Int, firmware: Firmware) {
        dataArray.replaceObject(at: index, with: firmware)
        versionTable.reloadData()
    }
}

extension VersionUpdateVC : BLEServiceDelegate {
    func bleDisconnected() {
    }
    
    func updatedData(byteArray: [UInt8]) {
        print(byteArray)
        if byteArray.count < 3 {
            return
        }
        if installView.isHidden {
            return
        }
        if byteArray.contains(211) && currentStep == 0 {
            commandAction(step: 1)
        } else if byteArray.contains(213) && currentStep == 1 {
            sendingChunks()
        } else if byteArray.contains(213) && currentStep == 2 {
            commandAction(step: 3)
        } else if byteArray.contains(215) && currentStep == 3  {
            progressView?.progress = 1.0
            overView.removeFromSuperview()
            installView.isHidden = true
            let alert = UIAlertController(title: "Alert", message: "Firmware successfully installed.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (alert) in
                self.updateVersion()
            }))
            self.present(alert, animated: true, completion: nil)
        } else if byteArray[2] == 223 || byteArray[2] == 216 {
            removeInstallView()
            let alert = UIAlertController(title: "Alert", message: "Installing Failed!", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: { (alert) in
                
            }))
            alert.addAction(UIAlertAction(title: "Try Again", style: .default, handler: { (alert) in
                self.downloadAction(index: self.selectedIndex)
            }))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func bleConnected() {
        
    }
    
    func receivedResponseOfCommands(response: String) {
        
    }
    
    func commandFailed(error: String) {
        
    }
    
    func charactersticsFetched(id: String) {
        
    }
    
    func deviceBluetoothOn(on: Bool) {
        
    }
    
    func updatedDevice() {
    }
}
