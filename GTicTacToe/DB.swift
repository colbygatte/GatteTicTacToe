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
    static var usersRef: FIRDatabaseReference!
    static var gamesRef: FIRDatabaseReference!
    static var userRef: FIRDatabaseReference!
    
    static func save(object: NSObject, userPath: String) {
        DB.usersRef.child(App.loggedInUser.uid).child(userPath).setValue(object.toFirebaseObject())
    }
    
    static func save(game: GTGame) {
        DB.gamesRef.child(game.id).setValue(game.toFirebaseObject())
    }
}


extension NSObject {
    func toFirebaseObject() -> Any? {
        return nil
    }
}
