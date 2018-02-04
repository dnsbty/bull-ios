//
//  WaitingViewController.swift
//  Bull
//
//  Created by Dennis Beatty on 12/29/17.
//  Copyright © 2017 Dennis Beatty. All rights reserved.
//

import UIKit

class WaitingViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet var playerListTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        playerListTableView.dataSource = self
        playerListTableView.delegate = self
        
        GameServer.onPresenceUpdate({
            self.updatePlayerList()
        })
        
        GameServer.onStartDefining({
            DispatchQueue.main.async(){
                self.performSegue(withIdentifier: "defineWord", sender: self)
            }
        })
        
        GameServer.onStartVoting({
            DispatchQueue.main.async(){
                self.performSegue(withIdentifier: "startVoting", sender: self)
            }
        })
        
        GameServer.onShowResults({
            DispatchQueue.main.async(){
                self.performSegue(withIdentifier: "showResults", sender: self)
            }
        })
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Game.playerCount()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "playerCell", for: indexPath) as! PlayerListTableCell
        let player = Game.playerAt(indexPath.row)
        cell.nameLabel.text = player.name
        cell.checkMark.isHidden = player.status != "ready"
        return cell
    }
    
    func updatePlayerList() {
        DispatchQueue.main.async {
            self.playerListTableView.reloadData()
        }
    }
    
    @IBAction func leaveGame(_ sender: Any) {
        Game.leave()
        self.view.window?.rootViewController?.dismiss(animated: true, completion: nil)
    }
}
