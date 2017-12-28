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
    
    var socket: Socket?
    var channel: Channel?
    var name: String!
    var gameId: String!
    
    @IBOutlet var gameIdLabel: UILabel!
    @IBOutlet var playerListTableView: UITableView!
    @IBOutlet var startButton: RoundedButton!
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let count = self.channel?.presence.firstMetas().count
        return count == nil ? 0 : count!
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "playerCell", for: indexPath) as! PlayerListTableCell
        if let keys = self.channel?.presence.firstMetas().keys {
            let name = Array(keys)[indexPath.row]
            cell.nameLabel!.text = name
        }
        return cell
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        playerListTableView.delegate = self
        playerListTableView.dataSource = self
        gameIdLabel.text = gameId
        
        connectSocket()
        
        self.updatePlayerList()
    }
    
    func setupCallbacks() {
        self.channel?.on("new:msg", callback: { response in
            print(response)
        })
        
        self.channel?.join()?.receive("ok", callback: { payload in
            print("Joined channel: \(self.channel!.topic)")
            self.updatePlayerList()
        }).receive("error", callback: { payload in
            print("Failed joining channel. Payload: \(payload)")
        })
        
        // Presence support
        self.channel?.onPresenceUpdate({ _ in
            print("Received presence update")
            self.updatePlayerList()
        })
        
        self.channel?.presence.onStateChange = { _ in
            print("Received presence state change")
            self.updatePlayerList()
        }
        
        self.channel?.presence.onJoin = { _, _ in
            print("Received presence join event")
            self.updatePlayerList()
        }
        
        self.channel?.presence.onLeave = { _, _ in
            print("Received presence leave event")
            self.updatePlayerList()
        }
    }
    
    func connectSocket() {
        // After connection, set up a channel and join it.
        socket!.onConnect = {
            self.channel = self.socket!.channel("game:\(self.gameId!)", payload: [:])
            
            self.channel?.on("new_game", callback: { response in
                let newGameId = response.payload.first!.value as! String
                self.channel?.leave()
                self.channel = self.socket!.channel("game:\(newGameId)", payload: [:])
                self.setupCallbacks()
                self.channel?.join()?.receive("ok", callback: { payload in
                    print("Joined channel: \(self.channel!.topic)")
                    self.startButton.isHidden = false
                    self.gameIdLabel.text = newGameId
                    self.updatePlayerList()
                }).receive("error", callback: { payload in
                    print("Failed joining channel.")
                })
            })
            
            self.setupCallbacks()
        }
        
        // Connect!
        socket!.connect()
    }
    
    func updatePlayerList() {
        print("Updating player list")
        DispatchQueue.main.async {
            self.playerListTableView.reloadData()
        }
    }
    
    @IBAction func leaveGame(_ sender: Any) {
        socket?.disconnect()
        navigationController?.popViewController(animated: true)
        dismiss(animated: true, completion: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
}
