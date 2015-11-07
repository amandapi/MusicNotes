//
//  GameScene.swift
//  MusicNotes
//
//  Created by Amanda Pi on 2015-05-31.
//  Copyright (c) 2015 Amanda. All rights reserved.
//

import SpriteKit
import UIKit  // neccessary?
import Foundation   // neccessary?
import AVFoundation

protocol GameSceneDelegate {
    func levelDidBegin()
    func notiDidScore(didScore: Bool)
}

class GameScene: SKScene {
    
    var gameSceneDelegate: GameSceneDelegate?
    
    var level: Level!
    
    var noti = MusicNotes(imageNamed: String())
    var roamingNoti: MusicNotes?
    var draggingNoti: Bool = false
    var movingNoti: MusicNotes?
    //var scoringNoti: MusicNotes?
    var scoringNotiArray = [SKSpriteNode]()
    
    var lastUpdateTime: NSTimeInterval = 0.0
    var dt: NSTimeInterval = 0.0
    var timerLabel: SKLabelNode!
    var levelTimeLimit: Int?
    var timeLimit: Int!
    
    var scoreLabel = SKLabelNode(fontNamed: "Komika Display Tight")
    var score = 0
    var deadCountLabel = SKLabelNode(fontNamed: "Komika Display Bold")
    var deadCount = 0
    var startMsg = SKLabelNode()
    
    var challenge = NSArray()
    var instructionLabel = SKLabelNode(fontNamed: "Komika Display")
    var instruction: String?
    var destination: String?
    var destinationNode = SKSpriteNode()
    var sound = String()
    var clef = String()
    
    var background = SKSpriteNode()
    
    var clefTreble = SKSpriteNode()
    var clefBass = SKSpriteNode()
    var cf: SKSpriteNode?
    var clefRotating = SKSpriteNode()
    var playPause: UIButton?
    
    var gameState = GameState.StartingLevel
    
    // these are the "destinations" defined by sizes of "staffLines"
    let L0 = SKSpriteNode(imageNamed: "L0") // middle C with clefTreble
    let L0leger = SKSpriteNode(imageNamed: "Lleger") // leger line for middle C
    let S0 = SKSpriteNode(imageNamed: "S0")
    let L1 = SKSpriteNode(imageNamed: "L1")
    let S1 = SKSpriteNode(imageNamed: "S1")
    let L2 = SKSpriteNode(imageNamed: "L2")
    let S2 = SKSpriteNode(imageNamed: "S2")
    let L3 = SKSpriteNode(imageNamed: "L3")
    let S3 = SKSpriteNode(imageNamed: "S3")
    let L4 = SKSpriteNode(imageNamed: "L4")
    let S4 = SKSpriteNode(imageNamed: "S4")
    let L5 = SKSpriteNode(imageNamed: "L5")
    let S5 = SKSpriteNode(imageNamed: "S5")
    let L6 = SKSpriteNode(imageNamed: "L6")  // middle C with clefBass
    let L6leger = SKSpriteNode(imageNamed: "Lleger") // leger line for middle C
    
    let trashcan = SKSpriteNode(imageNamed: "trashcan")
    let trashcanLid = SKSpriteNode(imageNamed: "trashcanLid")
    
    required init(coder aDecoder: NSCoder) {
        fatalError("NSCoding not supported")
    }
    
    override init(size: CGSize) {
        super.init(size: size)
    }
    
    func setGameSceneDelegate(delegate: GameSceneDelegate) {
        gameSceneDelegate = delegate
    }

    func setLevel(level: Level) { // This block will be called by GameViewController's scene.setLevel(level) before skView.presentScene
        self.level = level
    }
    
    override func didMoveToView(view: SKView) {
        addStaffLines()
        addNoti()
        addTrashcanAndTrashcanLid()
        addStartMsg()
        setupCountLabels()
        setupTimerLabel()
        
        if gameState == .StartingLevel {
        paused = true
        }
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        
        switch gameState {
            
            case .StartingLevel:
                startLevel()
  
            //fallthrough  //suppressing this line prevents initial phantom notes to appear
            
            case .Playing:                
                let touch = touches.first
                let location = touch!.locationInNode(scene!)
                let node = nodeAtPoint(location)

                if node.name == "noti" && !scoringNotiArray.contains(node as! SKSpriteNode) {
                    roamingNoti!.removeAllActions()
                    roamingNoti?.name = "noti"
                    
                    draggingNoti = true
                    let noti = node as! MusicNotes
        //            noti.addMovingPoint(location)  // do not want to use wayPoints for dragging
                  
                    movingNoti = noti
                    // animate noti at pick up
                    let expand = SKAction.scaleBy(1.18, duration: 0.1)
                    let rotR = SKAction.rotateByAngle(0.18, duration: 0.28)
                    let rotL = SKAction.rotateByAngle(-0.18, duration: 0.28)
                    let contract = SKAction.scaleBy(0.85, duration: 0.3)
                    let pickUp = SKAction.sequence([expand, rotR, rotL, contract, rotR, rotL])
                    noti.runAction(pickUp)
                }
        }
    }
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
    
    if (draggingNoti == false ) {
            return
        }
        let touch = touches.first
        let location = touch!.locationInNode(scene!)
        
        if let noti = movingNoti {
              noti.position = location // do not use noti.addMovingPoint(location)
        }
    }

    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        
        if (draggingNoti == false ) {
            return
        } else {
            draggingNoti = false
        }
        
        // check intersaction
        var didScore = false
        
        //if CGRectIntersectsRect(destinationRect(destinationNode.frame), roamingNoti!.scoringRect()) { // how much to relax destinationRect / scoringRect?
        if CGRectIntersectsRect((destinationNode.frame), roamingNoti!.scoringRect()) {
            
            movingNoti?.position.y = destinationNode.position.y
           
            scoringNotiArray.append(movingNoti!)
            
            // add leger for Middle C
            if (destinationNode == L0)   {
                L0leger.alpha = 1
                L0leger.position.x = movingNoti!.position.x + movingNoti!.frame.width * 0.06
                L0leger.position.y = L0.position.y
            } else if (destinationNode == L6)   {
                L6leger.alpha = 1
                L6leger.position.x = movingNoti!.position.x
                L6leger.position.y = L6.position.y
            }
            
            score++  // score has been passed to GameViewController
            scoreLabel.text = "Score : \(score)/\(level.challengesArray.count)"
            didScore = true
 
            celebrate({
                if self.gameSceneDelegate != nil {
                    self.gameSceneDelegate!.notiDidScore(didScore)
                }
            })
            
            animateInstructionLabel() // delay instructionLabel to be in sync with noti appearance

        } else {
            die()
            deadCount++  // deadCount has been passed to GameViewController
            deadCountLabel.text = "\(deadCount)"
            if self.gameSceneDelegate != nil {
                self.gameSceneDelegate!.notiDidScore(didScore)
            }
        }
    }
   
/*    func destinationRect(destination: CGRect) -> CGRect {
        return CGRectMake(destination.origin.x, destination.origin.y + destination.size.height/4, destination.size.width, destination.size.height/2)
    }
*/
    
    func addNoti() {
        let noti = MusicNotes(imageNamed: String())
        noti.name = "noti"
        noti.setScale(S5.yScale * 0.9)
        roamingNoti = noti
        noti.anchorPoint = CGPointMake(0.38, 0.28)  // should this line be here or in MusicNotes?
        noti.zPosition = 3
        noti.position = CGPoint(x: frame.width/2, y: frame.height*0.86)
        addChild(noti)
    }
    
    func followRoamingPath() {
        let path = CGPathCreateMutable()
        CGPathAddArc(path, nil, frame.width/2.0, frame.height*0.5, frame.height*0.36, CGFloat(M_PI_2) , CGFloat(2*M_PI + M_PI_2) , false)
        let followArc = SKAction.followPath(path, asOffset: false, orientToPath: false, duration: 12.0)
        roamingNoti!.runAction(SKAction.repeatActionForever(followArc))
    }

    func updateChallenge(challenge: Challenge) {
        self.instructionLabel.text = challenge.instruction
        self.destinationNode = getSpriteNodeForString(challenge.destination)
        self.sound = challenge.sound
        self.clef = challenge.clef
    }
    
    func updateClef(clef: String) {
        if self.cf != nil {
            self.removeChildrenInArray([self.cf!])
        }
        self.cf = SKSpriteNode(imageNamed: "\(clef).png")
        self.cf!.name  = "\(clef)"
        if (clef == "clefTreble") {
            self.cf!.anchorPoint = CGPointMake(0.5, 0.33)
            self.cf!.position = CGPoint(x: frame.width/5.2, y: frame.height/1.9 - 68*frame.width/580) // y at L2.y
            self.cf!.setScale(frame.width/3880)
            
        } else if (clef == "clefBass") {
            self.cf!.anchorPoint = CGPointMake(0.5, 0.71)
            self.cf!.position = CGPoint(x: frame.width/5.2, y: frame.height/1.9) // y at L4.y
            self.cf!.setScale(frame.width/1880)
        }
        self.insertChild(cf!, atIndex: 0)
        clefRotating = self.cf!
    }
    
    func updateBackground(background: String) {
        let bg = SKSpriteNode(imageNamed: "\(background).png")
        bg.anchorPoint = CGPoint(x: 0, y: 0)
        bg.size = self.frame.size
        bg.zPosition = -1
        insertChild(bg, atIndex: 0)
    }
    
    func getSpriteNodeForString(name : String) -> SKSpriteNode {
        switch name {
                case "L0": return L0
                case "L1": return L1
                case "L2": return L2
                case "L3": return L3
                case "L4": return L4
                case "L5": return L5
                case "S0": return S0
                case "S1": return S1
                case "S2": return S2
                case "S3": return S3
                case "S4": return S4
                case "S5": return S5
                case "L6": fallthrough
                default: return L6
            }
    }
    
    func setupInstructionLabel() {
        instructionLabel.fontColor = SKColor.blackColor()
        instructionLabel.name = "instructionLabel"
        instructionLabel.alpha = 1
        instructionLabel.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame) + frame.height/3)
        if (UIDevice.currentDevice().userInterfaceIdiom == .Pad) {
            instructionLabel.fontSize = 66
        } else if (UIDevice.currentDevice().userInterfaceIdiom == .Phone) {
            instructionLabel.fontSize = 33
        }
        addChild(instructionLabel)
    }
    
    func animateInstructionLabel() {  // so it appears in sync with Noti
        let fadeAction = SKAction.fadeAlphaTo(0, duration: 0.0)
        let waitAction = SKAction.waitForDuration(1.8)
        let fadeInAction = SKAction.fadeAlphaTo(1, duration: 0.5)
        let sequence = SKAction.sequence([fadeAction, waitAction, fadeInAction])
        instructionLabel.runAction(sequence)
    }
    
    func updateTimeLimit(timeLimit: Int) {
        _ = timeLimit
        self.timeLimit = timeLimit
    }
    
    func setupTimerLabel() {
        timerLabel = SKLabelNode(fontNamed: "Komika Display Tight")
        levelTimeLimit = timeLimit
        timerLabel.text = "Timeleft : \(timeLimit!)"
        if (UIDevice.currentDevice().userInterfaceIdiom == .Pad) {
            timerLabel.fontSize = 46
        } else if (UIDevice.currentDevice().userInterfaceIdiom == .Phone) {
            timerLabel.fontSize = 26
        }
        timerLabel.fontColor = SKColor(red: 0.871, green: 0.282, blue: 0.228, alpha: 1.0)
        timerLabel.horizontalAlignmentMode = .Left
        timerLabel.position = CGPoint(x: frame.width*0.023 , y: frame.height*0.82)
        if timeLimit > 0 {  // label for levels 7,8,9 only
            addChild(timerLabel)
        }
    }

     override func update(currentTime: CFTimeInterval) {     // for movingNoti
        dt = currentTime - lastUpdateTime
        lastUpdateTime = currentTime
        enumerateChildNodesWithName("noti", usingBlock: {node, stop in
            let noti = node as! MusicNotes
            noti.move(self.dt)
        })
    }
    
    func addStartMsg() {
        let startMsg = SKLabelNode(fontNamed: "Komika Display")
        startMsg.name = "msgLabel"
        startMsg.text = "Start!"
        startMsg.fontColor = SKColor.blackColor()
        startMsg.position = CGPoint(x: frame.width/2 , y: frame.height/1.38)
        if (UIDevice.currentDevice().userInterfaceIdiom == .Pad) {
            startMsg.fontSize = 88
        } else if (UIDevice.currentDevice().userInterfaceIdiom == .Phone) {
            startMsg.fontSize = 38
        }
        addChild(startMsg)
    }

    func addStaffLines() {
        let w = frame.width/2
        let h = frame.height/1.9
        let d = 68*frame.width/2300
        let yScale = frame.width/2300
        let xScale = frame.width/1680
        L0leger.position = L0.position
        L0leger.alpha = 0
        L0leger.xScale = xScale
        L0leger.yScale = yScale
        self.addChild(L0leger)
        L0.position = CGPoint(x:w , y:h-8*d)
        L0.yScale = yScale
        L0.xScale = xScale
        self.addChild(L0)
        L0.alpha = 0.08  // ledger line for middle C for clefTreble
        S0.position = CGPoint(x:w , y:h-7*d)
        S0.yScale = yScale
        S0.xScale = xScale
        self.addChild(S0)
        L1.position = CGPoint(x:w , y:h-6*d)
        L1.yScale = yScale
        L1.xScale = xScale
        self.addChild(L1)
        S1.position = CGPoint(x:w , y:h-5*d)
        S1.yScale = yScale
        S1.xScale = xScale
        self.addChild(S1)
        L2.position = CGPoint(x:w , y:h-4*d)
        L2.yScale = yScale
        L2.xScale = xScale
        self.addChild(L2)
        S2.position = CGPoint(x:w , y:h-3*d)
        S2.yScale = yScale
        S2.xScale = xScale
        self.addChild(S2)
        L3.position = CGPoint(x:w , y:h-2*d)
        L3.yScale = yScale
        L3.xScale = xScale
        self.addChild(L3)
        S3.position = CGPoint(x:w , y:h-d)
        S3.yScale = yScale
        S3.xScale = xScale
        self.addChild(S3)
        L4.position = CGPoint(x:w , y:h)
        L4.yScale = yScale
        L4.xScale = xScale
        self.addChild(L4)
        S4.position = CGPoint(x:w , y:h+d)
        S4.yScale = yScale
        S4.xScale = xScale
        self.addChild(S4)
        L5.position = CGPoint(x:w, y:h+2*d)
        L5.yScale = yScale
        L5.xScale = xScale
        self.addChild(L5)
        S5.position = CGPoint(x:w , y:h+3*d)
        S5.yScale = yScale
        S5.xScale = xScale
        self.addChild(S5)
        L6.position = CGPoint(x:w , y:h+4*d)
        L6.yScale = yScale
        L6.xScale = xScale
        self.addChild(L6)
        L6.alpha = 0.08  // ledger line for middle C for clefBass
        L6leger.position = L0.position
        L6leger.alpha = 0
        L6leger.xScale = xScale
        L6leger.yScale = yScale
        self.addChild(L6leger)
    }

    func addTrashcanAndTrashcanLid() {
        trashcan.position = CGPoint(x: frame.width - frame.width*0.12 , y: 0)
        trashcan.anchorPoint = CGPointMake(0.5, 0)
        trashcan.setScale(frame.width/900)
        trashcan.zPosition = 10
        self.addChild(trashcan)
        trashcanLid.position = CGPoint(x: frame.width - frame.width*0.095 + trashcanLid.frame.width/10 , y: trashcan.frame.height - trashcan.frame.height/4)
        trashcanLid.setScale(frame.width/900)
        trashcanLid.anchorPoint = CGPointMake(1, 0)
        trashcanLid.zPosition = 10
        addChild(trashcanLid)
    }
    
    func setupCountLabels() {
        scoreLabel.fontColor = SKColor(red: 0.871, green: 0.282, blue: 0.228, alpha: 1.0)
        scoreLabel.text = "Score : 0/\(level.challengesArray.count)"
        scoreLabel.name = "scoreLabel"
        scoreLabel.horizontalAlignmentMode = .Left
        scoreLabel.position = CGPoint(x: frame.width*0.023 , y: frame.height*0.9)
        if (UIDevice.currentDevice().userInterfaceIdiom == .Pad) {
            scoreLabel.fontSize = 46
        } else if (UIDevice.currentDevice().userInterfaceIdiom == .Phone) {
            scoreLabel.fontSize = 26
        }
        addChild(scoreLabel)
        
        deadCountLabel.fontColor = SKColor(red: 0.871, green: 0.282, blue: 0.228, alpha: 1.0)
        deadCountLabel.text = "0"
        deadCountLabel.name = "deadCountLabel"
        deadCountLabel.verticalAlignmentMode = .Center
        deadCountLabel.position = CGPoint(x: frame.width - frame.width*0.12 , y: trashcan.frame.height/2.3)  // at trashcan.position
        deadCountLabel.zPosition = 20
        if (UIDevice.currentDevice().userInterfaceIdiom == .Pad) {
            deadCountLabel.fontSize = 42
        } else if (UIDevice.currentDevice().userInterfaceIdiom == .Phone) {
            deadCountLabel.fontSize = 21
        }
        addChild(deadCountLabel)
    }
    
    func flashGameOver() {
        let gameoverLabel = SKLabelNode(fontNamed: "Komika Display")
        gameoverLabel.position = CGPoint(x: frame.width*0.5 , y: frame.height*0.56)
        gameoverLabel.fontColor = SKColor(red: 0.871, green: 0.282, blue: 0.228, alpha: 1.0)
        gameoverLabel.text = "Game Over"
        gameoverLabel.alpha = 0
        gameoverLabel.zPosition = 10
        if (UIDevice.currentDevice().userInterfaceIdiom == .Pad) {
            gameoverLabel.fontSize = 128
        } else if (UIDevice.currentDevice().userInterfaceIdiom == .Phone) {
            gameoverLabel.fontSize = 68
        }
        // animate label
        let fadeinAction = SKAction.fadeInWithDuration(0.5)
        let fadeoutAction = SKAction.fadeOutWithDuration(0.5)
        gameoverLabel.runAction(SKAction.sequence([fadeinAction, fadeoutAction, fadeinAction, fadeoutAction, fadeinAction]))        
        addChild(gameoverLabel)
}
    
    func celebrate(completionHandler: () -> ()) {
        
        rotateClef(completionHandler)
        playSound(sound)
        
        let texture1 = SKTexture(imageNamed: "particleRedHeart")
        let twinkle1 = SKEmitterNode()
        twinkle1.particleTexture = texture1
        twinkle1.position = roamingNoti!.position
        twinkle1.particlePositionRange = CGVectorMake(180, 180)
        twinkle1.particleBirthRate = 33
        twinkle1.numParticlesToEmit = 68
        twinkle1.particleLifetime = 0.1
        twinkle1.particleSpeed = 10.0
        twinkle1.particleRotation = 0.0
        twinkle1.particleRotationRange = 3.0
        twinkle1.particleScale = 0.5
        twinkle1.particleScaleRange = 0.6
        twinkle1.particleScaleSpeed = 0.5
        self.addChild(twinkle1)
        
        let texture2 = SKTexture(imageNamed: "particleGoldStar")
        let twinkle2 = SKEmitterNode()
        twinkle2.particleTexture = texture2
        twinkle2.position = roamingNoti!.position
        twinkle2.particlePositionRange = CGVectorMake(180, 180)
        twinkle2.particleBirthRate = 33
        twinkle2.numParticlesToEmit = 68
        twinkle2.particleLifetime = 0.1
        twinkle2.particleSpeed = 10.0
        twinkle2.particleRotation = 3.0
        twinkle2.particleRotationRange = 3.0
        twinkle2.particleScale = 0.6
        twinkle2.particleScaleRange = 0.6
        twinkle2.particleScaleSpeed = 0.5
        self.addChild(twinkle2)
        
        let texture3 = SKTexture(imageNamed: "particlePurpleFlower")
        let twinkle3 = SKEmitterNode()
        twinkle3.particleTexture = texture3
        twinkle3.position = roamingNoti!.position
        twinkle3.particlePositionRange = CGVectorMake(180, 180)
        twinkle3.particleBirthRate = 33
        twinkle3.numParticlesToEmit = 68
        twinkle3.particleLifetime = 0.1
        twinkle3.particleSpeed = 10.0
        twinkle3.particleRotation = 3.0
        twinkle3.particleRotationRange = 3.0
        twinkle3.particleScale = 0.4
        twinkle3.particleScaleRange = 0.6
        twinkle3.particleScaleSpeed = 0.5
        self.addChild(twinkle3)
        
        let rotR = SKAction.rotateByAngle(0.28, duration: 0.33)
        let rotL = SKAction.rotateByAngle(-0.28, duration: 0.33)
        let expand = SKAction.scaleBy(1.18, duration: 0.1)
        let contract = SKAction.scaleBy(0.85, duration: 0.3)
        let happy = SKAction.sequence([rotR, rotL, rotR, rotL, expand, contract])
        movingNoti!.runAction(happy)
    }
    
    func rotateClef(completionHandler: () -> ()) {   // closure
        clefRotating.runAction(SKAction.rotateByAngle (CGFloat(2*M_PI), duration: 1.8), completion: completionHandler)
    }
    
    func die() {
        playSound("soundNoGood")
        
        let shrinkAction = SKAction.scaleBy(0.38, duration: 0.8)
        let rotateAction = SKAction.rotateByAngle(CGFloat(M_PI), duration: 0.8)
        let group1Action = SKAction.group([shrinkAction, rotateAction])
        let recycleAction = SKAction.moveTo(CGPoint( x: trashcan.position.x , y: trashcan.position.y + trashcan.frame.height*1.2) , duration: 0.8)
        let fallAction = SKAction.moveToY(30.0, duration: 0.8)
        
        let removeAction = SKAction.removeFromParent()
        roamingNoti!.runAction(SKAction.sequence([group1Action, recycleAction, fallAction, removeAction]))
        
        let openAction = SKAction.rotateByAngle(CGFloat(-M_PI / 2), duration: 0.8)
        let waitAction1 = SKAction.waitForDuration(3.0)
        let closeAction = SKAction.rotateByAngle(CGFloat(M_PI / 2), duration: 1.0)
        trashcanLid.runAction(SKAction.sequence([openAction, waitAction1, closeAction]))
    }    
    
    func playSound(sound: String) {
        runAction(SKAction.playSoundFileNamed("\(sound).wav", waitForCompletion: false))
    }
    
    func startLevel() {
        childNodeWithName("msgLabel")!.hidden = true
        followRoamingPath()
        setupInstructionLabel()
        paused = false
        gameState = .Playing         
        if (gameSceneDelegate != nil) {
            gameSceneDelegate!.levelDidBegin()
            }
        }

}