//
//  GTGame.swift
//  GTicTacToe
//
//  Created by Colby Gatte on 1/4/17.
//  Copyright © 2017 colbyg. All rights reserved.
//

import UIKit
import Firebase

class GTGame: NSObject {
    var id: String!
    var localPlayer: Int = 0
    var remotePlayer: Int = 0
    
    var localPlayerUid: String!
    var remotePlayerUid: String!
    
    // These are just so the player UID's don't keep switching in the database
    var player1Uid: String!
    var player2Uid: String!
    
    var nextToPlay: String!
    var gameWinner: String?
    
    var playsLeft = 511
    
    let winningCombos = [7, 56, 448, 73, 146, 292, 273, 84]
    
    init(snapshot: FIRDataSnapshot) {
        id = snapshot.key
        
        let values = snapshot.value as! [String: Any]
        playsLeft = values["playsLeft"] as! Int
        
        player1Uid = values["player1Uid"] as! String
        player2Uid = values["player2Uid"] as! String
        nextToPlay = values["nextToPlay"] as! String
        gameWinner = values["gameWinner"] as? String
        
        if player1Uid == App.loggedInUser.uid {
            localPlayerUid = player1Uid
            remotePlayerUid = player2Uid
        } else {
            localPlayerUid = player2Uid
            remotePlayerUid = player1Uid
        }
        
        let players = values["players"] as! [String: Int]
        remotePlayer = players[remotePlayerUid]!
        localPlayer = players[localPlayerUid]!
    }
    
    init(id: String, localPlayerUid: String, remotePlayerUid: String) {
        super.init()
        self.id = id
        self.localPlayerUid = localPlayerUid
        self.remotePlayerUid = remotePlayerUid
        self.player1Uid = localPlayerUid
        self.player2Uid = remotePlayerUid
        coinToss()
    }
    
    override func toFirebaseObject() -> Any? {
        var object: [String: Any] = [:]
        object["player1Uid"] = player1Uid
        object["player2Uid"] = player2Uid
        object["playsLeft"] = playsLeft
        object["nextToPlay"] = nextToPlay
        object["gameWinner"] = gameWinner
        
        var usersObject: [String: Any] = [:]
        usersObject[localPlayerUid] = localPlayer
        usersObject[remotePlayerUid] = remotePlayer
        object["players"] = usersObject
        
        return object
    }
    
    func coinToss() {
        let toss = arc4random_uniform(2)
        if toss == 1 {
            nextToPlay = localPlayerUid
        } else {
            nextToPlay = remotePlayerUid
        }
    }
    
    func play(_ play: Int) -> Bool {
        if playsLeft & play != 0 && nextToPlay == localPlayerUid {
            playsLeft -= play
            localPlayer += play
            nextToPlay = remotePlayerUid
            checkForWinner()
            return true
        }
        return false
    }
    
    func checkForWinner() {
        for combo in winningCombos {
            if localPlayer & combo == combo {
                gameWinner = localPlayerUid
            }
        }
    }
}
