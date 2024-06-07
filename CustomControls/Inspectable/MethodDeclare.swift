//
//  MethodDeclare.swift
//  MedicCoin
//
//  Copyright © 2018 Chaman. All rights reserved.
//

import UIKit

extension UIView {
    @IBInspectable
    var cornerRadius: CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            layer.cornerRadius = newValue
            layer.masksToBounds = newValue > 0
        }
    }
    
    @IBInspectable
    var borderWidth: CGFloat {
        get {
            return layer.borderWidth
        }
        set {
            layer.borderWidth = newValue
        }
    }
    
    @IBInspectable
    var borderColor: UIColor? {
        get {
            let color = UIColor(cgColor: layer.borderColor!)
            return color
        }
        set {
            layer.borderColor = newValue?.cgColor
        }
    }
}

var ScreenWidth: CGFloat {
    set {}
    get {
        return UIScreen.main.bounds.width
    }
}
var ScreenHeight: CGFloat {
    set {}
    get {
        return UIScreen.main.bounds.height
    }
}


