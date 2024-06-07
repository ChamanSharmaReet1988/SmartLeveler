//
//  ViewReadingViewController.swift
//  smartleveler
//
//  Created by Waheguru on 15/10/18.
//  Copyright © 2018 com. All rights reserved.
//

import Foundation
import UIKit

class ViewReadingViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet var tvReadings: UITableView!
    var aryReadings = [ReadingModel]()
    let readTable = ReadingTable()
    var strFileName : String!
    
    @IBOutlet var wvViewExcel: UIWebView!
    @IBOutlet var viewExcelButton : UIButton?
    
    override func viewDidLoad() {
        viewExcelButton?.setTitle("View Excel", for: UIControlState.normal)
        tvReadings.rowHeight = UITableViewAutomaticDimension
        tvReadings.estimatedRowHeight = UITableViewAutomaticDimension
        
        UIView.transition(with: view, duration: 0.7, options: .transitionFlipFromRight, animations: {
            self.wvViewExcel.isHidden = true
        })
    }
    
    override func viewWillAppear(_ animated: Bool)     {
        aryReadings = readTable.getReadings()
        tvReadings.dataSource = self
        tvReadings.delegate = self
        tvReadings.reloadData()
    }
    
    @IBAction func moveBack() {
        if wvViewExcel.isHidden == false {
            self.title = "Readings"
            viewExcelButton?.setTitle("View Excel", for: UIControlState.normal)
            UIView.transition(with: view, duration: 0.7, options: .transitionFlipFromRight, animations: {
                self.wvViewExcel.isHidden = true
            })
        } else {
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    @IBAction func exportAndViewExcel() {
        let fileName  = "savereading.csv"
        let path = NSURL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(fileName)
        if viewExcelButton?.title(for: UIControlState.normal) == "View Excel" {
            viewExcelButton?.setTitle("Send Excel", for: UIControlState.normal)
            UIView.transition(with: view, duration: 0.7, options: .transitionFlipFromRight, animations: {
                self.wvViewExcel.isHidden = false
            })
            
            var csvText = "Date-Time,Height,% of EV,Comment\n"
            
            if aryReadings.count > 0 {
                for result in aryReadings {
                    let commentArray : [String] = result.comment!.components(separatedBy: "\n")
                    let commentText = commentArray.joined(separator:" ")
                    let fraction = result.fraction!.replacingOccurrences(of: "\n", with: " ")
                    let hgt = "\(result.height!) \(fraction) \(result.heightUnit!)"
                    let newLine = "\(String(describing: result.dateTime!)),\(String(describing: hgt)),\(String(describing: result.evPercentage!)),\(commentText)\n"
                    csvText.append(newLine)
                }
                do {
                    try csvText.write(to: path!, atomically: true, encoding: String.Encoding.utf8)
                    
                    
                    let urlrequest : URLRequest! = URLRequest(url: path!)
                    print(urlrequest)
                    wvViewExcel.loadRequest(urlrequest!)
                    
                } catch {
                    
                    print("Failed to create file")
                    print("\(error)")
                }
            } else {
                if let clearURL = URL(string: "about:blank")
                {
                    wvViewExcel.loadRequest(URLRequest(url: clearURL))
                }
                self.view.makeToast(message: "Error! There is no data to export.")
            }
        } else {
            if userID.user.type == true {
                let activityVC = UIActivityViewController(activityItems: [path!], applicationActivities: [])
                activityVC.excludedActivityTypes = [
                    UIActivityType.assignToContact,
                    UIActivityType.saveToCameraRoll,
                    UIActivityType.postToFlickr,
                    UIActivityType.postToVimeo,
                    UIActivityType.postToTencentWeibo,
                    UIActivityType.postToTwitter,
                    UIActivityType.postToFacebook,
                    UIActivityType.openInIBooks
                ]
                present(activityVC, animated: true, completion: nil)
                if let popOver = activityVC.popoverPresentationController
                {
                    popOver.sourceView = self.view
                }
            } else {
                let vc = UIActivityViewController(activityItems: [path!], applicationActivities: [])
                vc.excludedActivityTypes = [
                    UIActivityType.assignToContact,
                    UIActivityType.saveToCameraRoll,
                    UIActivityType.postToFlickr,
                    UIActivityType.postToVimeo,
                    UIActivityType.postToTencentWeibo,
                    UIActivityType.postToTwitter,
                    UIActivityType.postToFacebook,
                    UIActivityType.openInIBooks
                ]
                present(vc, animated: true, completion: nil)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return aryReadings.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "viewreading") as! ViewReadingTableViewCell?
        
        cell?.lblHeight.text! = "\(String(describing: aryReadings[indexPath.row].height!))"
        if aryReadings[indexPath.row].fraction! != "" {
            let swiftyString = (aryReadings[indexPath.row].fraction!).replacingOccurrences(of: "/", with: "\n")
            cell?.lblFraction.text! = "\(String(describing: swiftyString))"
        } else {
            cell?.lblFraction.text! = ""
        }
        
        cell?.lblUnit.text! = "\(String(describing: aryReadings[indexPath.row].heightUnit!))"
        cell?.lblPercentage.text! = "\(String(describing: aryReadings[indexPath.row].evPercentage!)) %"
        cell?.lblDateTime.text! = "\(String(describing: aryReadings[indexPath.row].dateTime!))"
        cell?.lblComment.text! = "\(String(describing: aryReadings[indexPath.row].comment!))"
        print(aryReadings[indexPath.row].comment!)
        cell!.selectionStyle = .none
        
        if  aryReadings[indexPath.row].fraction! != "" {
                if aryReadings[indexPath.row].fraction!.last! == "\n" {
                    cell?.ivFraction.isHidden = true
                } else {
                    cell?.ivFraction.isHidden = false
                }
        } else {
            cell?.ivFraction.isHidden = true
        }
        return cell!
    }
    
    func tableView(_ tableView: UITableView,
                   trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        // Write action code for the trash
        let deleteAction = UIContextualAction(style: .normal, title:  "Delete", handler: { (ac:UIContextualAction, view:UIView, success:(Bool) -> Void) in
            
            ReadingTable().deleteTableByLocalId(localId: self.aryReadings[indexPath.row].localId!)
            self.aryReadings  =  self.readTable.getReadings()
            self.tvReadings.reloadData()
            print("Update action ...")
            success(true)
        })
        deleteAction.backgroundColor = .red
        
        // Write action code for the Flag
        let editAction = UIContextualAction(style: .normal, title:  "Edit", handler: { (ac:UIContextualAction, view:UIView, success:(Bool) -> Void) in
            success(true)
            let cntrEdit = self.storyboard?.instantiateViewController(withIdentifier: "edit") as! EditReadingViewController
            cntrEdit.strLocaleId = self.aryReadings[indexPath.row].localId!
            self.navigationController?.pushViewController(cntrEdit, animated: true)
        })
        editAction.backgroundColor = .darkGray
        
        return UISwipeActionsConfiguration(actions: [deleteAction, editAction])
    }
}

class ViewReadingTableViewCell: UITableViewCell {
    @IBOutlet var lblDateTime: UILabel!
    @IBOutlet var lblPercentage: UILabel!
    @IBOutlet var lblHeight: UILabel!
    @IBOutlet var lblComment: UILabel!
    @IBOutlet var lblFraction: UILabel!
    @IBOutlet var lblUnit: UILabel!
    @IBOutlet var ivFraction: UIImageView!
}
