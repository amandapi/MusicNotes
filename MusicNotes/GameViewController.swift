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
import AVFoundation
import GameKit

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
    
    var audioPlayer = AVAudioPlayer()
    var fileNSURL = NSURL()
    
    var hintView: UIImageView? // for hint
    var returnButton: UIButton?  // for congratulations
    var backButton: UIButton?  // for gameOver
    var isPause: Bool = false // for playPauseButton
    var isStarted: Bool = false
    var startButton: UIButton? // for scene
    
    var scoreStars1ImageView: UIImageView?
    var scoreStars2ImageView: UIImageView?
    var scoreStars3ImageView: UIImageView?
    var numStars: Int!
        
    var selectedSong: NSArray?
    
    var level: Level!
    func setLevel(level: Level) {
        self.level = level
    }

    @IBAction func stop(sender: UIButton) {

        self.navigationController?.popViewControllerAnimated(true)
        print("audioPlayer is \(audioPlayer)")
//        if audioPlayer != 0 {
            playRewardSong()  // it seems that audioPlayer needs something to play before it can .stop()
            audioPlayer.stop()
//        }
    }

    @IBOutlet weak var playPause: UIButton!
    
    @IBAction func playPause(sender: UIButton) {
        setPaused(!isPause)
    }
    
    func setPaused(paused: Bool) {
        
        isPause = paused
        
        if (!isStarted) {
            scene.startLevel()
        }
        
        if isPause {
            playPause.setImage(UIImage(named: "play"), forState: UIControlState.Normal)
            if scene.timer != nil {
                scene.timer!.invalidate()
            }
            scene.instructionLabel.alpha = 0.38
            scene.roamingNoti!.alpha = 0.38
            scene.self.speed = 0
        } else {
            playPause.setImage(UIImage(named: "pause"), forState: UIControlState.Normal)
            scene.startCountdown()
            scene.instructionLabel.alpha = 1.0
            scene.roamingNoti!.alpha = 1.0
            scene.self.speed = 1
        }
    }
    
    @IBAction func hint(sender: UIButton) {
        showHint()
    }
    
    @IBAction func gameCenter(sender: UIButton) {
        let  localPlayer = GKLocalPlayer.localPlayer()
//        let localPlayer = GKLocalPlayer.localPlayer()
        localPlayer.authenticateHandler = {(viewController, error) -> Void in
            
            if (viewController != nil) {
                self.presentViewController(viewController!, animated: true, completion: nil)
            }
            else {
                print((GKLocalPlayer.localPlayer().authenticated))
            }
        }
    }
 
    @IBAction func shareOnFacebook(sender: UIButton) {
        if SLComposeViewController.isAvailableForServiceType(SLServiceTypeFacebook) {
            let shareOnFacebook : SLComposeViewController = SLComposeViewController(forServiceType: SLServiceTypeFacebook)
            shareOnFacebook.setInitialText("I want to share this App called MusicNotes") // new faceBook policy doesnot allow pre-set message
            shareOnFacebook.addImage(UIImage(named: "MusicNotesAppIconSmall.png"))
            self.presentViewController(shareOnFacebook, animated: true, completion: nil)
        } else {
            let alert = UIAlertController(title: "Accounts", message: "Please login to a Facebook account to share.", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
        }
    }

    @IBAction func shareOnTwitter(sender: UIButton) {
        if SLComposeViewController.isAvailableForServiceType(SLServiceTypeTwitter) {
            let shareOnTwitter : SLComposeViewController = SLComposeViewController(forServiceType: SLServiceTypeTwitter)
            shareOnTwitter.setInitialText("I want to share this App called MusicNotes")
            shareOnTwitter.addImage(UIImage(named: "MusicNotesAppIconSmall.png"))
            self.presentViewController(shareOnTwitter, animated: true, completion: nil)
        } else {
            let alert = UIAlertController(title: "Accounts", message: "Please login to a Twitter account to tweet.", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
        }
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
        let currentChallenge = level.challengesArray[currentChallengeIndex] as! Challenge
        scene.updateChallenge(currentChallenge)
        scene.updateClef(currentChallenge.clef)
        
        scene.gameSceneDelegate = self
          
        scene.startButton = self.startButton
        addStartButton()
                
        skView.presentScene(scene)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        let skView = self.view as! SKView
        _ = skView.scene as! GameScene
    }
    
    override func shouldAutorotate() -> Bool {
        return true
    }
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        let orientation: UIInterfaceOrientationMask = [UIInterfaceOrientationMask.Portrait, UIInterfaceOrientationMask.PortraitUpsideDown]
        return orientation
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }

    func notiDidScore(didScore: Bool) {
        deadCount = scene.deadCount  // get deadCount from GameScene
        
        if deadCount < 3  {
            currentChallengeIndex++
            if (currentChallengeIndex < level.challengesArray.count){
                let challenge = level.challengesArray[currentChallengeIndex] as! Challenge
                scene.updateChallenge(challenge)
                scene.updateClef(challenge.clef)
                scene.addNoti()
                scene.followRoamingPath()
            } else {
                score = scene.score // get score from GameScene
                congratulations()
                addStars()
                endLevelWithSuccess()
            }
        } else {
            gameOver()
        }
    }
    
    func timesUpDelegateFunc() {  // when timesUp
        // add condition "if deadCount < 3"?
        flashTimesUp()
        scene.instructionLabel.alpha = 0.38
        scene.roamingNoti!.alpha = 0.38
        scene.timer!.invalidate()
        scene.self.speed = 0
        addTryAgainButton()
    }
 
    func flashTimesUp() {  // moved from gameScene to here
        let timesUpLabel = UILabel(frame: CGRectMake(800 , self.view.frame.size.height/6 , self.view.frame.size.width/1.2, self.view.frame.size.width/10))
        timesUpLabel.textAlignment = NSTextAlignment.Center
        timesUpLabel.numberOfLines = 0
        timesUpLabel.text = "Time's Up!"
        timesUpLabel.textColor = UIColor.redColor()
        if (UIDevice.currentDevice().userInterfaceIdiom == .Pad) {
            timesUpLabel.font = UIFont(name: "Komika Display", size: 88)
        } else if (UIDevice.currentDevice().userInterfaceIdiom == .Phone) {
            timesUpLabel.font = UIFont(name: "Komika Display", size: 38)
        }
        timesUpLabel.sizeToFit()
        self.view.addSubview(timesUpLabel)
        // animate label
        UIView.animateWithDuration(2.0, delay: 0.0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.0, options: .CurveLinear, animations: {
            timesUpLabel.center = CGPoint(x: self.view.frame.size.width/2, y:self.view.frame.size.height/4.3 )
            }, completion: nil)
    }
    
    func showHint() {
        self.hintView = UIImageView(image: UIImage(named: "hintContent.png"))
        hintView!.frame = view.frame
        hintView!.userInteractionEnabled = true
        hintView!.alpha = 0.0
        view.addSubview(hintView!)
        addIGotItButton()
    }
    
    func hintViewReturnButtonPressed() {
        UIView.animateWithDuration(1.8, animations: { () -> Void in
            self.hintView!.alpha = 0.0
        })
    }
    
    func gameOver() {
        scene.flashGameOver()
        scene.instructionLabel.removeFromParent()
        scene.timer!.invalidate()
        addTryAgainButton()
    }
    
    func addStartButton() { // for scene
        let startButton = UIButton(type: .System)
        startButton.setTitle("Start!", forState: UIControlState.Normal)
        startButton.setTitleColor(UIColor.yellowColor(), forState: .Normal)
        if (UIDevice.currentDevice().userInterfaceIdiom == .Pad) {
            startButton.titleLabel!.font = UIFont(name: "Komika Display", size: 88)
        } else if (UIDevice.currentDevice().userInterfaceIdiom == .Phone) {
            startButton.titleLabel!.font = UIFont(name: "Komika Display", size: 38)
        }
        startButton.backgroundColor = UIColor.clearColor()
        startButton.frame = CGRectMake(view.frame.size.width/30, view.frame.size.height/1.38, view.bounds.width, view.bounds.height/50) // view.bounds.height/2
        startButton.addTarget(self, action: "startButtonPressed", forControlEvents: UIControlEvents.TouchUpInside)
        startButton.hidden = false
        print("startButton1: \(startButton)")
  //      startButton = scene.startButton!
        view.addSubview(startButton)
    }
    
    func startButtonPressed() {
        print("startButtonPressed")
    }
    
    func addIGotItButton() {
        let returnButton = UIButton(type: .System)
        returnButton.setTitle("I got it!", forState: UIControlState.Normal)
        returnButton.setTitleColor(UIColor.blueColor(), forState: .Normal)
        if (UIDevice.currentDevice().userInterfaceIdiom == .Pad) {
             returnButton.titleLabel!.font = UIFont(name: "Komika Display", size: 88)
        } else if (UIDevice.currentDevice().userInterfaceIdiom == .Phone) {
             returnButton.titleLabel!.font = UIFont(name: "Komika Display", size: 68)
        }
        returnButton.backgroundColor = UIColor.clearColor()
        returnButton.frame = CGRectMake(0 , hintView!.bounds.height*3/4, hintView!.bounds.width, hintView!.bounds.height/6)
        returnButton.addTarget(self, action: "hintViewReturnButtonPressed", forControlEvents: UIControlEvents.TouchUpInside)
        hintView!.addSubview(returnButton)
        
        // animate hintView
        hintView!.center = self.view.center
        UIView.animateWithDuration(1.8, delay: 0.0, options: .CurveEaseOut, animations:{
            self.hintView!.alpha = 1.0
            }, completion: nil)
    }
    
    func addTryAgainButton() {
        let backButton = UIButton(type: .System)
        backButton.setTitle("Try again", forState: UIControlState.Normal)
        backButton.setTitleColor(UIColor.redColor(), forState: .Normal)
        if (UIDevice.currentDevice().userInterfaceIdiom == .Pad) {
            backButton.titleLabel!.font = UIFont(name: "Komika Display", size: 88)
        } else if (UIDevice.currentDevice().userInterfaceIdiom == .Phone) {
            backButton.titleLabel!.font = UIFont(name: "Komika Display", size: 38)
        }
        backButton.backgroundColor = UIColor.clearColor()
        backButton.frame = CGRectMake(view.frame.size.width/2 , view.frame.size.height/2, view.bounds.width, view.bounds.height/6)
        backButton.center.x = view.center.x
        backButton.addTarget(self, action: "tryAgainButtonPressed", forControlEvents: UIControlEvents.TouchUpInside)
        view.addSubview(backButton)
        
        // animate button
        let bounds = backButton.bounds
        UIView.animateWithDuration(2.0, delay: 1.5, usingSpringWithDamping: 0.08, initialSpringVelocity: 13, options:[], animations: {
            backButton.bounds = CGRect(x: bounds.origin.x, y: bounds.origin.y - 80, width: bounds.size.width, height: bounds.size.height + 100)
            backButton.enabled = true
            }, completion: nil)        
    }
    
    func endLevelWithSuccess() {
        scene.instructionLabel.removeFromParent()
    }
    
    func congratulations() {
        let congratulationsLabel = UILabel(frame: CGRectMake(800 , self.view.frame.size.height/6 , self.view.frame.size.width/1.2, self.view.frame.size.width/10))
        congratulationsLabel.textAlignment = NSTextAlignment.Center
        congratulationsLabel.numberOfLines = 0
        congratulationsLabel.text = "Congratulations! \n You scored \(score) out of \(level.challengesArray.count)"
        congratulationsLabel.textColor = UIColor.redColor()
        if (UIDevice.currentDevice().userInterfaceIdiom == .Pad) {
            congratulationsLabel.font = UIFont(name: "Komika Display", size: 68)
        } else if (UIDevice.currentDevice().userInterfaceIdiom == .Phone) {
            congratulationsLabel.font = UIFont(name: "Komika Display", size: 38)
        }
        congratulationsLabel.sizeToFit()
        self.view.addSubview(congratulationsLabel)
        // animate label
        UIView.animateWithDuration(2.0, delay: 0.0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.0, options: .CurveLinear, animations: {
        congratulationsLabel.center = CGPoint(x: self.view.frame.size.width/2, y:self.view.frame.size.height/4.3 )
            }, completion: nil)
        scene.timer!.invalidate()
        playRewardSong()
        addBackButton()
        
        // make a background using particles and to show text better
        let textureManyStars = SKTexture(imageNamed: "particleManyStars")
        let manyStars = SKEmitterNode()
        manyStars.particleTexture = textureManyStars
        manyStars.position = CGPointMake(self.view.frame.size.width/2, self.view.frame.size.height/2)
        manyStars.particlePositionRange = CGVectorMake(self.view.frame.size.width*0.8, self.view.frame.size.height*0.8)
        manyStars.particleBirthRate = 88
        manyStars.numParticlesToEmit = 1680
        manyStars.particleLifetime = 0.8
        manyStars.particleLifetimeRange = 1.0
        manyStars.particleSpeed = 20.0
        manyStars.particleSpeedRange = 10.0
        manyStars.particleAlpha = 0.75
        manyStars.particleRotation = 3.0
        manyStars.particleRotationRange = 1.0
        manyStars.particleScale = 0.5
        manyStars.particleScaleRange = 0.6
        manyStars.particleScaleSpeed = 0.5
        manyStars.emissionAngleRange = 360.0
        scene.addChild(manyStars)
    }
    
    func playRewardSong() {
        let soundFilenames = ["rewardMozartSymphony40.wav" , "rewardProkofievPeter.wav" , "rewardTchaikovskySugarplum.wav" , "rewardBachBrandenburg3.wav" , "rewardChopinMazurkaE.wav" , "rewardVivaldiSpring.wav", "rewardBeethovenSym9.wav"]
        let randomIndex = Int(arc4random_uniform(UInt32(soundFilenames.count)))
        let selectedFilename = soundFilenames[randomIndex]
        // AVAudioPlayer play song
        audioPlayer = AVAudioPlayer()
        let path = NSBundle.mainBundle().pathForResource(selectedFilename, ofType:nil)
        let fileURL = NSURL(fileURLWithPath: path!)
        do {
            try audioPlayer = AVAudioPlayer(contentsOfURL: fileURL, fileTypeHint: nil)
        } catch {
            print("error at audioPlayer")
        }
        audioPlayer.prepareToPlay()
        audioPlayer.play()
    }
    
    func addStars() {
        let scoreStars1ImageView = UIImageView(image: UIImage(named: "scoreStars1.png")!)
        let scoreStars2ImageView = UIImageView(image: UIImage(named: "scoreStars2.png")!)
        let scoreStars3ImageView = UIImageView(image: UIImage(named: "scoreStars3.png")!)
        scoreStars1ImageView.contentMode = .ScaleAspectFit
        scoreStars2ImageView.contentMode = .ScaleAspectFit
        scoreStars3ImageView.contentMode = .ScaleAspectFit
        scoreStars1ImageView.frame = CGRect(x: self.view.frame.size.width/4, y:self.view.frame.size.height/3, width: self.view.frame.size.width/2, height: self.view.frame.size.height/5)
        scoreStars2ImageView.frame = scoreStars1ImageView.frame
        scoreStars3ImageView.frame = scoreStars1ImageView.frame
 
        if (score == level.challengesArray.count) {
            view.addSubview(scoreStars3ImageView)
            numStars = 3
        } else if (score <= level.challengesArray.count - 2) {
            view.addSubview(scoreStars1ImageView)
            numStars = 1
        } else {
            view.addSubview(scoreStars2ImageView)
            numStars = 2
        }

        // save numStars to defaults
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.setInteger(numStars, forKey: level.keyForLevelScore())
        
    }
    
    func addBackButton() { // after winning level
        let backButton = UIButton(type: .System)
        backButton.setTitle("More!", forState: UIControlState.Normal)
        backButton.setTitleColor(UIColor.redColor(), forState: .Normal)
        if (UIDevice.currentDevice().userInterfaceIdiom == .Pad) {
            backButton.titleLabel!.font = UIFont(name: "Komika Display", size: 128)
        } else if (UIDevice.currentDevice().userInterfaceIdiom == .Phone) {
            backButton.titleLabel!.font = UIFont(name: "Komika Display", size: 68)
        }
        //backButton.titleLabel!.font = UIFont(name: "Komika Display", size: 68)
        backButton.frame = CGRectMake(view.frame.size.width/2 , view.frame.size.height/2, view.bounds.width, view.bounds.height/6)
        backButton.center.x = view.center.x
        backButton.addTarget(self, action: "wonMoreButtonPressed", forControlEvents: UIControlEvents.TouchUpInside)
        view.addSubview(backButton)
    }
    
    func wonMoreButtonPressed() { // after winning level
        audioPlayer.stop()
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    func tryAgainButtonPressed() {  // after gameOver and after timesUp
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    func levelDidBegin() {
        isStarted = true
        setPaused(false)
    }
    
 }
