//
//  ViewController.swift
//  Bull
//
//  Created by Dennis Beatty on 12/26/17.
//  Copyright © 2017 Dennis Beatty. All rights reserved.
//

import UIKit
import Birdsong

class NewGameViewController: UIViewController {
    
    var newGame = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    @IBAction func createGame(_ sender: Any) {
        newGame = true
        self.performSegue(withIdentifier: "toGameDetails", sender: self)
    }
    
    @IBAction func joinGame(_ sender: Any) {
        newGame = false
        self.performSegue(withIdentifier: "toGameDetails", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! GameDetailsViewController
        destinationVC.newGame = newGame
    }
}

