//
//  DefineViewController.swift
//  Bull
//
//  Created by Dennis Beatty on 12/29/17.
//  Copyright © 2017 Dennis Beatty. All rights reserved.
//

import UIKit

class DefineViewController: UIViewController, UITextViewDelegate {
    @IBOutlet var wordLabel: UILabel!
    @IBOutlet var definitionInput: UITextView!
    
    override func viewDidLoad() {
        wordLabel.text = "Define \"\(Game.currentWord()!)\""
        definitionInput.delegate = self
        definitionInput.becomeFirstResponder()
        Game.setThinking()
    }
    
    @IBAction func submitDefinition(_ sender: Any) {
        let definition = definitionInput.text ?? ""
        if definition.isEmpty {
            let alert = UIAlertController(title: "Alert", message: "Please enter a definition", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            return
        }
        Game.submitDefinition(definition)
        self.performSegue(withIdentifier: "waitForOthers", sender: self)
    }
    
    @IBAction func leaveGame() {
        Game.leave()
        self.view.window?.rootViewController?.dismiss(animated: true, completion: nil)
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            textView.resignFirstResponder()
            return false
        }
        return true
    }
}
