//
//  UIColorConverter.swift
//  TrackerApp
//
//  Created by Ilya Kalin on 23.11.2024.
//

import UIKit

final class UIColorConverter {
    static func hexString(from color: UIColor) -> String {
        let components = color.cgColor.components
        let r: CGFloat = components?[0] ?? 0.0
        let g: CGFloat = components?[1] ?? 0.0
        let b: CGFloat = components?[2] ?? 0.0
        return String.init(
            format: "%02lX%02lX%02lX",
            lroundf(Float(r * 255)),
            lroundf(Float(g * 255)),
            lroundf(Float(b * 255))
        )
    }

    static func color(from hex: String) -> UIColor {
        var rgbValue:UInt64 = 0
        Scanner(string: hex).scanHexInt64(&rgbValue)
        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
    
    func isEqual(color1: UIColor, to color2: UIColor) -> Bool {
        let hex1 = UIColorConverter.hexString(from: color1)
        let hex2 = UIColorConverter.hexString(from: color2)
        if hex1 == hex2 {
            return true
        }
        return false
    }
}
