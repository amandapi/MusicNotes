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

class GameScene: SKScene {
    
    var noti = MusicNotes(imageNamed: String())
    var roamingNoti: MusicNotes?
    var draggingNoti: Bool = false
    var movingNoti: MusicNotes?
    
    var lastUpdateTime: NSTimeInterval = 0.0
    var dt: NSTimeInterval = 0.0
    
    var scoreLabel = SKLabelNode(fontNamed: "Verdana-Bold")
    var score = 0
    var deadCountLabel = SKLabelNode(fontNamed: "Verdana-Bold")
    var deadCount = 0
    //var startMsg = SKLabelNode(fontNamed: "Verdana-Bold")
    var startMsg = SKLabelNode()
    
    var instruction = SKLabelNode()  // retrieve from plist
    var destination = SKSpriteNode()  // retrieve from plist
    var background = SKSpriteNode()
    
    // these are the "clefs"
    var clefTreble = SKSpriteNode()
    var clefBass = SKSpriteNode()
    var clef = SKSpriteNode()
    var clefRotating = SKSpriteNode()
    
    var gameState = GameState.StartingLevel
    
    // these are the "destinations" defined by sizes of "staffLines"
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
    
    let trashcan = SKSpriteNode(imageNamed: "trashcan")
    let trashcanLid = SKSpriteNode(imageNamed: "trashcanLid")
    
    required init(coder aDecoder: NSCoder) {
        fatalError("NSCoding not supported")
    }
    
    override init(size: CGSize) {
        super.init(size: size)
    }
    
// This block will be called by GameViewController's scene.setLevel(level) before skView.presentScene
    var level: Level!
    func setLevel(level: Level) {
        self.level = level
        //println("check2 is \(level)") // returns MusicNotes.Level
        //println("check3 is \(level.background)") // correct
        //println("check4 is \(level.clef)")  // correct
    }
    
    override func didMoveToView(view: SKView) {
        addBackground()
        addStaffLines()
        addNoti()
        addClef()
        addTrashcanAndTrashcanLid()
        addStartMsg()
        setupCountLabels()
        
        if gameState == .StartingLevel {
            paused = true  // would false serves a better purpose? and get rid of gameStates?
        }
    }
    
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        
        switch gameState {
            
            case .StartingLevel:
                childNodeWithName("msgLabel")!.hidden = true
                followRoamingPath()
                addInstruction()
                paused = false
                gameState = .Playing
        
            //fallthrough
            
            case .Playing:
                roamingNoti!.removeAllActions()
                roamingNoti?.name = "noti"
/*
                if CGRectIntersectsRect(destinationRect(S3.frame), roamingNoti!.scoringRect()) {
                    draggingNoti = false
                    return         // what does this block do?
                }
*/
                
                let touch = touches.first as? UITouch
                let location = touch!.locationInNode(self)
                let node = nodeAtPoint(location)
                if node.name == "noti" {
                    draggingNoti = true
                    let noti = node as! MusicNotes
                    noti.addMovingPoint(location)
                    movingNoti = noti
            }
        }
    }

    override func touchesMoved(touches: Set<NSObject>, withEvent event: UIEvent) {
        
        if (draggingNoti == false ) {
            return
        }
        
        let touch = touches.first as? UITouch
        let location = touch!.locationInNode(scene)
        if let noti = movingNoti {
        noti.addMovingPoint(location)
        }
    }
    
    func destinationRect(destination: CGRect) -> CGRect {
        return CGRectMake(destination.origin.x, destination.origin.y + destination.size.height/3, destination.size.width, destination.size.height/3)
    }

    override func touchesEnded(touches: Set<NSObject>, withEvent event: UIEvent) {
        
        if (draggingNoti == false ) {
            return
        } else {
            draggingNoti = false
        }
        
        // check collision
 
        if CGRectIntersectsRect(destinationRect(S3.frame), roamingNoti!.scoringRect()) {

            roamingNoti!.position.y = S3.position.y // this does not work if addNoti() is effective

            celebrate()
            score++
            scoreLabel.text = "Score: \(score)"
            addNoti()
            followRoamingPath()
            
        } else {
            die()
            deadCount++
            deadCountLabel.text = "\(deadCount)"
            flashGameOver()
            addNoti()
            followRoamingPath()
        }
    }

    override func update(currentTime: CFTimeInterval) {
        dt = currentTime - lastUpdateTime
        lastUpdateTime = currentTime
        enumerateChildNodesWithName("noti", usingBlock: {node, stop in
            let noti = node as! MusicNotes
            noti.move(self.dt)
        })
    }

    func addStartMsg() {
        let startMsg = SKLabelNode(fontNamed: "Verdana-Bold")
        startMsg.name = "msgLabel"
        startMsg.text = "Start!"
        startMsg.fontColor = SKColor.greenColor()
        startMsg.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame) + frame.height/8)
        if (UIDevice.currentDevice().userInterfaceIdiom == .Pad) {
            startMsg.fontSize = 88
        } else if (UIDevice.currentDevice().userInterfaceIdiom == .Phone) {
            startMsg.fontSize = 44
        }
        addChild(startMsg)
    }
    
    func addInstruction() {
        var instruction = SKLabelNode(fontNamed: "Verdana-Bold")
        instruction.text = "C in a Space" // how to feed value from plist?
        instruction.fontColor = UIColor.blackColor()
        instruction.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame) + frame.height/5)
        if (UIDevice.currentDevice().userInterfaceIdiom == .Pad) {
            instruction.fontSize = 66
        } else if (UIDevice.currentDevice().userInterfaceIdiom == .Phone) {
            instruction.fontSize = 33
        }
        self.addChild(instruction)

        let fadeinAction = SKAction.fadeInWithDuration(0.2)
        let fadeoutAction = SKAction.fadeOutWithDuration(0.2)
        instruction.runAction(SKAction.sequence([fadeinAction, fadeoutAction, fadeinAction, fadeoutAction, fadeinAction]))
    }

    func addBackground() {

//        var bg = SKSpriteNode(imageNamed: "bg9") // bg raw size is 2048x1536
        var bgName = level?.background!
        var bg = SKSpriteNode(imageNamed: "\(bgName!)")
        bg.anchorPoint = CGPoint(x: 0, y: 0)
        bg.size = self.frame.size
        bg.zPosition = -1
        addChild(bg)
        }
    
    func addStaffLines() {
        var w = frame.width/2
        var h = frame.height/2
        var d = 68*frame.width/2300
        var yScale = frame.width/2300
        var xScale = frame.width/1680
        
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
    }

    func addNoti() {
        //var noti = MusicNotes(imageNamed: "notiPinkU")
        var noti = MusicNotes(imageNamed: String())
        noti.setScale(S5.yScale * 0.8)
        roamingNoti = noti
        noti.name = "noti"
        println("noti is \(noti)")  // note this does specify exactly which noti is roaming
        noti.anchorPoint = CGPointMake(0.38, 0.25)  // should this line be here or in MusicNotes?
        noti.zPosition = 3
        noti.position = CGPoint(x: frame.width/2, y: frame.height*0.76)
        addChild(noti)
        //followRoamingPath()
    }
    
    func followRoamingPath() {
        var path = CGPathCreateMutable()
        //CGPathMoveToPoint(path, nil, 560, 360)  // (path, nil, x, y)
        //CGPathAddArc(path!, nil, 560, 360, 280, CGFloat(M_PI_2) , CGFloat(2*M_PI + M_PI_2) , false)
        CGPathAddArc(path!, nil, frame.width/2.0, frame.height*0.4, frame.height*0.36, CGFloat(M_PI_2) , CGFloat(2*M_PI + M_PI_2) , false)
        // CGPathAddArc(path, nil, x, y, r, startø , endø, clockwise?)
        var followArc = SKAction.followPath(path, asOffset: false, orientToPath: false, duration: 12.0)
        roamingNoti!.runAction(SKAction.repeatActionForever(followArc))
        //noti.runAction(SKAction.repeatActionForever(followArc))
/*
        let pathCenter = CGPoint(x: frame.width/6 , y: frame.height/6)
        let pathDiameter = CGFloat(frame.height/2)
        let path = CGPathCreateWithEllipseInRect(CGRect(origin: pathCenter, size: CGSize(width: pathDiameter * 2.0, height: pathDiameter * 1.2)), nil)
        let followPath = SKAction.followPath(path, asOffset: false, orientToPath: false, duration: 12.0)
        roamingNoti!.runAction(SKAction.repeatActionForever(followPath))
        println("didCallFollowRoamingPath")
*/
    }

    func addClef() {
        //let clefTreble = SKSpriteNode()
        //let clefBass = SKSpriteNode()
        var clef = SKSpriteNode(imageNamed: "\(level.clef!).png")
        //println("level.clef! is \(level.clef!)") //correct: clefBass or clefTreble
        if level.clef! == "clefTreble" {
            clef.anchorPoint = CGPointMake(0.5, 0.33)
            clef.position = CGPoint(x: L2.position.x - frame.width/3.5, y: L2.position.y)
            clef.setScale(L2.size.height / 118)
            clef.name = "clefTreble"
            self.addChild(clef)
            clefRotating = clef
        } else if level.clef! == "clefBass" {
            clef.anchorPoint = CGPointMake(0.5, 0.71)
            clef.position = CGPoint(x: L2.position.x - frame.width/3.5, y: L4.position.y)
            clef.setScale(L4.size.height / 56)
            clef.name = "clefBass"
            self.addChild(clef)
            clefRotating = clef
        }
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
        
        scoreLabel.fontColor = SKColor.redColor()
        scoreLabel.text = "Score: 0"
        scoreLabel.name = "scoreLabel"
        scoreLabel.verticalAlignmentMode = .Center
        scoreLabel.position = CGPoint(x: frame.width/8 , y: frame.height*9/10)
        if (UIDevice.currentDevice().userInterfaceIdiom == .Pad) {
            scoreLabel.fontSize = 48
        } else if (UIDevice.currentDevice().userInterfaceIdiom == .Phone) {
            scoreLabel.fontSize = 23
        }
        addChild(scoreLabel)
        
        deadCountLabel.fontColor = SKColor.redColor()
        deadCountLabel.text = "0"
        deadCountLabel.name = "deadCountLabel"
        deadCountLabel.verticalAlignmentMode = .Center
        //deadCountLabel.position = trashcan.position
        deadCountLabel.position = CGPoint(x: frame.width - frame.width*0.12 , y: trashcan.frame.height/2.3)
        deadCountLabel.zPosition = 20
        if (UIDevice.currentDevice().userInterfaceIdiom == .Pad) {
            deadCountLabel.fontSize = 48
        } else if (UIDevice.currentDevice().userInterfaceIdiom == .Phone) {
            deadCountLabel.fontSize = 23
        }
        addChild(deadCountLabel)
    }
    
    func flashGameOver() { // when deadCount = 3
        let gameoverLabel = SKLabelNode(fontNamed: "Verdana-Bold")
        gameoverLabel.position = CGPoint(x: frame.width/2 , y: frame.height/2)
        gameoverLabel.fontColor = SKColor.redColor()
        gameoverLabel.text = "Game Over"
        gameoverLabel.zPosition = 4
        gameoverLabel.alpha = 0
        //gameoverLabel.fontSize = 138
        if (UIDevice.currentDevice().userInterfaceIdiom == .Pad) {
            deadCountLabel.fontSize = 138
        } else if (UIDevice.currentDevice().userInterfaceIdiom == .Phone) {
            deadCountLabel.fontSize = 68
        }

        let fadeinAction = SKAction.fadeInWithDuration(0.5)
        let fadeoutAction = SKAction.fadeOutWithDuration(0.5)
        let deleteAction = SKAction.removeFromParent()
        gameoverLabel.runAction(SKAction.sequence([fadeinAction, fadeoutAction, fadeinAction, fadeoutAction, fadeinAction, fadeoutAction, deleteAction]))
        
        if (deadCount == 3) {
            addChild(gameoverLabel)
            // reset level, score, deadcount, segue back to LevelViewController
        } else {
            return
        }
    }
    
    func celebrate() {
        rotateClef()
        playSound("soundC5.wav")
        
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
    }
    
    func rotateClef() {
        //let clef = clefRotating
        clefRotating.runAction(SKAction.rotateByAngle (CGFloat(2*M_PI), duration: 1.8))
    }
    
    func playSound(sound:String) { // method for GameViewController to play any sound file on demand
        runAction(SKAction.playSoundFileNamed(sound, waitForCompletion: false))
    }
    
    func die() {
        let shrinkAction = SKAction.scaleBy(0.38, duration: 1.0)
        let rotateAction = SKAction.rotateByAngle(CGFloat(3*M_PI), duration: 1.0)
        let recycleAction = SKAction.moveTo(CGPoint( x: trashcan.position.x , y: trashcan.position.y + trashcan.frame.height*2) , duration: 1.0)
        let fallAction = SKAction.moveToY(30.0, duration: 1.0)
        let removeAction = SKAction.removeFromParent()
        roamingNoti!.runAction(SKAction.sequence([shrinkAction, rotateAction, recycleAction, fallAction, removeAction]))
        
        let openAction = SKAction.rotateByAngle(CGFloat(-M_PI / 2), duration: 1.0)
        let waitAction1 = SKAction.waitForDuration(3.0)
        let closeAction = SKAction.rotateByAngle(CGFloat(M_PI / 2), duration: 1.0)
        trashcanLid.runAction(SKAction.sequence([openAction, waitAction1, closeAction]))
    }

}