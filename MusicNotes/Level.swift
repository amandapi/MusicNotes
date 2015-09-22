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
    let timeLimit: Int!
    let challenges: NSDictionary!
    var challengesArray: NSMutableArray!
    
    required init(background: String, timeLimit: Int, challenges: NSDictionary) {
        //fatalError("NSCoding not supported")
        self.background = background
        self.timeLimit = timeLimit
        self.challenges = challenges
       
        // create an array out of the challenges in a given level
        
        challengesArray = NSMutableArray()
        for key in challenges.allKeys{
            let value = challenges.objectForKey(key) as! NSArray
            let instruction = value[0] as! String
            let destination = value[1] as! String
            let sound = value[2] as! String
            let clef = value[3] as! String
            challengesArray.addObject(Challenge(instruction: instruction, destination: destination, sound: sound, clef: clef))
        }

/*
        // take an inspiring look inside Challenge
        for challenge in challengesArray {
            var c = challenge as! Challenge
        //println("take a look: \(c.instruction)")
        println("take a look: \(c.clef)")
        //println("take a look: \(c.destination)")
        //println("take a look: \(c.sound)")
        }
*/
    }

    func randomizeChallenges() {
        for _ in 0..<challengesArray.count {
            let randomNumber = Int(arc4random_uniform(UInt32(challengesArray.count)))
            let object: AnyObject = challengesArray[randomNumber]
            challengesArray.removeObjectAtIndex(randomNumber)
            challengesArray.insertObject(object, atIndex: 0)
            }
        }
    
    }
