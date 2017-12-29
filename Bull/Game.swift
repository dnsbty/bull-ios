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
    var definitions: [String: String]?
    
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
    
    static func playerAt(_ index: Int) -> Player {
        let name = players()[index]
        let status = GameServer.playerStatus(name)
        return Player(name: name, status: status)
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
    
    static func leave() {
        shared.name = nil
        shared.word = nil
        GameServer.disconnect()
    }
    
    static func allReady() -> Bool {
        for player in players() {
            if GameServer.playerStatus(player) != "ready" {
                return false
            }
        }
        return true
    }
    
    static func setDefinitions(_ definitions: [String: String]) {
        shared.definitions = definitions
    }
}
