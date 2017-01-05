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
    var delegate: CreateUsernameViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.hidesBackButton = true
    }
    
    func error(message: String) {
        
    }
    
    @IBAction func createUsernameButtonPressed() {
        if let username = usernameTextField.text {
            DB.userExists(username: username, completion: { uid in
                if uid != nil {
                    self.error(message: "Username taken")
                } else {
                    App.loggedInUser = GTUser(uid: App.loggedInUid, username: username)
                    DB.save(user: App.loggedInUser)
                    self.delegate?.usernameCreated()
                    _ = self.navigationController?.popViewController(animated: true)
                }
            })
        }
    }
}
