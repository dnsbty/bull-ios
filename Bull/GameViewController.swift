//
//  GameViewController.swift
//  Bull
//
//  Created by Dennis Beatty on 12/29/17.
//  Copyright © 2017 Dennis Beatty. All rights reserved.
//

import UIKit

class GameViewController: UIViewController {
    @IBAction func leaveGame() {
        GameServer.disconnect()
        self.view.window?.rootViewController?.dismiss(animated: true, completion: nil)
    }
}
