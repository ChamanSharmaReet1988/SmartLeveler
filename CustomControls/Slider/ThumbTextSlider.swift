//
//  CustomSlider.swift
//  smartleveler
//
//  Created by apple on 07/05/18.
//  Copyright © 2018 com. All rights reserved.
//

import UIKit

class ThumbTextSlider: UISlider {
    
    override func thumbRect(forBounds bounds: CGRect, trackRect rect: CGRect, value: Float) -> CGRect {
        return super.thumbRect(forBounds: bounds, trackRect:rect, value: value)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
}
