//
//  DB.swift
//  GTicTacToe
//
//  Created by Colby Gatte on 1/4/17.
//  Copyright © 2017 colbyg. All rights reserved.
//

import Foundation
import Firebase

class DB {
    static var ref: FIRDatabaseReference!
    static var gamesRef: FIRDatabaseReference!
    static var usernamesRef: FIRDatabaseReference!
    
    static func save(game: GTGame) {
        DB.gamesRef.child(game.id).setValue(game.toFirebaseObject())
        DB.ref.child("userData").child(game.player1Uid).child("games").child(game.player2Uid).setValue(game.id)
        DB.ref.child("userData").child(game.player2Uid).child("games").child(game.player1Uid).setValue(game.id)
    }
    
    static func delete(game: GTGame) {
        DB.gamesRef.child(game.id).setValue(nil)
        DB.ref.child("userData").child(game.player1Uid).child("games").child(game.player2Uid).setValue(nil)
        DB.ref.child("userData").child(game.player2Uid).child("games").child(game.player1Uid).setValue(nil)
    }
    
    static func save(user: GTUser) {
        DB.usernamesRef.child(user.username).setValue(user.uid)
        DB.ref.child("userData").child(user.uid).child("won").setValue(user.won)
        DB.ref.child("userData").child(user.uid).child("lost").setValue(user.lost)
    }
    
    static func userExists(username: String, completion: @escaping (String?)->()) {
        DB.usernamesRef.queryOrderedByKey().queryEqual(toValue: username).observeSingleEvent(of: .value, with: { snap in
            if let usernameValue = snap.value as? [String: String] {
                completion(usernameValue.first!.value)
            } else {
                completion(nil)
            }
        })
    }

    static func userExists(uid: String, completion: @escaping (String?)->()) {
        DB.usernamesRef.queryOrderedByValue().queryEqual(toValue: uid).observeSingleEvent(of: .value, with: { snap in
            if let usernameValue = snap.value as? [String: String] {
                completion(usernameValue.first!.key)
            } else {
                completion(nil)
            }
        })
    }
    
    static func increaseLost(uid: String) {
        let ref = DB.ref.child("userData").child(uid).child("lost").child(App.loggedInUid)
        ref.observeSingleEvent(of: .value, with: { snap in
            if let lost = snap.value as? Int {
                ref.setValue(lost + 1)
            } else {
                ref.setValue(1)
            }
        })
    }
    
    static func increaseWon(uid: String) {
        let ref = DB.ref.child("userData").child(uid).child("won").child(App.loggedInUid)
        ref.observeSingleEvent(of: .value, with: { snap in
            if let won = snap.value as? Int {
                ref.setValue(won + 1)
            } else {
                ref.setValue(1)
            }
        })
    }
}


extension NSObject {
    func toFirebaseObject() -> Any? {
        return nil
    }
}
