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
    var challengesArray: NSMutableArray!
    
    required init(background: String, clef: String, challenges: NSDictionary) {
        //fatalError("NSCoding not supported")
        self.background = background
        self.clef = clef
        self.challenges = challenges
       
        // create an array out of the challenges in a given level
        
        challengesArray = NSMutableArray()
        for key in challenges.allKeys{
            let value = challenges.objectForKey(key) as! NSArray
            let instruction = value[0] as! String
            let destination = value[1] as! String
            let sound = value[2] as! String
        challengesArray.addObject(Challenge(instruction: instruction, destination: destination, sound: sound))
            //randomizeChallenges()
        }

/*
        var challengesArray : Array<NSArray> = []
        for (key, value) in challenges {
            challengesArray.append(value as! NSArray)
            //println("challengesArray has key \(key) and value \(challengesArray)")
            }
*/
    }
    
    

        func randomizeChallenges() {
            //var randomChallenges = NSMutableArray(capacity: challengesArray.count)
            for i in 0..<challengesArray.count {
                let randomNumber = Int(arc4random_uniform(UInt32(challengesArray.count)))
                let object: AnyObject = challengesArray[randomNumber]
                challengesArray.removeObjectAtIndex(randomNumber)
            }
        }
    
    }
