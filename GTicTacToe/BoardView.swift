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
    func winner(local: Bool)
    func tie()
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
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        setup()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    func setFrame() {
        boardView.frame = CGRect(x: 0, y: 0, width: self.frame.size.width, height: self.frame.size.height)
    }
    
    func setup() {
        Bundle.main.loadNibNamed("BoardView", owner: self, options: nil)
        addSubview(boardView)
        imageViews = [1: cell11, 2: cell12, 4: cell13, 8: cell21, 16: cell22, 32: cell23, 64: cell31, 128: cell32, 256: cell33]
        
        for imageView in imageViews {
            imageView.value.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapped(recognizer:))))
        }
    }
    
    func loadGame() {
        let bits = [1, 2, 4, 8, 16, 32, 64, 128, 256]
        
        for bit in bits {
            if game.localPlayer & bit != 0 {
                imageViews[bit]?.image = UIImage(named: "x.png")
            } else if game.remotePlayer & bit != 0 {
                imageViews[bit]?.image = UIImage(named: "o.png")
            }
        }
    }
    
    func played(_ played: Int) {
        if game.nextToPlay == game.localPlayerUid {
            game.play(played)
            imageViews[played]?.image = UIImage(named: "x.png")
            delegate?.board(playedPosition: played)
            
            if game.gameWinner != nil {
                print("LOCAL WON!")
            }
        }
    }
    
    func tapped(recognizer: UITapGestureRecognizer) {
        if let imageView = recognizer.view as? UIImageView {
            switch imageView {
            case cell11:
                played(1)
                break
            case cell12:
                played(2)
                break
            case cell13:
                played(4)
                break
            case cell21:
                played(8)
                break
            case cell22:
                played(16)
                break
            case cell23:
                played(32)
                break
            case cell31:
                played(64)
                break
            case cell32:
                played(128)
                break
            case cell33:
                played(256)
                break
            default:
                print("error")
                break
            }
        }
    }
}
