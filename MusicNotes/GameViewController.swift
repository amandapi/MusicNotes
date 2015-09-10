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
    var clef: String!
    var score: Int!
    var congratulationsLabel: UILabel?
    var deadCount: Int!
    
    var level: Level!
    func setLevel(level: Level) {
        self.level = level
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
        
        // pass information about the level to the GameScene Object
        scene.setLevel(level)
        
        // pass background to GameScene
        scene.updateBackground(level.background)
        
        // pass timeLimit to GameScene
        scene.updateTimeLimit(level.timeLimit)
        
        // randomize challenges and pass challenges and clef to GameScene
        level.randomizeChallenges()
        var currentChallenge = level.challengesArray[currentChallengeIndex] as! Challenge
        scene.updateChallenge(currentChallenge)
        scene.updateClef(currentChallenge.clef)
        
        scene.gameSceneDelegate = self
        
        skView.presentScene(scene)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        let skView = self.view as! SKView
        let scene = skView.scene as! GameScene
        //scene.level = self.level
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
        deadCount = scene.deadCount
        if deadCount < 3 {
            currentChallengeIndex++
            if (currentChallengeIndex < level.challengesArray.count){
                var challenge = level.challengesArray[currentChallengeIndex] as! Challenge
                scene.updateChallenge(challenge)
                scene.updateClef(challenge.clef)
                scene.addNoti()
                scene.followRoamingPath()
            } else {
                score = scene.score // get score from GameScene
                congratulations()
                endLevelWithSuccess()
            }
        } else {
            gameOver()
        }
    }
    
    func gameOver() {
        scene.flashGameOver()
        scene.instructionLabel.removeFromParent()
        // how to segue to LevelViewController
    }
    
    func endLevelWithSuccess() {
        scene.instructionLabel.removeFromParent()
        // how to segue to LevelViewController
    }
    
    func congratulations() {
        var congratulationsLabel = UILabel(frame: CGRectMake(800 , self.view.frame.size.height/6 , self.view.frame.size.width/1.2, self.view.frame.size.width/10))
        congratulationsLabel.textAlignment = NSTextAlignment.Center
        congratulationsLabel.numberOfLines = 0
        congratulationsLabel.text = "Congratulations! \n You scored \(score) out of \(level.challengesArray.count)"
        congratulationsLabel.textColor = UIColor.redColor()
        congratulationsLabel.font = UIFont(name: "Komika Display", size: 52)
        congratulationsLabel.sizeToFit()
        self.view.addSubview(congratulationsLabel)
        
        // animate congratulationsLabel
        UIView.animateWithDuration(2.0, delay: 0.0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.0, options: .CurveLinear, animations: {
        congratulationsLabel.center = CGPoint(x: self.view.frame.size.width/2, y:self.view.frame.size.height/4.3 )
            }, completion: nil)
        
        // play sound
        scene.playSound("MozartSymphony40.caf")
        
        // add stars
        addStars()
    }
    
    func addStars() {
        //let scoreStarsImage = UIImage(named: "scoreStars2.png")
        
        let scoreStar1ImageView = UIImageView(image: UIImage(named: "scoreStar1.png")!)
        let scoreStars2ImageView = UIImageView(image: UIImage(named: "scoreStars2.png")!)
        let scoreStars3ImageView = UIImageView(image: UIImage(named: "scoreStars3.png")!)
        scoreStar1ImageView.contentMode = .ScaleAspectFit
        scoreStars2ImageView.contentMode = .ScaleAspectFit
        scoreStars3ImageView.contentMode = .ScaleAspectFit
        scoreStar1ImageView.frame = CGRect(x: self.view.frame.size.width/4, y:self.view.frame.size.height/3, width: 600, height: 100)
        scoreStars2ImageView.frame = CGRect(x: self.view.frame.size.width/4, y:self.view.frame.size.height/3, width: 600, height: 100)
        scoreStars3ImageView.frame = CGRect(x: self.view.frame.size.width/4, y:self.view.frame.size.height/3, width: 600, height: 100)
        
        if (score <= level.challengesArray.count - 3) {
            view.addSubview(scoreStar1ImageView)
        } else if (score < level.challengesArray.count) {
            view.addSubview(scoreStars2ImageView)
        } else if (score == level.challengesArray.count) {
            view.addSubview(scoreStars3ImageView)
        }
    }

}

