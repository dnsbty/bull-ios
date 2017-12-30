//
//  ResultsViewController.swift
//  Bull
//
//  Created by Dennis Beatty on 12/29/17.
//  Copyright © 2017 Dennis Beatty. All rights reserved.
//

import UIKit

class ResultsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet var resultLabel: UILabel!
    @IBOutlet var votesTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        Game.setThinking()
        votesTableView.delegate = self
        votesTableView.dataSource = self
        
        let authorVotedFor = Game.authorVotedFor()
        let votedForText = authorVotedFor == "correct" ? "the correct answer" : "\(authorVotedFor)'s answer"
        let player = Game.playerName()!
        let votesText = Game.votesFor(player) == 1 ? "1 vote" : "\(Game.votesFor(player)) votes"
        let receivedVotesText = Game.votesFor(player) > 0 ? " and received \(votesText)" : ""
        resultLabel.text = "You voted for \(votedForText)\(receivedVotesText)!"
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Game.definitionCount()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "resultCell") as! ResultsTableCell
        let player = Game.authorOfDefinitionAt(indexPath.row)
        cell.authorLabel.text = player == "correct" ? "Correct Definition" : player
        cell.definitionLabel.text = Game.definitionFor(player)
        cell.votesCountLabel.text = "\(Game.votesFor(player)) votes"
        return cell
    }
    
    @IBAction func startNextRound() {
        Game.setReady()
        self.performSegue(withIdentifier: "wait", sender: self)
    }
    
    @IBAction func leaveGame() {
        Game.leave()
        self.view.window?.rootViewController?.dismiss(animated: true, completion: nil)
    }
}
