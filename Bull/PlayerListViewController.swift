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
    
    let socket = Socket(url: "ws://9b5c5163.ngrok.io/socket/websocket", params: ["name": "Dennis"])
    var channel: Channel?
    var name: String!
    var gameId: String!
    var players = ["Apple", "Apricot", "Banana", "Blueberry", "Cantaloupe", "Cherry",
                  "Clementine", "Coconut", "Cranberry", "Fig", "Grape", "Grapefruit",
                  "Kiwi fruit", "Lemon", "Lime", "Lychee", "Mandarine", "Mango",
                  "Melon", "Nectarine", "Olive", "Orange", "Papaya", "Peach",
                  "Pear", "Pineapple", "Raspberry", "Strawberry"]
    
    @IBOutlet var playerListTableView: UITableView!
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return players.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "playerCell", for: indexPath) as! PlayerListTableCell
        cell.nameLabel!.text = players[indexPath.row]
        return cell
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        playerListTableView.delegate = self
        playerListTableView.dataSource = self
        
        // After connection, set up a channel and join it.
        socket.onConnect = {
            self.channel = self.socket.channel("game:\(self.gameId!)", payload: ["name": self.name])
            
            self.channel?.on("new:msg", callback: { response in
                print(response)
            })
            
            self.channel?.join()?.receive("ok", callback: { payload in
                print("Joined channel: \(self.channel!.topic)")
            }).receive("error", callback: { payload in
                print("Failed joining channel.")
            })
        }
        
        // Connect!
        socket.connect()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
}
