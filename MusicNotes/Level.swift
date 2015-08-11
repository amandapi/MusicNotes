//
//  Level.swift
//  MusicNotes
//
//  Created by Amanda Pi on 2015-07-21.
//  Copyright (c) 2015 Amanda. All rights reserved.
//

import Foundation

class Level {
    
    let background: String!
    let clef: String!
    let challenges: NSDictionary!
    
    required init(background: String, clef: String, challenges: NSDictionary) {
        //fatalError("NSCoding not supported")
        self.background = background
        self.clef = clef
        self.challenges = challenges
    }
}
