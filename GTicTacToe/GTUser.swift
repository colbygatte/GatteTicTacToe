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
    var games: [GTGame]!
    
    init(snapshot: FIRDataSnapshot) {
        uid = snapshot.key
    }
}
