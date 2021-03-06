//
//  Challenge.swift
//  MusicNotes
//
//  Created by Amanda Pi on 2015-07-21.
//  Copyright (c) 2015 Amanda. All rights reserved.
//

import Foundation

class Challenge {
    
    let instruction: String!
    let destination: String!
    let sound: String!
    let clef: String!
    
    required init(instruction: String, destination: String, sound: String, clef: String) {
        self.instruction = instruction
        self.destination = destination
        self.sound = sound
        self.clef = clef
    }
}
