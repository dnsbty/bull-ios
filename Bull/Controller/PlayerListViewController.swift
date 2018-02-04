//
//  PlayerListViewController.swift
//  Bull
//
//  Created by Dennis Beatty on 12/26/17.
//  Copyright © 2017 Dennis Beatty. All rights reserved.
//

import UIKit
import Birdsong

class PlayerListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    var gameId: String!
    var isCreator: Bool!
    
    @IBOutlet var gameIdLabel: UILabel!
    @IBOutlet var playerListTableView: UITableView!
    @IBOutlet var startButton: RoundedButton!
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Game.playerCount()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "playerCell", for: indexPath) as! PlayerListTableCell
        cell.nameLabel!.text = Game.playerAt(indexPath.row).name
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("Trying to select row \(indexPath.row)")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        playerListTableView.delegate = self
        playerListTableView.dataSource = self
        gameIdLabel.text = gameId
        
        GameServer.onPresenceUpdate({
            self.updatePlayerList()
        })
        
        GameServer.onJoin({ gameId in
            if self.isCreator {
                self.startButton.isHidden = false
            }
            
            GameServer.setupCallbacks()
            
            self.gameId = gameId
            self.gameIdLabel.text = self.gameId
            self.updatePlayerList()
            self.dismiss(animated: false, completion: nil)
        })
        
        GameServer.onError({ error in
            self.dismiss(animated: false, completion: nil)
            print("Error joining game: \(String(describing: error))")
            
            let title = "Oh no!"
            let message = self.message(forError: error)
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .default, handler: { _ in
                self.leaveGame(self)
            }))
            self.present(alert, animated: true, completion: nil)
        })
        
        GameServer.onStartGame({
            self.performSegue(withIdentifier: "startGame", sender: self)
        })
    }
    
    private func message(forError: String?) -> String {
        switch forError {
        case "bad_id"?:
            return "That game ID seems to be wrong 😬"
        case "bad_key"?:
            return "It looks like you don't have permission to join that game 😕"
        case "started"?:
            return "It looks like they started the game without you 😒"
        default:
            return "Bull couldn't connect to the server 😞 Maybe try again in a few minutes?"
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if Game.playerName() != nil {
            let message = isCreator ? "Creating game..." : "Joining game..."
            let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
            
            let loadingIndicator = UIActivityIndicatorView(frame: CGRect(x: 10, y: 5, width: 50, height: 50))
            loadingIndicator.hidesWhenStopped = true
            loadingIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
            loadingIndicator.startAnimating();
            
            alert.view.addSubview(loadingIndicator)
            present(alert, animated: true, completion: {
                if self.isCreator {
                    GameServer.createGame(Game.playerName()!)
                } else {
                    GameServer.joinGame(self.gameId, Game.playerName()!)
                }
            })
        }
    }
    
    func updatePlayerList() {
        DispatchQueue.main.async {
            self.playerListTableView.reloadData()
        }
    }
    
    @IBAction func startGame(_ sender: Any) {
        if Game.playerCount() > 1 {
            GameServer.startGame()
        } else {
            let title = "Don't play alone!"
            let message = "Invite a friend to join using the code at the top 😃"
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    @IBAction func leaveGame(_ sender: Any) {
        Game.leave()
        self.view.window?.rootViewController?.dismiss(animated: true, completion: nil)
    }
}
