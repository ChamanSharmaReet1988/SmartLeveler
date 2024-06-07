//
//  SettingsView.swift
//  smartleveler
//
//  Created by com on 22/01/19.
//  Copyright © 2019 com. All rights reserved.
//

import UIKit

class SettingsView: UIViewController {
    @IBOutlet weak var versionLabel: UILabel!
    @IBOutlet weak var modelNumberLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    @IBAction func backBtn(_ sender: Any) {
        _ = navigationController?.popViewController(animated: true)
    }

    func setupUI() {
        versionLabel.text = "Firmware Version: \(Defaults.smartLevellerCurrentVersion)"
        modelNumberLabel.text = "Model Number: \(Defaults.smartLevellerCurrentModelNumber)"
    }
}
