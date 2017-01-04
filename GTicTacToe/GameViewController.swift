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
            self.game = GTGame(snapshot: snap)
            self.boardView.game = self.game!
            DispatchQueue.main.async {
                self.boardView.loadGame()
                self.updateLabel()
            }
        })
    }
    
    func updateLabel() {
        if game!.nextToPlay == game!.localPlayerUid {
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
        updateLabel()
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
