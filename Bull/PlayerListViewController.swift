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
        
        // After connection, set up a channel and join it.
        socket = Socket(url: "ws://9b5c5163.ngrok.io/socket/websocket", params: ["name": self.name])
        socket!.onConnect = {
            self.channel = self.socket!.channel("game:\(self.gameId!)", payload: [:])
            
            self.channel?.on("new:msg", callback: { response in
                print(response)
            })
            
            self.channel?.join()?.receive("ok", callback: { payload in
                print("Joined channel: \(self.channel!.topic)")
            }).receive("error", callback: { payload in
                print("Failed joining channel.")
            })
            
            // Presence support.
            self.channel?.presence.onStateChange = { _ in
                self.updatePlayerList()
            }
            
            self.channel?.presence.onJoin = { _, _ in
                self.updatePlayerList()
            }
            
            self.channel?.presence.onLeave = { _, _ in
                self.updatePlayerList()
            }
        }
        
        // Connect!
        socket!.connect()
    }
    
    func updatePlayerList() {
        DispatchQueue.main.async {
            self.playerListTableView.reloadData()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
}
