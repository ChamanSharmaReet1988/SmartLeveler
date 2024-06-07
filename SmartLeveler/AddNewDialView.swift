//
//  AddNewDialView.swift
//  BLEApp
//
//  Created by com on 07/09/18.
//  Copyright © 2018 com. All rights reserved.
//

import UIKit

class AddNewDialView: UIViewController
{
    @IBOutlet var myCollectionView : UICollectionView!
    @IBOutlet var scanView : UIView!
    @IBOutlet var ivLogo: UIImageView!
    @IBOutlet var consIvWidth: NSLayoutConstraint!
    @IBOutlet var consIvHeight: NSLayoutConstraint!
    
    
    override func viewDidLoad()     {
        super.viewDidLoad()
        self.myCollectionView.register(UINib(nibName:"NewDialCell", bundle: nil), forCellWithReuseIdentifier: "NewDialCell")
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(true)
        
        if userID.user.type == true
        {
            consIvHeight.constant = 57
            consIvWidth.constant = 416
        }
        self.navigationController?.navigationBar.isHidden = true
        
        BLEService.shared().startScan()
        BLEService.shared().delegate = self
        checkBluetoothOn(isOn: BLEService.shared().isBluetoothDeviceOn)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidDisappear(_ animated: Bool)
    {
        super.viewDidDisappear(animated)
        BLEService.shared().stopScan()
    }
    
    @IBAction func backAction()
    {
        self.navigationController?.popViewController(animated: true)
    }
    
    func stopTasks(showToast toast:Bool,  message messageString: String) {
        self.view.isUserInteractionEnabled = true
        self.view.hideToastActivity()
        if toast {
            self.navigationController?.view.makeToast(message:messageString)
        }
    }
    
    func startTasks(message: String)
    {
        self.view.isUserInteractionEnabled = false
        self.view.makeToastActivity(position: ToastPositionCenter as AnyObject, message: message)
    }
    
    func checkBluetoothOn(isOn : Bool)
    {
        if isOn {
            scanView.isHidden = false
        } else {
            scanView.isHidden = true
            self.view.makeToast(message: BluetoothNotOn)
        }
    }
}

extension AddNewDialView : BLEServiceDelegate
{
    func bleDisconnected()
    {
    }
    
    func updatedData(byteArray: [UInt8]) {        
    }
    
    func deviceBluetoothOn(on: Bool) {
        if on {
            scanView.isHidden = false
        } else {
            scanView.isHidden = true
            self.view.makeToast(message: BluetoothNotOn)
        }
    }
    
    func charactersticsFetched(id: String) {
    }
    
    func commandFailed(error: String) {
    }
    
    func receivedResponseOfCommands(response: String) {
    }
    
    func bleConnected()
    {
        stopTasks(showToast: false, message: "")
        backAction()
    }
    
    func updatedDevice()
    {
        myCollectionView.reloadData()
    }
}

extension AddNewDialView: UICollectionViewDataSource, UICollectionViewDelegate
{
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "NewDialCell", for: indexPath) as! NewDialCell
        cell.tag = indexPath.row
        cell.numberLabel?.text = BLEService.shared().deviceList[indexPath.row].name
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return BLEService.shared().deviceList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if BLEService.shared().isBluetoothDeviceOn {
            startTasks(message: "Connecting...")
            BLEService.shared().connectPeripheral(bleDeviceModel:BLEService.shared().deviceList[indexPath.row])
        } else {
            self.view.makeToast(message: BluetoothNotOn)
        }
    }
}
