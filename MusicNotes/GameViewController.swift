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
//import GameKit

class GameViewController: UIViewController, GameSceneDelegate {
    
    var scene: GameScene!
    var destinationNode = SKSpriteNode()
    var challengesArray: [NSArray] = []
    var currentChallengeIndex: Int = 0
    //var instruction: String!
    //var destination: String!
    var sound: String!
    var clef: String!
    var score: Int!
    var congratulationsLabel: UILabel?
    var deadCount: Int!
    var timesUpLabel: UILabel?

    var audioPlayer = AVAudioPlayer()
    var fileNSURL = NSURL()
    
    var timer : NSTimer?
    var timeLimit : Int?
    var timerCount : Int?
    
    var hintView: UIImageView? // for hint
//    var returnButton: UIButton?  // for congratulations
//    var backButton: UIButton?  // for gameOver
    var centerPlayButton: UIButton?
    var isPause: Bool = false // for playPauseButton
    var isStarted: Bool = false  // for playPauseButton
    
    var scoreStars1ImageView: UIImageView?
    var scoreStars2ImageView: UIImageView?
    var scoreStars3ImageView: UIImageView?
    var numStars: Int!
    var highNumStars = 0
        
    var selectedSong: NSArray?
    
    var level: Level!
    func setLevel(level: Level) {
        self.level = level
        timerCount = level.timeLimit
    }

    @IBAction func stop(sender: UIButton) {
        self.navigationController?.popViewControllerAnimated(true)
        if timer != nil  {
            timer!.invalidate()
        }
        playRewardSong()  // it seems that audioPlayer needs something to play before it can .stop()
        audioPlayer.stop()
    }

    @IBOutlet weak var playPause: UIButton!
    
    @IBAction func playPause(sender: UIButton) {
        setPaused(!isPause)
    }
    
    func setPaused(paused: Bool) {
 
        isPause = paused
        if (!isStarted) {
            scene.startLevel()
        } else {
            if isPause {
                playPause.setImage(UIImage(named: "play.png"), forState: UIControlState.Normal)
                scene.instructionLabel.hidden = true  // so no cheating
                scene.roamingNoti!.hidden = true // so no cheating
                showPlayCenterButton()
                scene.self.speed = 0
                if timer != nil  {
                timer!.invalidate()
                }
            } else {
                playPause.setImage(UIImage(named: "pause.png"), forState: UIControlState.Normal)
                if (level.timeLimit > 0) {  // only for levels 7,8,9
                    startCountdown()
                }
                scene.instructionLabel.hidden = false
                scene.roamingNoti!.hidden = false
                if centerPlayButton != nil {
                    centerPlayButton!.removeFromSuperview()
                }
                scene.self.speed = 1
            }
        }
    }
    
    func showPlayCenterButton() {
        let image = UIImage(named: "playCenter.png")?.imageWithRenderingMode(.AlwaysOriginal)
        centerPlayButton = UIButton(type: UIButtonType.Custom)
        centerPlayButton!.setImage(image, forState: .Normal)
        centerPlayButton!.frame = CGRectMake(0, 0, view.bounds.height*0.8, view.bounds.height*0.8)
        centerPlayButton!.center = CGPoint(x: view.bounds.width*0.5, y: view.bounds.height*0.5)
        centerPlayButton!.alpha = 0.5
        centerPlayButton!.addTarget(self, action: "centerPlayButtonPressed", forControlEvents: UIControlEvents.TouchUpInside)
        self.view?.addSubview(centerPlayButton!)
    }
    
    func centerPlayButtonPressed() {
        setPaused(!isPause)
    }
    
    @IBAction func hint(sender: UIButton) {
        showHint()
    }
    
    @IBAction func camera(sender: UIButton) {
        scene.playSound("shutter")
        let screenshot = self.view?.pb_takeSnapshot()
        UIImageWriteToSavedPhotosAlbum(screenshot!, nil, nil, nil)
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
    
    func startCountdown() { // for countdown timer
        timer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: Selector("tick"), userInfo: nil, repeats: true)
    }
    
    func tick() {  // for countdown
        if timerCount > 0 {
            timerCount = timerCount! - 1
            scene.timerLabel.text = "Timeleft : \(timerCount!)"
            scene.playSound("tick")
        } else {
            timer!.invalidate()
            timesUp()
        }
    }
    
    func timesUp() {
        // add condition "if deadCount < 3"?
        flashTimesUp()
        scene.instructionLabel.alpha = 0.38
        scene.roamingNoti!.alpha = 0.38
        scene.self.speed = 0
        addTryAgainButton()
    }
 
    func flashTimesUp() {
        let timesUpLabel = UILabel(frame: CGRectMake(self.view.frame.size.width*0.2 , self.view.frame.size.height*0.26 , self.view.frame.size.width, self.view.frame.size.height*0.2))
        timesUpLabel.textAlignment = NSTextAlignment.Center
        timesUpLabel.text = "Time's Up"
        timesUpLabel.alpha = 1.0
        timesUpLabel.textColor = UIColor(red: 0.871, green: 0.282, blue: 0.228, alpha: 1.0)
        if (UIDevice.currentDevice().userInterfaceIdiom == .Pad) {
            timesUpLabel.font = UIFont(name: "Komika Display", size: 128)
        } else if (UIDevice.currentDevice().userInterfaceIdiom == .Phone) {
            timesUpLabel.font = UIFont(name: "Komika Display", size: 68)
        }
        timesUpLabel.sizeToFit()
        self.view.addSubview(timesUpLabel)
        // animate label
        timesUpLabel.alpha = 0
        UIView.animateWithDuration(0.38, delay: 0, options: [UIViewAnimationOptions.Autoreverse, UIViewAnimationOptions.Repeat], animations:
            {UIView.setAnimationRepeatCount(2)
            timesUpLabel.alpha = 1
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
        if timer != nil {
            timer!.invalidate()
        }
        addTryAgainButton()
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
        let tryAgainButton = UIButton(type: .System)
        tryAgainButton.setTitle("Try again", forState: UIControlState.Normal)
        tryAgainButton.setTitleColor(UIColor(red: 0.871, green: 0.282, blue: 0.228, alpha: 1.0), forState: .Normal)
        if (UIDevice.currentDevice().userInterfaceIdiom == .Pad) {
            tryAgainButton.titleLabel!.font = UIFont(name: "Komika Display", size: 128)
        } else if (UIDevice.currentDevice().userInterfaceIdiom == .Phone) {
            tryAgainButton.titleLabel!.font = UIFont(name: "Komika Display", size: 68)
        }
        tryAgainButton.contentVerticalAlignment = .Center
        tryAgainButton.frame = CGRectMake(view.frame.size.width*0.5 , self.view.frame.size.height*0.3, view.bounds.width, view.bounds.height*0.58)
        tryAgainButton.backgroundColor = UIColor.clearColor()
        tryAgainButton.center.x = view.center.x
        tryAgainButton.addTarget(self, action: "tryAgainButtonPressed", forControlEvents: UIControlEvents.TouchUpInside)
        view.addSubview(tryAgainButton)
        // animate button
        let bounds = tryAgainButton.bounds
        UIView.animateWithDuration(2.0, delay: 2.3, usingSpringWithDamping: 0.28, initialSpringVelocity: 3.8, options:[], animations: {
            tryAgainButton.bounds = CGRect(x: bounds.origin.x, y: bounds.origin.y + 600, width: bounds.size.width, height: bounds.size.height)
            tryAgainButton.enabled = true
            }, completion: nil)        
    }
    
    func endLevelWithSuccess() {
        scene.instructionLabel.removeFromParent()
    }
    
    func congratulations() {
        let congratulationsLabel = UILabel(frame: CGRectMake(800 , self.view.frame.size.height*0.167 , self.view.frame.size.width*0.83, self.view.frame.size.width*0.1))
        congratulationsLabel.textAlignment = NSTextAlignment.Center
        congratulationsLabel.numberOfLines = 0
        congratulationsLabel.text = "Congratulations! \n You scored \(score) out of \(level.challengesArray.count)"
        congratulationsLabel.textColor = UIColor(red: 0.871, green: 0.282, blue: 0.228, alpha: 1.0)
        if (UIDevice.currentDevice().userInterfaceIdiom == .Pad) {
            congratulationsLabel.font = UIFont(name: "Komika Display Tight", size: 78)
        } else if (UIDevice.currentDevice().userInterfaceIdiom == .Phone) {
            congratulationsLabel.font = UIFont(name: "Komika Display Tight", size: 38)
        }
        congratulationsLabel.sizeToFit()
        self.view.addSubview(congratulationsLabel)
        // animate label
        UIView.animateWithDuration(2.0, delay: 0.0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.0, options: .CurveLinear, animations: {
        congratulationsLabel.center = CGPoint(x: self.view.frame.size.width/2, y:self.view.frame.size.height/4.3 )
            }, completion: nil)
        if timer != nil {
            timer!.invalidate()
        }
        playRewardSong()
        addNextButton()
        
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
        scoreStars1ImageView.frame = CGRect(x: self.view.frame.size.width*0.25, y:self.view.frame.size.height*0.38, width: self.view.frame.size.width*0.5, height: self.view.frame.size.height*0.2)
        scoreStars2ImageView.frame = scoreStars1ImageView.frame
        scoreStars3ImageView.frame = scoreStars1ImageView.frame
        
         // save highNumStars to defaults
        let defaults = NSUserDefaults.standardUserDefaults()
        var highNumStars = defaults.integerForKey(level.keyForLevelScore())
        
        if (score == level.challengesArray.count) {
            view.addSubview(scoreStars3ImageView)
            numStars = 3
        } else if (score == level.challengesArray.count - 1) {
            view.addSubview(scoreStars2ImageView)
            numStars = 2
        } else if (score == level.challengesArray.count - 2) {
            view.addSubview(scoreStars1ImageView)
            numStars = 1
        } else {
            numStars = 0
        }
        highNumStars = max(numStars, highNumStars)
        
        defaults.setInteger(highNumStars, forKey: level.keyForLevelScore())
        defaults.synchronize()
    }
    
    func addNextButton() {
        let nextButton = UIButton(type: .System)
        nextButton.setTitle("Next", forState: UIControlState.Normal)
        nextButton.setTitleColor(UIColor(red: 0.871, green: 0.282, blue: 0.228, alpha: 1.0), forState: .Normal)        
        if (UIDevice.currentDevice().userInterfaceIdiom == .Pad) {
            nextButton.titleLabel!.font = UIFont(name: "Komika Display", size: 128)
        } else if (UIDevice.currentDevice().userInterfaceIdiom == .Phone) {
            nextButton.titleLabel!.font = UIFont(name: "Komika Display", size: 68)
        }
        nextButton.contentVerticalAlignment = .Center
        nextButton.frame = CGRectMake(view.frame.size.width*0.5 , self.view.frame.size.height*0.4, view.bounds.width, view.bounds.height*0.58)
        nextButton.center.x = view.center.x
        nextButton.backgroundColor = UIColor.clearColor()
        nextButton.addTarget(self, action: "nextButtonPressed", forControlEvents: UIControlEvents.TouchUpInside)
        view.addSubview(nextButton)
        // animate button
        let bounds = nextButton.bounds
        UIView.animateWithDuration(2.0, delay: 6.3, usingSpringWithDamping: 0.28, initialSpringVelocity: 3.8, options:[], animations: {
            nextButton.bounds = CGRect(x: bounds.origin.x, y: bounds.origin.y + 600, width: bounds.size.width, height: bounds.size.height)
            nextButton.enabled = true
            }, completion: nil)
    }
    
    func nextButtonPressed() { // after winning level
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


extension UIView { // for camera button
    func pb_takeSnapshot() -> UIImage {
        UIGraphicsBeginImageContextWithOptions(bounds.size, false, UIScreen.mainScreen().scale)
        drawViewHierarchyInRect(self.bounds, afterScreenUpdates: true)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
}
