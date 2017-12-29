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
        cell.nameLabel!.text = Game.playerAt(indexPath.row)
        return cell
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        playerListTableView.delegate = self
        playerListTableView.dataSource = self
        gameIdLabel.text = gameId
        
        GameServer.shared.onPresenceUpdate = {
            self.updatePlayerList()
        }
        
        GameServer.shared.onJoin = { gameId in
            if self.isCreator {
                self.startButton.isHidden = false
            }
            
            GameServer.setupCallbacks()
            
            self.gameId = gameId
            self.gameIdLabel.text = self.gameId
            self.updatePlayerList()
        }
        
        GameServer.shared.onStartGame = {
            self.performSegue(withIdentifier: "startGame", sender: self)
        }
        
        if isCreator {
            GameServer.createGame(Game.playerName()!)
        } else {
            GameServer.joinGame(gameId, Game.playerName()!)
        }
        self.updatePlayerList()
    }
    
    func updatePlayerList() {
        DispatchQueue.main.async {
            self.playerListTableView.reloadData()
        }
    }
    
    @IBAction func startGame(_ sender: Any) {
        GameServer.startGame()
    }
    
    @IBAction func leaveGame(_ sender: Any) {
        GameServer.disconnect()
        self.view.window?.rootViewController?.dismiss(animated: true, completion: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
}
