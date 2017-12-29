//
//  VoteViewController.swift
//  Bull
//
//  Created by Dennis Beatty on 12/29/17.
//  Copyright © 2017 Dennis Beatty. All rights reserved.
//

import UIKit

class VoteViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet var instructionLabel: UILabel!
    @IBOutlet var definitionsTableView: UITableView!
    var selectedIndex: Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        instructionLabel.text = "Define \"\(Game.currentWord()!)\""
        definitionsTableView.delegate = self
        definitionsTableView.dataSource = self
        Game.setThinking()
    }
    
    @IBAction func submitVote(sender: Any?) {
        Game.setReady()
        self.performSegue(withIdentifier: "wait", sender: self)
    }
    
    @IBAction func leaveGame(sender: Any?) {
        Game.leave()
        self.view.window?.rootViewController?.dismiss(animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Game.definitionCount()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let index = indexPath.row
        let cellIdentifier = index == selectedIndex ? "selectedDefinitionCell" : "definitionCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as! DefinitionsTableCell
        cell.definitionLabel.text = Game.definitionAt(indexPath.row)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedIndex = indexPath.row
        updateTable()
    }
    
    func updateTable() {
        DispatchQueue.main.async {
            self.definitionsTableView.reloadData()
        }
    }
}
