//
//  MainViewController.swift
//  GTicTacToe
//
//  Created by Colby Gatte on 1/3/17.
//  Copyright © 2017 colbyg. All rights reserved.
//

import UIKit
import Firebase

class MainViewController: UIViewController {
    @IBOutlet weak var playUserTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTheme()

        FIRAuth.auth()?.signInAnonymously() { user, error in
            if error == nil && user != nil {
                DB.usersRef.child(user!.uid).observeSingleEvent(of: .value, with: { snap in
                    App.loggedInUser = GTUser(snapshot: snap)
                    DB.userRef = DB.usersRef.child(App.loggedInUser.uid)
                    self.begin()
                })
            } else {
                print("Error signing in anonymously.")
            }
        }
    }
    
    func begin() {
        
    }
    
    @IBAction func newGameButtonPressed() {
        if let playUser = playUserTextField.text {
            //let game = GTGame(id: "whatever", localPlayerUid: App.loggedInUser.uid, remotePlayerUid: playUser)
            //DB.gamesRef.child(game.id).setValue(game.toFirebaseObject())
            
            let sb = UIStoryboard(name: "Game", bundle: nil)
            let vc = sb.instantiateViewController(withIdentifier: "Game") as! GameViewController
            vc.loadGameId = "whatever"
            navigationController?.pushViewController(vc, animated: true)
        } else {
            let sb = UIStoryboard(name: "Game", bundle: nil)
            let vc = sb.instantiateViewController(withIdentifier: "Game") as! GameViewController
            navigationController?.pushViewController(vc, animated: true)
        }
    }
}
