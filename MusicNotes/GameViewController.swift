//
//  GameViewController.swift
//  MusicNotes
//
//  Created by Amanda Pi on 2015-05-31.
//  Copyright (c) 2015 Amanda. All rights reserved.
//

import UIKit
import SpriteKit

class GameViewController: UIViewController, GameSceneDelegate {
    
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
        
        scene = GameScene(size: view.frame.size)
        
            // Configure the view
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
            //scene.updateChallenge(level.Challenge)
        
            level.randomizeChallenges()
        
            var currentChallenge = level.challengesArray[currentChallengeIndex] as! Challenge
            scene.updateChallenge(currentChallenge)
        
            scene.gameSceneDelegate = self
        
            skView.presentScene(scene)
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
    
    func notiDidScore(didScore: Bool) {
        currentChallengeIndex++
        if (currentChallengeIndex < level.challengesArray.count){
            var challenge = level.challengesArray[currentChallengeIndex] as! Challenge
            scene.updateChallenge(challenge)
        } else {
            // end the level here
        }
    }

}

