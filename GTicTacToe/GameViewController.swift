//
//  GameViewController.swift
//  GTicTacToe
//
//  Created by Colby Gatte on 1/3/17.
//  Copyright © 2017 colbyg. All rights reserved.
//

import UIKit

class GameViewController: UIViewController {
    @IBOutlet weak var boardView: BoardView!
    @IBOutlet weak var turnLabel: UILabel!
    var loadGameId: String!
    var game: GTGame?
    
    var isRemoteGame: Bool = false
    var myTurn = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTheme()
        
        boardView.setFrame()
        boardView.delegate = self
        isRemoteGame = false
        turnLabel.text = ""
        
        begin()
    }
    
    func begin() {
        DB.gamesRef.child(loadGameId).observe(.value, with: { snap in
            if snap.childrenCount == 0 {
                print("ERROR")
            } else {
                self.game = GTGame(snapshot: snap)

                self.boardView.game = self.game!
                DispatchQueue.main.async {
                    self.boardView.loadGame()
                    self.updateLabel()
                }
            }
        })
    }
    
    func declareWinner() {
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
        if game!.gameWinner != nil {
            if game!.gameWinner! == App.loggedInUid {
                turnLabel.text = "YOU WIN!"
            } else {
                turnLabel.text = "You lose."
            }
        } else if game!.nextToPlay == game!.localPlayerUid {
            turnLabel.text = "Your turn"
        } else {
            turnLabel.text = "Not your turn"
        }
    }
    
    func computerGo() {
        
    }
}

extension GameViewController: BoardViewDelegate  {
    func board(playedPosition: Int) {
        DB.save(game: game!)
        
        if game?.gameWinner != nil {
            declareWinner()
        } else {
            updateLabel()
        }
    }
    
    func winner(local: Bool) {
        if local {
            print("YOU WIN")
        } else {
            print("YOU LOSE")
        }
    }
    
    func tie() {
        print("TIE")
    }
}
