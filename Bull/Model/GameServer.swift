//
//  GameServer.swift
//  Bull
//
//  Created by Dennis Beatty on 12/28/17.
//  Copyright © 2017 Dennis Beatty. All rights reserved.
//

import Foundation
import Birdsong

class GameServer {
    let socketUrl = "wss://api.thebullgame.com/socket/websocket"
//    let socketUrl = "wss://5069954f.ngrok.io/socket/websocket"
    var socket: Socket?
    var channel: Channel?
    var onError: ((_ error: String?) -> ())?
    var onJoin: ((_ gameId: String) -> ())?
    var onPresenceUpdate: (() -> ())?
    var onStartDefining: (() -> ())?
    var onStartGame: (() -> ())?
    var onStartVoting: (() -> ())?
    var onShowResults: (() -> ())?
    
    // MARK: Singleton
    class var shared : GameServer {
        struct Singleton {
            static let instance = GameServer()
        }
        
        return Singleton.instance
    }
    
    fileprivate init() {
        // This guarantees that code outside this file can't instantiate a GameServer.
        // So others must use the shared singleton.
    }
    
    static func playerCount() -> Int {
        return shared.channel?.presence.firstMetas().count ?? 0
    }
    
    static func playerNames() -> [String] {
        if let keys = shared.channel?.presence.firstMetas().keys {
            return Array(keys)
        } else {
            return []
        }
    }
    
    static func connect(_ name: String, _ callback: @escaping () -> ()) {
        shared.socket = Socket(url: shared.socketUrl, params: ["name": name])
        
        // After connection, call the callback
        shared.socket!.onConnect = callback
        
        // Connect!
        shared.socket!.connect()
    }
    
    static func reconnect(_ name: String, _ key: String, _ callback: @escaping () -> ()) {
        shared.socket = Socket(url: shared.socketUrl, params: ["name": name, "key": key])
        
        // After connection, call the callback
        shared.socket!.onConnect = callback
        
        // Connect!
        shared.socket!.connect()
    }
    
    static func createGame(_ name: String) {
        connect(name, {
            setChannel("new")

            shared.channel!.on("new_game", callback: { response in
                let newGameId = response.payload.first!.value as! String
                shared.channel?.leave()
                joinGame(newGameId)
            })
            
            shared.channel!.join()?.receive("ok", callback: { payload in
                print("Joined new game channel")
            }).receive("error", callback: { payload in
                print("Failed joining new game channel. Payload: \(payload)")
            })
        })
    }
    
    static func setChannel(_ gameName: String) {
        shared.channel = shared.socket!.channel("game:\(gameName)", payload: [:])
    }
    
    static func joinGame(_ gameId: String, _ name: String) {
        connect(name, {
            joinGame(gameId)
        })
    }
    
    static func joinGame(_ gameId: String) {
        setChannel(gameId)
        
        shared.channel?.join()?.receive("ok", callback: { payload in
            print("Joined channel: \(shared.channel!.topic)")
            shared.onJoin?(gameId)
        }).receive("error", callback: { payload in
            print("Failed joining channel. Payload: \(payload)")
            shared.onError?(payload["response"] as? String)
        })
        
        setupCallbacks()
    }
    
    static func disconnect() {
        shared.socket?.disconnect()
        shared.channel = nil
        clearCallbacks()
    }
    
    static func clearCallbacks() {
        shared.onJoin = nil
        shared.onPresenceUpdate = nil
        shared.onStartGame = nil
    }
    
    static func setupCallbacks() {
        // Presence support
        shared.channel!.onPresenceUpdate({ _ in
            shared.onPresenceUpdate?()
        })
        
        shared.channel!.presence.onStateChange = { _ in
            shared.onPresenceUpdate?()
            if Game.shouldSendReadySignal() {
                sendReadySignal()
            }
        }
        
        shared.channel!.presence.onJoin = { _, _ in
            shared.onPresenceUpdate?()
        }
        
        shared.channel!.presence.onLeave = { _, _ in
            shared.onPresenceUpdate?()
        }
        
        shared.channel!.on("start_game", callback: { response in
            let word = response.payload["word"] as! String
            let rejoinKey = response.payload["rejoin_key"] as! String
            Game.setWord(word)
            Game.setRejoinKey(rejoinKey)
            Game.start()
            shared.onStartGame?()
        })
        
        shared.channel!.on("start_defining", callback: { response in
            Game.resetForRound()
            let word = response.payload.first!.value as! String
            Game.setWord(word)
            shared.onStartDefining?()
        })
        
        shared.channel!.on("start_voting", callback: { response in
            let definitions = response.payload["definitions"] as! [String: String]
            Game.setDefinitions(definitions)
            shared.onStartVoting?()
        })
        
        shared.channel!.on("show_results", callback: { response in
            let votes = response.payload["votes"] as! [String: [String]]
            let scores = response.payload["scores"] as! [String: Int]
            Game.setVotes(votes)
            Game.setScores(scores)
            shared.onShowResults?()
        })
    }
    
    static func allReady() -> Bool {
        for name in playerNames() {
            if shared.channel?.presence.firstMeta(id: name)!["status"] as! String != "ready" {
                return false
            }
        }
        return true
    }
    
    static func startGame() {
        shared.channel?.send("start_game", payload: [:])
    }
    
    static func submitDefinition(_ definition: String) {
        shared.channel?.send("define_word", payload: ["definition": definition, "player": Game.playerName()!])
    }
    
    static func submitVote(_ writer: String) {
        shared.channel?.send("submit_vote", payload: ["writer": writer, "player": Game.playerName()!])
    }
    
    static func updateStatus(_ status: String) {
        shared.channel?.send("new_status", payload: ["status": status])
    }
    
    static func sendReadySignal() {
        shared.channel?.send("all_ready", payload: [:])
    }
    
    static func onDisconnect() {
        reconnect(Game.playerName()!, Game.key(), {
            print("reconnected")
        })
    }
    
    static func onStartGame(_ callback: @escaping () -> ()) {
        shared.onStartGame = callback
    }
    
    static func onJoin(_ callback: @escaping (String) -> ()) {
        shared.onJoin = callback
    }
    
    static func onError(_ callback: @escaping (String?) -> ()) {
        shared.onError = callback
    }
    
    static func onPresenceUpdate(_ callback: @escaping () -> ()) {
        shared.onPresenceUpdate = callback
    }
    
    static func onStartDefining(_ callback: @escaping () -> ()) {
        shared.onStartDefining = callback
    }
    
    static func onStartVoting(_ callback: @escaping () -> ()) {
        shared.onStartVoting = callback
    }
    
    static func onShowResults(_ callback: @escaping () -> ()) {
        shared.onShowResults = callback
    }
    
    static func playerStatus(_ name: String) -> String {
        return (shared.channel?.presence.firstMetaValue(id: name, key: "status"))!
    }
}
