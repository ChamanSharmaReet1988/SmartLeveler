//
//  ColorConstants.swift
//  HueApp
//
//  Copyright © 2018 Chaman. All rights reserved.
//

import UIKit

enum ColorConstants{
    case whiteColor
    case statusBarColor
    case navigationBarColor
    case pinkTextColor
    case lightBlueColor
    case lightGrayBgColor
    case switchOffColor
    case darkGrayColor
    case switchOnBlueColor
    case blackColor
    case bridgeSettingsTextColor
    case noThemeTransparentBlack40
    case noThemeTransparentBlack80

    
    case white(CGFloat)
}

extension ColorConstants {
    var value: UIColor{
        var color: UIColor?
        switch self {
        case .statusBarColor:
            color = UIColor.init(red: 26/255, green: 35/255, blue: 126/255, alpha: 1)
            break
        case .navigationBarColor:
            color = UIColor.init(red: 48/255, green: 63/255, blue: 169/255, alpha: 1)
            break
        case .pinkTextColor:
            color = UIColor.init(red: 252/255, green: 68/255, blue: 130/255, alpha: 1)
            break
        case .lightBlueColor:
            color = UIColor.init(red: 31/255, green: 183/255, blue: 236/255, alpha: 1)
            break
        case .lightGrayBgColor:
            color = UIColor.init(red: 242/255, green: 242/255, blue: 242/255, alpha: 1)
            break
        case .darkGrayColor:
            color = UIColor.init(red: 169/255, green: 168/255, blue: 162/255, alpha: 1)
            break
        case .switchOnBlueColor:
            color = UIColor.init(red: 180/255, green: 233/255, blue: 249/255, alpha: 1)
            break
        case .whiteColor:
            color = UIColor.init(white: 1, alpha: 1)
            break
        case .bridgeSettingsTextColor:
            color = UIColor.init(red: 112/255, green: 111/255, blue: 101/255, alpha: 1)
            break
        case .switchOffColor:
            color = UIColor.init(red: 111/255, green: 110/255, blue: 100/255, alpha: 1)
            break
        case .blackColor:
            color = UIColor.black
            break
        case .noThemeTransparentBlack40:
            color = UIColor.black
            break
        case .noThemeTransparentBlack80:
            color = UIColor.black
            break
        case .white(let alpha):
            color = UIColor.white.withAlphaComponent(alpha)
            break
        }
        return color!
    }
}
