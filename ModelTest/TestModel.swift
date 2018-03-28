//
//  TestModel.swift
//  ModelTest
//
//  Created by D. Sijbring on 07/03/2018.
//  Copyright © 2018 D. Sijbring. All rights reserved.
//

// ALL TUNABLE PARAMETERS.
// --------------ACT-R-------------
// retrieval threshold, baselevel decay, activation noise, latency factor\
// --------------MODEL-------------
// responseTime, addToDMTime, checkDMTime, attendModel, attendTarget

import Foundation


class TestModel: Model {
    var lastEvent: Double = 0.0
    var nextEvent: Double = 0.0
    var modelCards = [Int]()
    var targetCards = [Int]()
    var attendedCardsModel = [Int]()
    var attendedCardsTarget = [Int]()
    var foundChunk = false
    var startTime = 0.0
    var endTime = 0.0
    var foundTime = 0.0
    
    ///TUNABLE TIMES
    var responseTime = 0.2
    var addToDMTime = 0.1
    var checkDMTime = 0.15
    
    ///TUNABLE AMOUNTS
    var attendModel = 2
    var attentTarget = 3
    
    init(game: Dobble) {
        self.modelCards = game.modelCards
        self.targetCards = game.targetCards
    }
    
    func attendCard(identifier: Int, amount: Int) {
        var cards = [Int]()
        var cardChar: String = ""
        if identifier==0 {
            cards = modelCards
            cardChar = "model"
        } else {
            cards = targetCards
            cardChar = "target"
        }
            for _ in 1...amount {
                if foundChunk == true {
                    break
                }
                let randomNumber = Int(arc4random_uniform(8))
                
                let cardID = cards[randomNumber]
                
                
                let chunk = generateNewChunk(string: "")
                chunk.setSlot(slot: "isa", value: "symbol")
                chunk.setSlot(slot: "card", value: cardChar)
                chunk.setSlot(slot: "id", value: String(cardID))
                
                let ch = dm.addToDMOrStrengthen(chunk: chunk)
                time += addToDMTime
                
                checkMemory(chunk: ch)
                
                
            }
        
        
        
        
    }
    
    func checkMemory(chunk: Chunk) {
        time += checkDMTime
        var cardChar = ""
        
        if String(describing: chunk.slotValue(slot: "card")!) == "model" {
            cardChar = "target"
        } else {
            cardChar = "model"
        }
        let cardID = String(describing: chunk.slotValue(slot: "id")!)
        
        let goalChunk = generateNewChunk(string: "")
        goalChunk.setSlot(slot: "isa", value: "symbol")
        goalChunk.setSlot(slot: "card", value: cardChar)
        goalChunk.setSlot(slot: "id", value: cardID)
        
        let result = dm.retrieve(chunk: goalChunk)
        if result.1 != nil {
            foundChunk = true
            time += responseTime
            endTime = time
        }
    }
    
    
    override func run() {
        startTime = time
        if foundChunk == true {
            foundChunk = false
            for (_, chunk) in dm.chunks {
                if String(describing: chunk.slotValue(slot: "card")!) == "model" {
                    dm.chunks.removeValue(forKey: chunk.name)
                }
            }
        }
        lastEvent = time
        super.run()
        nextEvent = time
        
        while foundChunk == false {
            attendCard(identifier: 0, amount: attendModel)
            attendCard(identifier: 1, amount: attentTarget)
        }
        foundTime = endTime - startTime
        
        
    }
    
    override func reset() {
        if modelText == "" {
            loadModel(fileName: "test")
        } else {
            super.reset()
            foundChunk = false
        }
        
        
    }
    
    
}
