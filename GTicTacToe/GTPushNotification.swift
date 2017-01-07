//
//  GTPushNotification.swift
//  GTicTacToe
//
//  Created by Colby Gatte on 1/6/17.
//  Copyright © 2017 colbyg. All rights reserved.
//

import Foundation

struct GTPushNotifications {
    static var apnTokens: [String: String] = [:]
    
    // Contacts the remote server that
    // will send the push notification
    static func sendNotification(apnToken: String, message: String) {
        let itemTeamid = URLQueryItem(name: "apnToken", value: apnToken)
        let itemMessage = URLQueryItem(name: "message", value: message)
        
        var url = URLComponents(string: "http://colbygatte.com/whatever/gattetictactoe_apn.cgi")
        url?.queryItems = [itemTeamid, itemMessage]
        
        let task = URLSession.shared.dataTask(with: (url?.url)!) { data, response, error in
            if error == nil {
                print("success!")
            } else {
                print(error ?? "error occured")
            }
        }
        task.resume()
    }
    
    // Gets the APN Token for the user we are sending a mesage to,
    // then calls the above sendNotification method.
    // Stores tokens in GTPushNotification.apnTokens
    // to reuse them.
    static func sendNotifaction(toUid: String, message: String) {
        if let apnToken = GTPushNotifications.apnTokens[toUid] {
            GTPushNotifications.sendNotification(apnToken: apnToken, message: message)
        } else {
            DB.ref.child("apnTokens").child(toUid).observeSingleEvent(of: .value, with: { snap in
                if let apnToken = snap.value as? String {
                    GTPushNotifications.apnTokens[toUid] = apnToken
                    GTPushNotifications.sendNotification(apnToken: apnToken, message: message)
                }
            })
        }
    }
}
