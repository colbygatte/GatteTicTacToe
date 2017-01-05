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
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var xImageView: UIImageView!
    @IBOutlet weak var oImageView: UIImageView!
    @IBOutlet weak var xSelectedImageView: UIImageView!
    @IBOutlet weak var oSelectedImageView: UIImageView!
    
    var gamesLoaded = false
    var gameIds: [String]!
    
    var is_o: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTheme()
        tableView.dataSource = self
        tableView.delegate = self
        gameIds = []
        
        let tapx = UITapGestureRecognizer(target: self, action: #selector(tapped(recognizer:)))
        xImageView.addGestureRecognizer(tapx)
        let tapo = UITapGestureRecognizer(target: self, action: #selector(tapped(recognizer:)))
        oImageView.addGestureRecognizer(tapo)
        oSelectedImageView.alpha = 0.0

        auth()
    }
    
    // Step 1
    func auth() {
        FIRAuth.auth()?.signInAnonymously() { user, error in
            if error == nil && user != nil {
                App.loggedInUid = user!.uid
                self.checkForUsername()
            } else {
                print("Error signing in anonymously.")
            }
        }
    }
    
    // Step 2 -> Will either lead to Step 3, or will be sent to the CreateUsernameViewController
    func checkForUsername() {
        DB.userExists(uid: App.loggedInUid) { username in
            if username != nil {
                App.loggedInUser = GTUser(uid: App.loggedInUid, username: username!)
                self.loadUserData()
            } else {
                self.sendToCreateUsername()
            }
        }
    }
    
    // Step 3
    func loadUserData() {
        DB.ref.child("userData").child(App.loggedInUid).observe(.value, with: { snap in
            let values = snap.value as? [String: Any]
            if let games = values?["games"] as? [String: String] {
                App.loggedInUser.games = games
            } else {
                App.loggedInUser.games = [:]
            }
            self.gameIds = Array(App.loggedInUser.games.values)
            self.displayGames()
            
            if let won = values?["won"] as? [String: Int] {
                App.loggedInUser.won = won
            }
            
            if let lost = values?["lost"] as? [String: Int] {
                App.loggedInUser.lost = lost
            }
        })
    }
    
    // Step 4
    func displayGames() {
        tableView.reloadData()
    }
    
    
    func sendToCreateUsername() {
        let vc = storyboard?.instantiateViewController(withIdentifier: "CreateUsername")
        navigationController?.pushViewController(vc!, animated: true)
    }
    
    func tapped(recognizer: UITapGestureRecognizer) {
        if let imageView = recognizer.view as? UIImageView {
            if imageView == xImageView {
                is_o = false
                animate() {
                    self.xSelectedImageView.alpha = 1.0
                    self.oSelectedImageView.alpha = 0.0
                }
            } else {
                is_o = true
                animate() {
                    self.xSelectedImageView.alpha = 0.0
                    self.oSelectedImageView.alpha = 1.0
                }
            }
        }
    }
    
    func animate(block: @escaping ()->()) {
        UIView.animate(withDuration: TimeInterval(0.2)) { 
            block()
        }
    }
    
    @IBAction func newGameButtonPressed() {
        if let playUser = playUserTextField.text {
            if playUser == App.loggedInUser.username {
                return
            }
            
            DB.userExists(username: playUser, completion: { uid in
                if uid != nil {
                    self.createNewGame(playAgainst: uid!)
                }
            })
        } else {
            
        }
    }
    
    // Here, we check to see if local user already has a game ID with the remote user.
    func createNewGame(playAgainst uid: String) {
        if let gameId = App.loggedInUser.games[uid] {
            goToGame(gameid: gameId)
        } else {
            let gameRef = DB.gamesRef.childByAutoId()
            let game: GTGame
            if self.is_o {
                game = GTGame(id: gameRef.key, localPlayerUid: uid, remotePlayerUid: App.loggedInUser.uid)
            } else {
                game = GTGame(id: gameRef.key, localPlayerUid: App.loggedInUser.uid, remotePlayerUid: uid)
            }
            DB.save(game: game)
            goToGame(gameid: game.id)
        }
    }
    
    
    func goToGame(gameid: String) {
        let sb = UIStoryboard(name: "Game", bundle: nil)
        let vc = sb.instantiateViewController(withIdentifier: "Game") as! GameViewController
        vc.loadGameId = gameid
        navigationController?.pushViewController(vc, animated: true)
    }
}

extension MainViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return gameIds.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let gameId = gameIds[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell")!
        cell.textLabel?.text = gameId
        return cell
    }
}

extension MainViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        goToGame(gameid: gameIds[indexPath.row])
    }
}

extension MainViewController: CreateUsernameViewControllerDelegate {
    func usernameCreated() {
        loadUserData()
    }
}
