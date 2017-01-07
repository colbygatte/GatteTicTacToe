//
//  BoardView.swift
//  GTicTacToe
//
//  Created by Colby Gatte on 1/3/17.
//  Copyright © 2017 colbyg. All rights reserved.
//

import UIKit

protocol BoardViewDelegate {
    func board(playedPosition: Int)
}

class BoardView: UIView {
    @IBOutlet weak var boardView: UIView!
    @IBOutlet weak var cell11: UIImageView!
    @IBOutlet weak var cell12: UIImageView!
    @IBOutlet weak var cell13: UIImageView!
    @IBOutlet weak var cell21: UIImageView!
    @IBOutlet weak var cell22: UIImageView!
    @IBOutlet weak var cell23: UIImageView!
    @IBOutlet weak var cell31: UIImageView!
    @IBOutlet weak var cell32: UIImageView!
    @IBOutlet weak var cell33: UIImageView!
    var delegate: BoardViewDelegate?
    var game: GTGame!
    var imageViews: [Int: UIImageView]!
    
    var localImage: UIImage?
    var remoteImage: UIImage?
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        setup()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    func setup() {
        Bundle.main.loadNibNamed("BoardView", owner: self, options: nil)
        addSubview(boardView)
        imageViews = [1: cell11, 2: cell12, 4: cell13, 8: cell21, 16: cell22, 32: cell23, 64: cell31, 128: cell32, 256: cell33]

        for imageView in imageViews {
            imageView.value.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapped(recognizer:))))
        }
    }
    
    func setFrame() {
        boardView.frame = CGRect(x: 0, y: 0, width: self.frame.size.width, height: self.frame.size.height)
    }
    
    func loadGame() {
        if game.player1Uid == game.localPlayerUid {
            localImage = UIImage(named: "x.png")
            remoteImage = UIImage(named: "o.png")
        } else {
            localImage = UIImage(named: "o.png")
            remoteImage = UIImage(named: "x.png")
        }
        
        for bit in [1, 2, 4, 8, 16, 32, 64, 128, 256] {
            if self.game.localPlayer & bit != 0 {
                animateImageViewIfNil(bit)
                self.imageViews[bit]?.image = self.localImage
            } else if self.game.remotePlayer & bit != 0 {
                animateImageViewIfNil(bit)
                self.imageViews[bit]?.image = self.remoteImage
            } else {
                self.imageViews[bit]?.image = nil
            }
        }
    }
    
    func animateImageViewIfNil(_ bit: Int) {
        if self.imageViews[bit]!.image == nil {
            self.imageViews[bit]!.alpha = 0
            App.animate {
                self.imageViews[bit]!.alpha = 1
            }
        }
    }
    
    // checkForWinner is only called after a player makes a move
    // so we update the stats for both users in GameViewController when the delegate method board is called
    func played(_ played: Int) {
        if game.nextToPlay == game.localPlayerUid && game.play(played) {
            self.imageViews[played]?.alpha = 0
            self.imageViews[played]?.image = self.localImage
            App.animate() {
                self.imageViews[played]?.alpha = 1
            }
            game.checkForWinner()
            if game.gameWinner != nil {
                DB.save(game: game)
            }
            delegate?.board(playedPosition: played)
        }
    }
    
    func tapped(recognizer: UITapGestureRecognizer) {
        if game.gameWinner != nil {
            return
        }
        
        if let imageView = recognizer.view as? UIImageView {
            if let play = imageView.restorationIdentifier {
                played(Int(play)!)
            }
        }
    }
}
