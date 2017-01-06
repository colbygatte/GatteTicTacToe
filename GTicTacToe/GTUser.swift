//
//  GTUser.swift
//  GTicTacToe
//
//  Created by Colby Gatte on 1/4/17.
//  Copyright © 2017 colbyg. All rights reserved.
//

import Foundation
import Firebase

class GTUser: NSObject {
    var uid: String!
    var username: String!
    var games: [String: String]! // OpponentUID: GameID
    
    var won: [String: Int]!
    var lost: [String: Int]!
    
    var totalWon: Int {
        var total = 0
        for num in won.values {
            total += num
        }
        return total
    }
    
    var totalLost: Int {
        var total = 0
        for num in lost.values {
            total += num
        }
        return total
    }
    
    init(uid: String, username: String) {
        self.uid = uid
        self.username = username
        won = [:]
        lost = [:]
        games = [:]
    }
    
    func lost(against: String) {
        if lost[against] != nil {
            lost[against] = lost[against]! + 1
        } else {
            lost[against] = 1
        }
    }
    
    func won(against: String) {
        if won[against] != nil {
            won[against] = won[against]! + 1
        } else {
            won[against] = 1
        }
    }
}
