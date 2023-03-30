//
//  UIColor+Extensions.swift
//  
//
//  Created by 尤坤 on 2023/3/30.
//

import UIKit

public extension UIColor {
    var rgba: UInt32 {
        let rgba: UInt32 = (UInt32)(self.rgbaComponents.alpha * 255.0) << 24
        | (UInt32)(self.rgbaComponents.red * 255.0) << 16
        | (UInt32)(self.rgbaComponents.green * 255.0) << 8
        | (UInt32)(self.rgbaComponents.blue * 255.0)
        return rgba
    }
    
    var rgbaComponents: (red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat) {
        var red: CGFloat = 0.0, green: CGFloat = 0.0, blue: CGFloat = 0.0, alpha: CGFloat = 0.0
        self.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        return (red: red, green: green, blue: blue, alpha: alpha)
    }
}
