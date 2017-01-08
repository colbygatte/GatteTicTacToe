//
//  GameViewController.swift
//  GTicTacToe
//
//  Created by Colby Gatte on 1/3/17.
//  Copyright © 2017 colbyg. All rights reserved.
//
// player1 is X
// player2 is O

import UIKit

class GameViewController: UIViewController {
    @IBOutlet weak var backgroundBoardView: UIView!
    @IBOutlet weak var boardView: BoardView!
    @IBOutlet weak var chooseTacView: ChooseTacView!
    @IBOutlet weak var chooseTacViewLabel: UILabel!
    @IBOutlet weak var newGameView: UIView!
    @IBOutlet weak var turnLabel: UILabel!
    @IBOutlet weak var winsLabel: UILabel!
    @IBOutlet weak var lossesLabel: UILabel!
    @IBOutlet weak var tieLabel: UILabel!
    @IBOutlet weak var localTacImageView: UIImageView!
    var opponentName: String?
    
    
    var loadGameId: String!
    var game: GTGame?
    
    var newGameViewIsShowing: Bool = false
    
    var isRemoteGame: Bool = false
    var myTurn = false
    
    var lost: Int?
    var won: Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTheme()
        
        //newGameView.layer.cornerRadius = 20.0
        //backgroundBoardView.layer.cornerRadius = 20.0
        
        boardView.setFrame()
        chooseTacView.setFrame()
        boardView.delegate = self
        isRemoteGame = false
        
        if let name = opponentName {
            title = "Playing " + name
        } else {
            title = "TicTacToe"
        }
        
        begin()
    }
    
    func begin() {
        DB.gamesRef.child(loadGameId).observe(.value, with: { snap in
            if snap.childrenCount == 0 {
                print("ERROR")
            } else {
                self.game = GTGame(snapshot: snap)
                self.tieLabel.text = String(self.game!.cat)
                
                // Update the popup to the current player's piece
                if (self.game!.localPlayerUid == self.game!.player1Uid && self.chooseTacView.is_o) || (self.game!.localPlayerUid == self.game!.player2Uid && !self.chooseTacView.is_o)  {
                    self.chooseTacView.toggle()
                }
                
                if self.game!.localPlayerUid == self.game!.player1Uid {
                    self.localTacImageView.image = UIImage(named: "x.png")
                } else {
                    self.localTacImageView.image = UIImage(named: "o.png")
                }

                // If lost is nil, we set it now. While in this view, we increment ourselves, we don't grab the values from the database
                if self.lost == nil {
                    self.lost = App.loggedInUser.lost[self.game!.remotePlayerUid] ?? 0
                    self.won = App.loggedInUser.won[self.game!.remotePlayerUid] ?? 0
                }
                
                self.boardView.game = self.game!
                DispatchQueue.main.async {
                    self.boardView.loadGame()
                    self.updateLabel()
                }
            }
        })
    }
    
    func declareWinner() {
        if game?.gameWinner == "C" {
            return
        }
        
        if game?.gameWinner == game?.localPlayerUid {
            App.loggedInUser.won(against: game!.remotePlayerUid)
            DB.increaseLost(uid: game!.remotePlayerUid)
        } else {
            App.loggedInUser.lost(against: game!.remotePlayerUid)
            DB.increaseWon(uid: game!.remotePlayerUid)
        }
        
        DB.save(user: App.loggedInUser)
    }
    
    func updateLabel() {
        if game!.gameWinner != nil && game!.gameWinner != "C" {
            if game!.gameWinner! == App.loggedInUid {
                turnLabel.text = "YOU WIN!"
                if won != nil { won = 1 + won! }
            } else {
                if lost != nil { lost = 1 + lost! }
                turnLabel.text = "You lose."
            }
            
            newGameView(on: true)
        } else if game!.gameWinner == "C" {
            turnLabel.text = "Tie!"
            newGameView(on: true)
        } else if game!.nextToPlay == game!.localPlayerUid {
            turnLabel.text = "Your turn"
            newGameView(on: false)
        } else {
            turnLabel.text = "Not your turn"
            newGameView(on: false)
        }
        
        winsLabel.text = String(won ?? 0)
        lossesLabel.text = String(lost ?? 0)
    }
    
    func newGameView(on: Bool) {
        if on {
            newGameView.isUserInteractionEnabled = true
            newGameViewIsShowing = true
            view.addSubview(newGameView)
            newGameView.center = CGPoint(x: view.frame.size.width / 2, y: view.frame.size.height / 2)
            view.bringSubview(toFront: newGameView)
            UIView.animate(withDuration: TimeInterval(0.2), animations: {
                self.newGameView.alpha = 1.0
            })
        } else {
            if newGameViewIsShowing {
                UIView.animate(withDuration: TimeInterval(0.2), animations: { 
                    self.newGameView.alpha = 0.0
                })
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.2) {
                    self.newGameView.removeFromSuperview()
                }
                newGameView.isUserInteractionEnabled = false
            }
        }
    }
    
    @IBAction func newGameButtonPressed() {
        if game?.gameWinner != nil {
            newGameView(on: false)
            if chooseTacView.is_o {
                game!.player2Uid = game!.localPlayerUid
                game!.player1Uid = game!.remotePlayerUid
            } else {
                game!.player1Uid = game!.localPlayerUid
                game!.player2Uid = game!.remotePlayerUid
            }
            game!.reset()
            DB.save(game: game!)
            boardView.loadGame()
            updateLabel()
        }
    }
}

extension GameViewController: BoardViewDelegate  {
    func board(playedPosition: Int) {
        DB.save(game: game!)
        if let username = App.loggedInUser.username {
            GTPushNotifications.sendNotifaction(toUid: game!.remotePlayerUid, message: "Your move against \(username).")
        }
        
        if game?.gameWinner != nil {
            declareWinner()
        } else {
            updateLabel()
        }
    }
}
