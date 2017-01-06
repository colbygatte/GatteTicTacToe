//
//  App.swift
//  GTicTacToe
//
//  Created by Colby Gatte on 1/3/17.
//  Copyright © 2017 colbyg. All rights reserved.
//

import UIKit

struct App {
    static var loggedInUser: GTUser!
    static var loggedInUid: String!
    static var apnToken: String!
    
    struct Theme {
        static var viewBackgroundColor = UIColor.hexString(hex: "91A7B3")
        static var tintColor = UIColor.black
        static var navBarColor = UIColor.lightGray
    }
    
    static func setupTheme() {
        UIApplication.shared.delegate?.window??.tintColor = App.Theme.tintColor
        UILabel.appearance().font = UIFont(name: "OpenSans", size: 16.0)
        UINavigationBar.appearance().barTintColor = App.Theme.navBarColor
        
        //UIView.appearance().backgroundColor = App.Theme.viewBackgroundColor
    }
}

extension UIViewController {
    func setupTheme() {
        view.backgroundColor = App.Theme.viewBackgroundColor
    }
}

// below from http://stackoverflow.com/questions/24263007/how-to-use-hex-colour-values-in-swift-ios
extension UIColor {
    static func hexString(hex: String) -> UIColor {
        var cString:String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        
        if (cString.hasPrefix("#")) {
            cString.remove(at: cString.startIndex)
        }
        
        if ((cString.characters.count) != 6) {
            return UIColor.gray
        }
        
        var rgbValue: UInt32 = 0
        Scanner(string: cString).scanHexInt32(&rgbValue)
        
        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
}
