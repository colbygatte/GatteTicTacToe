//
//  ChooseTac.swift
//  GTicTacToe
//
//  Created by Colby Gatte on 1/5/17.
//  Copyright © 2017 colbyg. All rights reserved.
//

import UIKit

class ChooseTacView: UIView {
    @IBOutlet weak var tacView: UIView!
    @IBOutlet weak var xImageView: UIImageView!
    @IBOutlet weak var oImageView: UIImageView!
    @IBOutlet weak var xSelectedImageView: UIImageView!
    @IBOutlet weak var oSelectedImageView: UIImageView!
    
    var is_o: Bool = false
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        setup()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    func setup() {
        Bundle.main.loadNibNamed("ChooseTacView", owner: self, options: nil)
        addSubview(tacView)
        
        let tapx = UITapGestureRecognizer(target: self, action: #selector(tapped(recognizer:)))
        xImageView.addGestureRecognizer(tapx)
        let tapo = UITapGestureRecognizer(target: self, action: #selector(tapped(recognizer:)))
        oImageView.addGestureRecognizer(tapo)
        oSelectedImageView.alpha = 0.0
    }
    
    func setFrame() {
        tacView.frame = CGRect(x: 0, y: 0, width: self.frame.size.width, height: self.frame.size.height)
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
    
    func toggle() {
        if is_o {
            is_o = false
            self.xSelectedImageView.alpha = 1.0
            self.oSelectedImageView.alpha = 0.0
        } else {
            is_o = true
            self.xSelectedImageView.alpha = 0.0
            self.oSelectedImageView.alpha = 1.0
        }
    }
    
    func animate(block: @escaping ()->()) {
        UIView.animate(withDuration: TimeInterval(0.2)) {
            block()
        }
    }
}
