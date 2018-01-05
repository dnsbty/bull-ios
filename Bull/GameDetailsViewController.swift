//
//  ConnectToGameViewController.swift
//  Bull
//
//  Created by Dennis Beatty on 12/26/17.
//  Copyright © 2017 Dennis Beatty. All rights reserved.
//

import UIKit
import Birdsong

class GameDetailsViewController: UIViewController, UITextFieldDelegate {
    var newGame: Bool!
    @IBOutlet var topLabel: UILabel!
    @IBOutlet var gameIdLabel: UILabel!
    @IBOutlet var gameIdInput: UITextField!
    @IBOutlet var gameIdInputView: UIView!
    @IBOutlet var actionButton: RoundedButton!
    @IBOutlet var nameInput: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let name = UserDefaults.standard.string(forKey: "name") ?? ""
        nameInput.text = name
        
        if newGame {
            topLabel.text = "CREATE GAME"
            gameIdLabel.isHidden = true
            gameIdInputView.isHidden = true
            actionButton.setTitle("CREATE GAME", for: .normal)
            nameInput.returnKeyType = .go
            nameInput.delegate = self
            if name.isEmpty {
                nameInput.becomeFirstResponder()
            }
        } else {
            gameIdInput.delegate = self
            if name.isEmpty {
                nameInput.becomeFirstResponder()
            } else {
                gameIdInput.becomeFirstResponder()
            }
        }
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(GameDetailsViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        createOrJoin(textField)
        return true
    }
    
    @IBAction func createOrJoin(_ sender: Any) {
        UserDefaults.standard.set(nameInput.text, forKey: "name")
        self.performSegue(withIdentifier: "toPlayerList", sender: self)
    }
    
    @IBAction func goBack(_ sender: Any) {
        self.view.window?.rootViewController?.dismiss(animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! PlayerListViewController
        Game.setPlayerName(nameInput.text!)
        Game.setHost(newGame)
        destinationVC.gameId = newGame ? nil : gameIdInput.text!
        destinationVC.isCreator = newGame
    }
}
