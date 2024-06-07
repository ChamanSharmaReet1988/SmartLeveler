//
//  ViewController.swift
//  smartleveler
//
//  Created by com on 07/05/18.
//  Copyright © 2018 com. All rights reserved.
//

import UIKit
import CoreLocation


class ViewController: UIViewController  {
    var locationManager:CLLocationManager!
    
    @IBOutlet var tvComment: UITextView!
    @IBOutlet var readingView: UIView!
    @IBOutlet var evView: UIView!
    @IBOutlet var timeView: UIView!
    @IBOutlet var slider: ThumbTextSlider!
    @IBOutlet var saveReadingButton: UIButton!
    @IBOutlet var timeLabel: UILabel!
    @IBOutlet var svMain: UIScrollView!
    @IBOutlet var inchLabel: UILabel!
    @IBOutlet var tankHeightLabel: UILabel!
    @IBOutlet var minusButton: UIButton!
    var voiceRecognitionOn: Bool = false
    @IBOutlet var micImage: UIImageView!
    @IBOutlet var ivFractionDivider: UIImageView!
    @IBOutlet var lblFraction: UILabel!
    @IBOutlet var viewComment: UIView!
    @IBOutlet var lblHght: UILabel!
    @IBOutlet var lblEv: UILabel!
    var strUnit : String! = ""
    var strPlusMinus : String! = ""
    var fraction : Double!
    var strFraction : String! = ""
    var strSystemMode : Int! = 0
    @IBOutlet var lblFractionCommentV: UILabel!
    @IBOutlet var ivFractionDividerCmnt: UIImageView!
    @IBOutlet var lblUnitComment: UILabel!
    @IBOutlet var lblHghtCmnt: UILabel!
    @IBOutlet weak var optionView: UIView!
    @IBOutlet weak var optionContainerView: UIView!
    var strHghtSave : String!
    var strFractionSave : String!
    var strUnitSave : String!
    var isSelectedMore : Bool = false
    var overButton : UIButton?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        guard let _ = BLEService.shared().discoveredPeripheral else {
            goToScanScreen(animated: true)
            return
        }
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.startUpdatingHeading()
        setupUI()
        viewComment.isHidden = true
        optionView.isHidden = true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewDidLayoutSubviews() {
        if userID.user.type == false {
            svMain.contentSize = CGSize(width: self.view.frame.width, height: 523)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.navigationController?.navigationBar.isHidden = true
        BLEService.shared().delegate = self
        
        let date = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "hh:mm a"
        let hour = dateFormatter.string(from: date)
        timeLabel.text = String(hour)
        Timer.scheduledTimer(timeInterval: 60.0, target: self, selector: #selector(self.timer), userInfo: nil, repeats: true)
    }
    
    @IBAction func moreBtn(_ sender: Any) {
        if isSelectedMore {
            hideOptionView()
        } else {
            showOptionView()
        }
    }
    
    func showOptionView() {
        overButton = UIButton(frame: CGRect(x: 0, y: 0, width: ScreenWidth, height: ScreenHeight))
        overButton!.backgroundColor = UIColor.clear
        overButton!.addTarget(self, action:  #selector(hideOptionView), for: UIControlEvents.touchUpInside)
        self.optionView.superview!.addSubview(overButton!)
        self.optionView.superview!.bringSubview(toFront: self.optionView)
        isSelectedMore = true
        UIView.animate(withDuration: 1.0, delay: 0, options: .curveEaseOut, animations: {
            self.optionView.isHidden = false
        }, completion: { finished in
        })
    }
    
    @objc func hideOptionView() {
        if let _ = overButton {
            overButton?.removeFromSuperview()
        }
        isSelectedMore = false
        UIView.animate(withDuration: 1.0, delay: 0, options: .curveEaseOut, animations: {
            self.optionView.isHidden = true
        }, completion: { finished in
        })
    }
    
    @IBAction func settingsButtonAction(_ sender: Any) {
        hideOptionView()
        let viewController = SettingsView(nibName: "SettingsView", bundle: nil)
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
    @IBAction func firmwereButtonAction(_ sender: Any) {
        hideOptionView()
        let versionUpdate = self.storyboard?.instantiateViewController(withIdentifier: "VersionUpdateVC") as! VersionUpdateVC
        self.navigationController?.pushViewController(versionUpdate, animated: true)
    }
    
    @IBAction func movebackFromComment(_ sender: Any) {
        UIView.transition(with: view, duration: 0.7, options: .transitionFlipFromRight, animations: {
            self.viewComment.isHidden = true
        })
    }
    
    @objc func timer() {
        let date = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "hh:mm a"
        let hour = dateFormatter.string(from: date)
        timeLabel.text = String(hour)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return true
    }
    
    @IBAction func goToScanScreen(animated: Bool = false) {
        hideOptionView()
        let viewController = AddNewDialView(nibName: "AddNewDialView", bundle: nil)
        self.navigationController?.pushViewController(viewController, animated: !animated)
    }
 
    func setupUI() {
        optionContainerView.dropShadow(color: ColorConstants.darkGrayColor.value, opacity: 1.0, offSet: cardLayerOffSet, radius: cardLayerShadow, scale: true)
        timeLabel.text = DateFormatters.getDateString(Date())
        readingView.dropShadow(color: ColorConstants.darkGrayColor.value, opacity: 1.0, offSet: cardLayerOffSet, radius: cardLayerShadow, scale: true)
        evView.dropShadow(color: ColorConstants.darkGrayColor.value, opacity: 1.0, offSet: cardLayerOffSet, radius: cardLayerShadow, scale: true)
        timeView.dropShadow(color: ColorConstants.darkGrayColor.value, opacity: 1.0, offSet: cardLayerOffSet, radius: cardLayerShadow, scale: true)
        slider.dropShadow(color: ColorConstants.darkGrayColor.value, opacity: 1.0, offSet: cardLayerOffSet, radius: cardLayerShadow, scale: true)
    }
    
    @IBAction func SaveRecording(_ sender: Any) {
        saveReadings()
    }
    
    @objc func saveReadings() {
        lblEv.text = "0.0"
        lblHght.text = "\(strPlusMinus!)\(tankHeightLabel.text!)"
        let fraction = strFraction!.replacingOccurrences(of: "/", with: "\n")
        lblFractionCommentV.text = fraction
        lblUnitComment.text = strUnit!
        tvComment.text = ""
        strHghtSave = "\(strPlusMinus!)\(tankHeightLabel.text!)"
        strFractionSave = strFraction!
        strUnitSave = strUnit!
        if strFractionSave != "" {
            if strFractionSave.last! == "\n" {
                ivFractionDividerCmnt.isHidden = true
            } else {
                ivFractionDividerCmnt.isHidden = false
            }
        } else {
            ivFractionDividerCmnt.isHidden = true
        }
        UIView.transition(with: view, duration: 0.7, options: .transitionFlipFromRight, animations: {
            self.viewComment.isHidden = false
        })
    }
    
    @IBAction func saveComment(_ sender: Any) {
        self.view.endEditing(true)
        let readModel = ReadingModel()
        readModel.dateTime = DateFormatters.getDateTimeString(Date())
        readModel.height = strHghtSave!
        readModel.fraction = strFractionSave!
        readModel.evPercentage = "0.0"
        readModel.comment = tvComment.text!
        readModel.heightUnit = strUnitSave!
        
        ReadingTable().saveReading(readingModel: readModel)
        UIView.transition(with: view, duration: 0.7, options: .transitionFlipFromRight, animations: {
            self.viewComment.isHidden = true
        })
    }
    
    @IBAction func saveVoiceOn() {
        VoiceRecognization.shared().voiceRecognizationDelegate = self
        if voiceRecognitionOn {
            VoiceRecognization.shared().stopRecording()
            voiceRecognitionOn = false
            micImage.tintColor = UIColor.lightGray
        } else {
            NotificationCenter.default.addObserver(self, selector: #selector(speechStopedAutomatically), name: Notification.Name("speechstopped"), object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(saveReadings), name: Notification.Name("savereading"), object: nil)
            VoiceRecognization.shared().startRecording()
            voiceRecognitionOn = true
            micImage.tintColor = UIColor(red: 251.0/255.0, green: 115.0/255.0, blue: 34.0/255.0, alpha: 1.0)
        }
    }
    
    @objc func speechStopedAutomatically() {
        self.view.makeToast(message: stopSpeech)
        VoiceRecognization.shared().stopRecording()
        voiceRecognitionOn = false
        micImage.tintColor = UIColor.lightGray
        
        NotificationCenter.default.removeObserver(self, name: Notification.Name("speechstopped"), object: nil)
        NotificationCenter.default.removeObserver(self, name: Notification.Name("savereading"), object: nil)
    }
}

extension ViewController : VoiceRecognizationDelegate {
    func getText(text: String) {
    }
    
    func speechRecognizerAvailability(isEnabled: Bool) {
        if !isEnabled {
            let alert = UIAlertController(title: "Speech recognizer not allowed", message: "You enable the recognizer in Settings", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: {(_ action: UIAlertAction) -> Void in
            }))
            self.present(alert, animated: true, completion: nil)
        }
    }
}

extension ViewController : UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ReadingCell", for: indexPath) as! ReadingCell
        return cell
    }
}

extension ViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
    }
}

extension ViewController : BLEServiceDelegate {
    func bleDisconnected() {
    }
    
    func updatedData(byteArray: [UInt8]) {
        print(byteArray)
        
        //For BLE Information
        if byteArray.contains(UInt8(BLE_Device_Information)) {
            let index = (byteArray as NSArray).index(of: BLE_Device_Information) + 2
            Defaults.smartLevellerCurrentModelNumber = "\(byteArray[index])"
            Defaults.smartLevellerCurrentVersion = "\(byteArray[index + 1]).\(byteArray[index + 2]).\(byteArray[index + 3])"
            if CheckForUpdateDetails {
                Utility.updateDetial()
                CheckForUpdateDetails = false
            }
        }
        
        //For Height Reading
        if byteArray.contains(UInt8(BLE_Tank_Height)) {
            var index = (byteArray as NSArray).index(of: BLE_Tank_Height) + 1
            index = (byteArray as NSArray).index(of: BLE_System_Mode) + 1
            print("System Mode : \(byteArray[index])")
            if byteArray[index] == 0 {
                strSystemMode = 0
                strUnit = "FT"
                lblHghtCmnt.text = "HEIGHT (FT)        :"
                lblFraction.isHidden = false
                ivFractionDivider.isHidden = false
            } else if byteArray[index] == 1 {
                strSystemMode = 1
                strUnit = "INCH"
                lblHghtCmnt.text = "HEIGHT (INCH)       :"
                lblFraction.isHidden = false
                ivFractionDivider.isHidden = false
            } else if byteArray[index] == 2 {
                strSystemMode = 2
                strUnit = "FT"
                lblHghtCmnt.text = "HEIGHT (FT)        :"
                lblFraction.text = ""
                strFraction = ""
                lblFraction.isHidden = false
                ivFractionDivider.isHidden = true
            } else if byteArray[index] == 3 {
                strSystemMode = 3
                strUnit = "INCH"
                lblHghtCmnt.text = "HEIGHT (INCH)       :"
                lblFraction.isHidden = true
                lblFraction.text = ""
                strFraction = ""
                ivFractionDivider.isHidden = true
            } else if byteArray[index] == 4 {
                strSystemMode = 4
                strUnit = "CM"
                lblHghtCmnt.text = "HEIGHT (CM)        :"
                lblFraction.isHidden = true
                lblFraction.text = ""
                strFraction = ""
                ivFractionDivider.isHidden = true
            } else {
                strUnit = ""
                lblHghtCmnt.text = "HEIGHT             :"
                lblFraction.isHidden = true
                lblFraction.text = ""
                strFraction = ""
                ivFractionDivider.isHidden = true
            }
            inchLabel.text = strUnit!
            
            let data = Data(bytes: byteArray)
            print("Hex String : \(data.hexEncodedString())")
            let array = data.hexEncodedString().components(separatedBy: "a2")
            
            if array[1].count > 4 {
                var index = array[1].index(array[1].startIndex, offsetBy: 4)
                var hexString = String(array[1][..<index])
                index = hexString.index(hexString.startIndex, offsetBy: 2)
                let preString = String(hexString[..<index])
                hexString = hexString.replacingOccurrences(of: preString, with: "")
                hexString = hexString + preString
                
                let value2 = Int(UInt16(hexString,radix:16)!)
                print("Value From The Device :  \(value2)")
                var heightReading = value2 > 0x7fff ?  Double(value2 - 0x10000) : Double(value2)
                
                if strSystemMode == 3 {
                    heightReading = heightReading/100.0
                } else if strSystemMode == 2 {
                    heightReading = heightReading/100.0
                    let strHgt = String(heightReading)
                    let aryDecimal = strHgt.components(separatedBy: ".")
                    
                    if aryDecimal.count == 2 {
                        lblFraction.text = "\(aryDecimal[1].prefix(1))\n"
                        strFraction = "\(aryDecimal[1].prefix(1))\n"
                    }
                    if aryDecimal[0].contains("-") {
                        strPlusMinus = "-"
                        minusButton.setTitle("-", for: UIControlState.normal)
                    } else {
                        strPlusMinus = ""
                        minusButton.setTitle("+", for: UIControlState.normal)
                    }
                    let heightReadingString =  aryDecimal[0].replacingOccurrences(of: "-", with: "")
                    
                    let ary = feetToFeetInches((Double(heightReadingString)!)/12)
                    var strHght : String!
                    var aryInch = ary[1].components(separatedBy: ".")
                    var val =  String(aryInch[0].dropLast())
                    if val.count == 1 && ary[0].count == 2 {
                        val = "0\(val)"
                    }
                    if ary.count == 2 {
                        strHght = "\(ary[0]) \(val)"
                    }
                    tankHeightLabel.text = strHght
                } else if strSystemMode == 0 {
                    print("Height Getting: \(heightReading)")
                    heightReading = (Double(heightReading)/100.0)
                    let strHgt = String(heightReading)
                    var aryDecimal = strHgt.components(separatedBy: ".")
                    let decimalNo = "0.\(aryDecimal[1] as String)"
                    fraction = Double(decimalNo)
                    
                    heightReading = Double(aryDecimal[0] as String)!
                    let heightReadingString =  aryDecimal[0].replacingOccurrences(of: "-", with: "")
                    let ary = feetToFeetInches((Double(heightReadingString)!)/12)
                    var strHght : String!
                    var aryInch = ary[1].components(separatedBy: ".")
                    var val =  String(aryInch[0].dropLast())
                    if val.count == 1 && ary[0].count == 2 {
                        val = "0\(val)"
                    }
                    if ary.count == 2 {
                        strHght = "\(ary[0]) \(val)"
                    }
                    tankHeightLabel.text = strHght
                } else if strSystemMode == 1 {
                    heightReading = (Double(heightReading)/100.0)
                    let strHgt = String(heightReading)
                    var aryDecimal = strHgt.components(separatedBy: ".")
                    let decimalNo = "0.\(aryDecimal[1] as String)"
                    fraction = Double(decimalNo)
                    print("Fraction In Decimal : \(String(describing: fraction))")
                    heightReading = Double(aryDecimal[0] as String)!
                    let heightReadingString = String(Int(heightReading)).replacingOccurrences(of: "-", with: "")
                    
                    tankHeightLabel.text  = heightReadingString
                } else if  strSystemMode == 4 {
                    heightReading = (Double(heightReading)/100.0) * 2.54
                }
                if strSystemMode == 0 || strSystemMode == 1 {
                    var heightReadingString = String(Int(heightReading))
                    if String(heightReading).contains("-") {
                        strPlusMinus = "-"
                        minusButton.setTitle("-", for: UIControlState.normal)
                        heightReadingString = heightReadingString.replacingOccurrences(of: "-", with: "")
                    } else {
                        strPlusMinus = ""
                        minusButton.setTitle("+", for: UIControlState.normal)
                    }
                    print("Fraction Getting : \(fraction!)")
                    if 0.03125...0.09375 ~= fraction! {
                        lblFraction.text = "1\n16"
                        strFraction = "1/16"
                        ivFractionDivider.isHidden = false
                    } else if 0.09376...0.15625 ~= fraction! {
                        lblFraction.text = "1\n8"
                        strFraction = "1/8"
                        ivFractionDivider.isHidden = false
                    } else if 0.15626...0.21875 ~= fraction! {
                        lblFraction.text = "3\n16"
                        strFraction = "3/16"
                        ivFractionDivider.isHidden = false
                    } else if 0.21876...0.28125 ~= fraction! {
                        lblFraction.text = "1\n4"
                        strFraction = "1/4"
                        ivFractionDivider.isHidden = false
                    } else if 0.28126...0.34375 ~= fraction! {
                        lblFraction.text = "5\n16"
                        strFraction = "5/16"
                        ivFractionDivider.isHidden = false
                    } else if 0.34376...0.40625 ~= fraction! {
                        lblFraction.text = "3\n8"
                        strFraction = "3/8"
                        ivFractionDivider.isHidden = false
                    } else if 0.40626...0.46875 ~= fraction! {
                        lblFraction.text = "7\n16"
                        strFraction = "7/16"
                        ivFractionDivider.isHidden = false
                    } else if 0.46876...0.53125 ~= fraction! {
                        lblFraction.text = "1\n2"
                        strFraction = "1/2"
                        ivFractionDivider.isHidden = false
                    } else if 0.53126...0.59375 ~= fraction! {
                        lblFraction.text = "9\n16"
                        strFraction = "9/16"
                        ivFractionDivider.isHidden = false
                    } else if 0.59376...0.65625 ~= fraction! {
                        lblFraction.text = "5\n8"
                        strFraction = "5/8"
                        ivFractionDivider.isHidden = false
                    } else if 0.65626...0.71875 ~= fraction! {
                        lblFraction.text = "11\n16"
                        strFraction = "11/16"
                        ivFractionDivider.isHidden = false
                    } else if 0.71876...0.78125 ~= fraction! {
                        lblFraction.text = "3\n4"
                        strFraction = "3/4"
                        ivFractionDivider.isHidden = false
                    } else if 0.78126...0.84375 ~= fraction! {
                        lblFraction.text = "13\n16"
                        strFraction = "13/16"
                        ivFractionDivider.isHidden = false
                    } else if 0.84376...0.90625 ~= fraction! {
                        lblFraction.text = "7\n8"
                        strFraction = "7/8"
                        ivFractionDivider.isHidden = false
                    } else if 0.90626...0.96875 ~= fraction! {
                        lblFraction.text = "15\n16"
                        strFraction = "15/16"
                        ivFractionDivider.isHidden = false
                    } else {
                        lblFraction.text = ""
                        ivFractionDivider.isHidden = true
                    }
                } else if strSystemMode == 3 || strSystemMode == 4 {
                    var heightReadingString = String(heightReading)
                    if heightReadingString.contains("-") {
                        strPlusMinus = "-"
                        minusButton.setTitle("-", for: UIControlState.normal)
                        heightReadingString = heightReadingString.replacingOccurrences(of: "-", with: "")
                    } else {
                        strPlusMinus = ""
                        minusButton.setTitle("+", for: UIControlState.normal)
                    }
                    let aryDecimal = String(heightReadingString).components(separatedBy: ".")
                    
                    if aryDecimal.count == 2 {
                        let lblText  = aryDecimal[1].prefix(1)
                        tankHeightLabel.text = "\(aryDecimal[0]).\(String(lblText))"
                    } else {
                        tankHeightLabel.text = "\(aryDecimal[0])"
                    }
                }
            }
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
    
    typealias Rational = (num : Int, den : Int)
    
    func rationalApproximation(of x0 : Double, withPrecision eps : Double = 1.0E-6) -> (num : Int, den : Int) {
        var x = x0
        var a = x.rounded(.down)
        var (h1, k1, h, k) = (1, 0, Int(a), 1)
        
        while x - a > eps * Double(k) * Double(k) {
            x = 1.0/(x - a)
            a = x.rounded(.down)
            (h1, k1, h, k) = (h, k, h1 + Int(a) * h, k1 + Int(a) * k)
        }
        return (h, k)
    }
    
    func feetToFeetInches(_ value: Double) -> Array<String> {
        let formatter = MeasurementFormatter()
        formatter.unitOptions = .providedUnit
        formatter.unitStyle = .short
        let rounded = value.rounded(.towardZero)
        let feet = Measurement(value: rounded, unit: UnitLength.feet)
        let inches = Measurement(value: value - rounded, unit: UnitLength.feet).converted(to: .inches)
        return ["\(formatter.string(from: feet))", "\(formatter.string(from: inches))"]
    }
}

extension Double {
    
}
