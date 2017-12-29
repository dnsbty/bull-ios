//
//  Game.swift
//  Bull
//
//  Created by Dennis Beatty on 12/29/17.
//  Copyright © 2017 Dennis Beatty. All rights reserved.
//

import Foundation

class Game {
    var name: String?
    var word: String?
    
    // MARK: Singleton
    class var shared : Game {
        struct Singleton {
            static let instance = Game()
        }
        
        return Singleton.instance
    }
    
    fileprivate init() {
        // This guarantees that code outside this file can't instantiate a GameServer.
        // So others must use the shared singleton.
    }
    
    static func setPlayerName(_ name: String) {
        shared.name = name
    }
    
    static func playerName() -> String? {
        return shared.name
    }
    
    static func players() -> [String] {
        return GameServer.playerNames()
    }
    
    static func playerAt(_ index: Int) -> String {
        return players()[index]
    }
    
    static func playerCount() -> Int {
        return GameServer.playerCount()
    }
    
    static func setWord(_ word: String) {
        shared.word = word
    }
    
    static func currentWord() -> String? {
        return shared.word
    }
    
    static func setThinking() {
        GameServer.updateStatus("thinking")
    }
    
    static func setReady() {
        GameServer.updateStatus("ready")
    }
    
    static func submitDefinition(_ definition: String) {
        GameServer.submitDefinition(definition)
        setReady()
    }
}
