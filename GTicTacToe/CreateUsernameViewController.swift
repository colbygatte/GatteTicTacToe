//
//  CreateUsernameViewController.swift
//  GTicTacToe
//
//  Created by Colby Gatte on 1/5/17.
//  Copyright © 2017 colbyg. All rights reserved.
//

import UIKit

protocol CreateUsernameViewControllerDelegate {
    func usernameCreated()
}

class CreateUsernameViewController: UIViewController {
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var goButtonImageView: UIImageView!
    var delegate: CreateUsernameViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tap = UILongPressGestureRecognizer(target: self, action: #selector(tapped(recognizer:)))
        tap.minimumPressDuration = 0
        goButtonImageView.addGestureRecognizer(tap)
        usernameTextField.becomeFirstResponder()
    }
    
    func error(message: String) {
        
    }
    
    func tapped(recognizer: UILongPressGestureRecognizer) {
        if recognizer.state == .began {
            
        } else if recognizer.state == .ended {
            createUsernameButtonPressed()
        }
    }
    
    func createUsernameButtonPressed() {
        if let username = usernameTextField.text {
            DB.userExists(username: username, completion: { uid in
                if uid != nil {
                    self.error(message: "Username taken")
                } else {
                    App.loggedInUser = GTUser(uid: App.loggedInUid, username: username)
                    DB.save(user: App.loggedInUser)
                    self.delegate?.usernameCreated()
                    self.dismiss(animated: true, completion: nil)
                }
            })
        }
    }
}
