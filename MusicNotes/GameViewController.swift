//
//  GameViewController.swift
//  MusicNotes
//
//  Created by Amanda Pi on 2015-05-31.
//  Copyright (c) 2015 Amanda. All rights reserved.
//

import UIKit
import SpriteKit
import Social

class GameViewController: UIViewController, GameSceneDelegate {
    
    @IBAction func hint(sender: UIButton) {
        showHint()
    }
    
    @IBAction func shareOnFacebook(sender: UIButton) {
        var shareToFacebook : SLComposeViewController = SLComposeViewController(forServiceType: SLServiceTypeFacebook)
        shareToFacebook.setInitialText("Hello I am playing MusicNotes")
        shareToFacebook.addImage(UIImage(named: "MusicNotesAppIconSmall.png"))
        //shareToFacebook.addURL(NSURL(www....))
        self.presentViewController(shareToFacebook, animated: true, completion: nil)
    }
    
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
    
    //var hintView = UIImageView()
    var hintView: UIImageView?
    var returnButton: UIButton?
    
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
    
    func showHint() {
        
        // create hintView
        self.hintView = UIImageView(image: UIImage(named: "hintContent.png"))
        //hintView!.frame = CGRectMake(self.view.center.x, self.view.center.y, view.bounds.width/1.28, view.bounds.height/1.28)
        //hintView.center = self.view.center
        hintView!.frame = view.frame
        hintView!.userInteractionEnabled = true
        
        hintView!.alpha = 0.0
        view.addSubview(hintView!)
        
        // create "OK!" button in hintView
        var returnButton = UIButton.buttonWithType(UIButtonType.System) as! UIButton
        returnButton.setTitle("OK!", forState: UIControlState.Normal)
        returnButton.setTitleColor(UIColor.blueColor(), forState: .Normal)
        returnButton.titleLabel!.font = UIFont(name: "Komika Display", size: 68)
        returnButton.backgroundColor = UIColor.clearColor()
        //returnButton.frame = CGRectMake(0 , hintView.center.y*1.2, hintView.bounds.width, hintView.bounds.height/6)
        returnButton.frame = CGRectMake(0 , 550, hintView!.bounds.width, hintView!.bounds.height/6)
        returnButton.addTarget(self, action: "returnButtonPressed", forControlEvents: UIControlEvents.TouchUpInside)
        hintView!.addSubview(returnButton)
        
        // animate appearance of hintView
        hintView!.center = self.view.center
        UIView.animateWithDuration(2.8, delay: 0.0, options: .CurveEaseOut, animations:{
            self.hintView!.alpha = 1.0
            }, completion: nil)
    }
    
    func returnButtonPressed() {
        UIView.animateWithDuration(2.8, animations: { () -> Void in
            self.hintView!.alpha = 0.0
        })
       // self.hintView?.removeFromSuperview()  // if hintView is not removed, will it stack up?
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
        congratulationsLabel.font = UIFont(name: "Komika Display", size: 38)
        congratulationsLabel.sizeToFit()
        self.view.addSubview(congratulationsLabel)
        
        // animate congratulationsLabel
        UIView.animateWithDuration(2.0, delay: 0.0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.0, options: .CurveLinear, animations: {
        congratulationsLabel.center = CGPoint(x: self.view.frame.size.width/2, y:self.view.frame.size.height/4.3 )
            }, completion: nil)
        
        // play sound
        playRewardSong()
        
        // add stars
        addStars()
    }
    
    func playRewardSong() {
        var rewardSongArray = ["rewardMozartSymphony40.wav" , "rewardProkofievPeterWolf.wav" , "rewardTchaikovskySugarplum.wav"]
        var randomSongIndex = 0
        randomSongIndex = Int(arc4random_uniform(UInt32(rewardSongArray.count)))
        var selectedSong = rewardSongArray[randomSongIndex]
        scene.runAction(SKAction.playSoundFileNamed(selectedSong, waitForCompletion: false))
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

