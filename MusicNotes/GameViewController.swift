//
//  GameViewController.swift
//  MusicNotes
//
//  Created by Amanda Pi on 2015-05-31.
//  Copyright (c) 2015 Amanda. All rights reserved.
//

import UIKit
import SpriteKit

class GameViewController: UIViewController {
    
    var scene: GameScene!
    var destinationNode = SKSpriteNode()
    var challengesArray: [NSArray] = []
    var currentChallengeIndex: Int = 0
    var instruction: String!
    var destination: String!
    var sound: String!
    
    var level: Level!
    func setLevel(level: Level) {
        self.level = level
        //println("check level is \(level)")
        //println("check level.background is \(level.background)")  // returns bg5 when button 5 is pressed
    }
      
    override func viewDidLoad() {
        super.viewDidLoad()
        
    if let scene = GameScene(size: view.frame.size) as GameScene? {
        
            //scene.chellengeDelegate = self
        
            // Configure the view.
            let skView = self.view as! SKView
            skView.showsFPS = true
            skView.showsNodeCount = true
            skView.showsPhysics = true
            /* Sprite Kit applies additional optimizations to improve rendering performance */
            skView.ignoresSiblingOrder = false
            
            /* Set the scale mode to scale to fit the window */
            scene.scaleMode = .AspectFill
        
            // here is to pass information about the level to the GameScene Object
            scene.setLevel(level)
        
            // here is to ask GameScene to update variables according to level
            scene.updateBackground(level.background)
            scene.updateClef(level.clef)
            //scene.updateChallenge(level.challenges)
        
      
        
        //Homework: level.randomizeChallenges() for every level, then use challengesArray, keep track of challengeIndex
        
        
        var challengesArray = NSMutableArray()
        for challenge in level.challenges {
        challengesArray.insertObject(Challenge.self, atIndex: 0)
        println(challengesArray)
        }
        
        
        
        // randomize the challenges once at the beginning of the level
        level.randomizeChallenges()
        println(level)
        println(challengesArray)
        
        // track the challenge of the current index
        //currentChallengeIndex = 0 // this should be a property of GameViewController
       // for key in challengesArray.keys {
        //    currentChallengeIndex = challengesArray.index()

        // pass the first challenge to GameScene
      //  scene.updateChallenge(level.challengesArray[currentChallengeIndex] as! Challenge)
        
        

        
/*        var challengesArray = NSMutableArray()
        for challenge in level.challenges {
            println("challengeP is \(challenge)")
            
            challengesArray.insertObject(Challenge.self, atIndex: 0)
            level.randomizeChallenges()
            scene.updateChallenge(Challenge(instruction: String(), destination: String(), sound: String()))
            //challengesArray.addObject(Challenge)

            level.randomizeChallenges()
            //println(level) // gives MusicNotes.Level

            println("challengeQ is \(challenge)") // gives one challenge
            
        }
*/
        
        
        
            skView.presentScene(scene)
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        let skView = self.view as! SKView
        let scene = skView.scene as! GameScene
 //       scene.level = self.level
        
    }

    override func shouldAutorotate() -> Bool {
        return true
    }
    
    override func supportedInterfaceOrientations() -> Int {
/*        if UIDevice.currentDevice().userInterfaceIdiom == .Phone {
            return Int(UIInterfaceOrientationMask.AllButUpsideDown.rawValue)
        } else {
            return Int(UIInterfaceOrientationMask.All.rawValue)
        }
*/
        return Int(UIInterfaceOrientationMask.LandscapeLeft.rawValue)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }

}

