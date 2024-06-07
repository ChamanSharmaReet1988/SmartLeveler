//
//  EditReadingViewController.swift
//  smartleveler
//
//  Created by Waheguru on 16/10/18.
//  Copyright © 2018 com. All rights reserved.
//

import Foundation
import UIKit

class EditReadingViewController: UIViewController, UITextFieldDelegate
{
    
    @IBOutlet var tfEv: UITextField!
    @IBOutlet var tfHeight: UITextField!
    var strLocaleId : String!
    var strDate : String!
    var strComment : String!
    var value : [ReadingModel]!
    var strUnit : String! = ""
    @IBOutlet var lblHeight: UILabel!
    
    override func viewDidLoad()
    {
        self.title = "Edit Data"
        
        let saveBarButtonItem = UIBarButtonItem(title: "Save", style: .done, target: self, action: #selector(save))
        self.navigationItem.rightBarButtonItem  = saveBarButtonItem
        
      let value =  ReadingTable().getReading(strLocaleId!)
        tfEv.text = value.evPercentage!
        tfHeight.text = "\(value.height!) \(value.fraction!)"
        strDate = value.dateTime!
        strComment = value.comment!
        strUnit = value.heightUnit!
        lblHeight.text = "HEIGHT (\(strUnit!))"

        print(strLocaleId!)
          let navLabel = UILabel()
        if userID.user.type == true
        {
            navigationItem.rightBarButtonItem?.setTitleTextAttributes([NSAttributedStringKey.font: UIFont.systemFont(ofSize: 25.0, weight: UIFont.Weight.light)], for: UIControlState.normal)
            
            let navTitle = NSMutableAttributedString(string: "", attributes:[
                NSAttributedStringKey.foregroundColor: UIColor.white,
                NSAttributedStringKey.font: UIFont.systemFont(ofSize: 25.0, weight: UIFont.Weight.light)])
            
            navTitle.append(NSMutableAttributedString(string: "", attributes:[
                NSAttributedStringKey.font: UIFont.boldSystemFont(ofSize: 25.0),
                NSAttributedStringKey.foregroundColor: UIColor.white]))
            
            navLabel.attributedText = navTitle
            self.navigationItem.titleView = navLabel
        }
        else
        {
            navigationItem.rightBarButtonItem?.setTitleTextAttributes([NSAttributedStringKey.font: UIFont.systemFont(ofSize: 16.0, weight: UIFont.Weight.light)], for: UIControlState.normal)
            
            let navTitle = NSMutableAttributedString(string: "", attributes:[
                NSAttributedStringKey.foregroundColor: UIColor.white,
                NSAttributedStringKey.font: UIFont.systemFont(ofSize: 16.0, weight: UIFont.Weight.light)])
            
            navTitle.append(NSMutableAttributedString(string: "", attributes:[
                NSAttributedStringKey.font: UIFont.boldSystemFont(ofSize: 16.0),
                NSAttributedStringKey.foregroundColor: UIColor.white]))
            
            navLabel.attributedText = navTitle
            self.navigationItem.titleView = navLabel
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
        self.view.endEditing(true)
        return true
    }
    
    @objc func save()
    {
         self.view.endEditing(true)
        let result = tfHeight.text!.split(separator: " ")
        print(result)
        let readModel = ReadingModel()
        readModel.dateTime = strDate!
        readModel.height = String(result[0]) as String
        readModel.evPercentage = tfEv.text!
        readModel.localId = strLocaleId!
        readModel.comment = strComment!
        readModel.heightUnit = strUnit!
        if result.count > 1
        {
            readModel.fraction = String(result[1]) as String
        }
        else
        {
            readModel.fraction = ""
        }
                
        ReadingTable().updateReading(readingModel: readModel)
        
        self.navigationController?.popViewController(animated: true)
    }
}
