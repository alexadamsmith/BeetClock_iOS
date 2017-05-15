//
//  ColorBank.swift
//  BeetClock_A1
//
//  Created by Alex Smith on 12/5/16.
//  Copyright © 2016 BeetWorks. All rights reserved.
//

import Foundation

class ColorBank {
    
    func GetUIColor(_ colorString: String) -> UIColor {
        var rgbValue = UInt()
        
        
        if colorString == "background" {rgbValue = 0xC8C582}
        if colorString == "navbar" {rgbValue = 0x682243}
        if colorString == "crop" {rgbValue = 0x86895C}
        if colorString == "job" {rgbValue = 0x879087}
        if colorString == "implement" {rgbValue = 0xD1A539}
        if colorString == "tractor" {rgbValue = 0xE1561C}
        
        
        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
    
}
