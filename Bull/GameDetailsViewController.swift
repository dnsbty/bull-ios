//
//  ConnectToGameViewController.swift
//  Bull
//
//  Created by Dennis Beatty on 12/26/17.
//  Copyright © 2017 Dennis Beatty. All rights reserved.
//

import UIKit

class GameDetailsViewController: UIViewController {
    var newGame: Bool!
    @IBOutlet var topLabel: UILabel!
    @IBOutlet var gameIdLabel: UILabel!
    @IBOutlet var gameIdInput: UITextField!
    @IBOutlet var actionButton: RoundedButton!
    @IBOutlet var nameInput: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if newGame {
            topLabel.text = "CREATE GAME"
            gameIdLabel.isHidden = true
            gameIdInput.isHidden = true
            actionButton.setTitle("CREATE GAME", for: .normal)
        }
        
        nameInput.text = UserDefaults.standard.string(forKey: "name")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    @IBAction func createOrJoin(_ sender: Any) {
        UserDefaults.standard.set(nameInput.text, forKey: "name")
        self.performSegue(withIdentifier: "toPlayerList", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! PlayerListViewController
        destinationVC.name = nameInput.text!
        destinationVC.gameId = newGame ? "new" : gameIdInput.text!
    }
}
