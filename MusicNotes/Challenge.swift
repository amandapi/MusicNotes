//
//  Challenge.swift
//  MusicNotes
//
//  Created by Amanda Pi on 2015-07-21.
//  Copyright (c) 2015 Amanda. All rights reserved.
//

import Foundation
//import SpriteKit

class Challenge {
    
    let instruction: String!
    let destination: String!
    let sound: String!
    //var destinationNode: SKSpriteNode!
    
    required init(instruction: String, destination: String, sound: String) {
  //required init(instruction: String, destination: String, sound: String, destinationNode: SKSpriteNode!) {
        //fatalError("NSCoding not supported")
        self.instruction = instruction
        self.destination = destination
        self.sound = sound
        //self.destinationNode = destinationNode
    }
}
