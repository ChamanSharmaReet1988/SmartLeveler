//
//  FontUtility.swift
//  HueApp
//
//  Copyright © 2018 Chaman. All rights reserved.
//

import UIKit

class FontUtility {
    fileprivate enum FontNames: String{
        case light = "Roboto-Light"
        case regular = "Roboto-Regular"
        case medium = "Roboto-Medium"
        case bold = "Roboto-Bold"
        case black = "Roboto-Black"
        case ultraLight = "Roboto-Ultralight"
        case thin = "Roboto-Thin"
        case semibold = "Roboto-Semibold"
    }
    
    enum FontSize: CGFloat{
        case h0 = 24.0
        case h1 = 22.0
        case h2 = 20.0
        case h3 = 18.0
        case h4 = 16.0
        case h5 = 14.0
        case h6 = 12.0
        case h7 =  6.0
    }
    
    static func lightFontWithSize(size: FontSize) -> UIFont {
        return UIFont(name: FontNames.light.rawValue, size: size.rawValue)!
    }
    
    static func regularFontWithSize(size: FontSize) -> UIFont {
        return UIFont(name: FontNames.regular.rawValue, size: size.rawValue)!
    }
    
    static func mediumFontWithSize(size: FontSize) -> UIFont {
        return UIFont(name: FontNames.medium.rawValue, size: size.rawValue)!
    }
    
    static func boldFontWithSize(size: CGFloat) -> UIFont {
        return UIFont(name: FontNames.bold.rawValue, size: size)!
    }
    
    static func blackFontWithSize(size: CGFloat) -> UIFont {
        return UIFont(name: FontNames.black.rawValue, size: size)!
    }
    
    static func ultraLightFontWithSize(size: CGFloat) -> UIFont {
        return UIFont(name: FontNames.medium.rawValue, size: size)!
    }
    
    static func thinFontWithSize(size: CGFloat) -> UIFont {
        return UIFont(name: FontNames.semibold.rawValue, size: size)!
    }
    
    static func semiBoldFontWithSize(size: CGFloat) -> UIFont {
        return UIFont(name: FontNames.semibold.rawValue, size: size)!
    }

    
}
