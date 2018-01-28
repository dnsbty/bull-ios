//
//  FinalResultsViewController.swift
//  Bull
//
//  Created by Dennis Beatty on 1/5/18.
//  Copyright © 2018 Dennis Beatty. All rights reserved.
//

import UIKit

class FinalResultsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet var winnerLabel: UILabel!
    @IBOutlet var scoresTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        scoresTableView.delegate = self
        scoresTableView.dataSource = self
        winnerLabel.text = "\(Game.winner().key) wins!"
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Game.resultsCount()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "resultCell") as! FinalResultsTableCell
        let result = Game.resultAt(indexPath.row)
        cell.playerNameLabel.text = result.key
        cell.playerScoreLabel.text = "\(result.value) pts"
        return cell
    }
    
    @IBAction func finishGame() {
        print("Leaving")
        Game.leave()
        print("Left")
        self.view.window?.rootViewController?.dismiss(animated: true, completion: nil)
    }
}
