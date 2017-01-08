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
    @IBOutlet weak var winsLabel: UILabel!
    @IBOutlet weak var lossesLabel: UILabel!
    
    var gamesLoaded = false
    var gameIds: [String]!
    var opponentUids: [String]!
    
    override func viewWillAppear(_ animated: Bool) {
        if let indexPath = tableView.indexPathForSelectedRow {
            tableView.deselectRow(at: indexPath, animated: true)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTheme()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UINib(nibName: "MainTableViewCell", bundle: nil), forCellReuseIdentifier: "MainCell")
        registerForPreviewing(with: self, sourceView: tableView)
        gameIds = []
        opponentUids = []

        navigationItem.backBarButtonItem = UIBarButtonItem(title: "Games", style: .plain, target: self, action: nil)
        
        auth()
    }
    
    // Step 1
    func auth() {
        FIRAuth.auth()?.signInAnonymously() { user, error in
            if error == nil && user != nil {
                App.loggedInUid = user!.uid
                if App.apnToken != nil {
                    // When the user is logged in before the apnToken is set
                    // This line won't be executed,
                    // but it will be executed when apnToken is set.
                    DB.save(apnToken: App.apnToken!, forUser: user!.uid)
                }
                
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
        DB.observeUser(uid: App.loggedInUid) { snap in
            let values = snap.value as? [String: Any]
            
            if let games = values?["games"] as? [String: String] {
                App.loggedInUser.games = games
            } else {
                App.loggedInUser.games = [:]
            }
            
            if let won = values?["won"] as? [String: Int] {
                App.loggedInUser.won = won
            }
            
            if let lost = values?["lost"] as? [String: Int] {
                App.loggedInUser.lost = lost
            }
            
            self.gameIds = Array(App.loggedInUser.games.values)
            self.opponentUids = Array(App.loggedInUser.games.keys)
            self.displayGames()
        }
    }
    
    // Step 4
    func displayGames() {
        winsLabel.text = String(App.loggedInUser.totalWon)
        lossesLabel.text = String(App.loggedInUser.totalLost)
        
        tableView.reloadData()
    }
    
    
    func sendToCreateUsername() {
        let vc = storyboard?.instantiateViewController(withIdentifier: "CreateUsername") as! CreateUsernameViewController
        vc.delegate = self
        present(vc, animated: true, completion: nil)
    }
    
    @IBAction func addFriendButtonPressed() {
        let alert = UIAlertController(title: "Add friend", message: "Enter username", preferredStyle: .alert)
        alert.addTextField(configurationHandler: nil)
        let add = UIAlertAction(title: "Add", style: .default) { alertAction in
            if let playUser = alert.textFields?[0].text {
                if playUser != App.loggedInUser.username {
                
                    DB.userExists(username: playUser, completion: { uid in
                        if uid != nil {
                            self.createNewGame(playAgainst: uid!)
                        } else {
                            self.addFriendError()
                        }
                    })
                }
            } else {
                self.addFriendError()
            }
        }
        alert.addAction(add)
        let cancel = UIAlertAction(title: "Cancel", style: .default, handler: nil)
        alert.addAction(cancel)
        present(alert, animated: true, completion: nil)
    }
    
    func addFriendError() {
        let alert = UIAlertController(title: "Error", message: "That user doesn't exist.", preferredStyle: .alert)
        let okay = UIAlertAction(title: "Okay", style: .default, handler: nil)
        alert.addAction(okay)
        present(alert, animated: true, completion: nil)
    }
    
    // Here, we check to see if local user already has a game ID with the remote user.
    func createNewGame(playAgainst uid: String) {
        if let gameId = App.loggedInUser.games[uid] {
            goToGame(gameid: gameId)
        } else {
            let gameRef = DB.gamesRef.childByAutoId()
            let game: GTGame
            if let username = App.loggedInUser.username {
                GTPushNotifications.sendNotifaction(toUid: uid, message: "\(username) wants to play!")
            }
            game = GTGame(id: gameRef.key, localPlayerUid: uid, remotePlayerUid: App.loggedInUser.uid)
            DB.save(game: game)
            goToGame(gameid: game.id)
        }
    }
    
    
    func viewControllerFor(gameId: String) -> UIViewController {
        let sb = UIStoryboard(name: "Game", bundle: nil)
        let vc = sb.instantiateViewController(withIdentifier: "Game") as! GameViewController
        vc.loadGameId = gameId
        if let indexPath = tableView.indexPathForSelectedRow {
            let cell = tableView.cellForRow(at: indexPath) as! MainTableViewCell
            vc.opponentName = cell.usernameLabel.text
        }
        
        return vc
    }
    
    func goToGame(gameid: String) {
        navigationController?.pushViewController(viewControllerFor(gameId: gameid), animated: true)
    }
}

extension MainViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return gameIds.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MainCell") as! MainTableViewCell
        
        DB.userExists(uid: opponentUids[indexPath.row]) { username in
            DispatchQueue.main.async {
                cell.usernameLabel.text = username
            }
        }
        
        DB.gameStatus(gameid: gameIds[indexPath.row]) { status in
            let texts: [GTGameStatus: String] = [.localTurn: "Your turn", .remoteTurn: "Waiting", .localWon: "Won!", .remoteWon: "Lost"]
            cell.turnLabel.text = texts[status]
        }
        
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

extension MainViewController: UIViewControllerPreviewingDelegate {
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) {
        navigationController?.pushViewController(viewControllerToCommit, animated: false)
    }
    
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        if let indexPath = tableView.indexPathForRow(at: location) {
            previewingContext.sourceRect = tableView.rectForRow(at: indexPath)
            return viewControllerFor(gameId: gameIds[indexPath.row])
        }
        
        return nil
    }
}




//for family: String in UIFont.familyNames
//{
//    print("\(family)")
//    for names: String in UIFont.fontNames(forFamilyName: family)
//    {
//        print("== \(names)")
//    }
//}
