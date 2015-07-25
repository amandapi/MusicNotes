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
    
    var score : Int = 0
    var deadCount : Int = 0
    
    var startMsg = SKLabelNode()
    var instruction = SKLabelNode()  // retrieve from plist
    var destination = SKSpriteNode()  // retrieve from plist
    var clef = SKSpriteNode()  // retrieve from plist
    var background = SKSpriteNode()  // retrieve from plist
    var gameLevel = Int()  // retrieve from plist
    var gameState = GameState.StartingLevel
    
    // these are the "destinations" defined by "staffLines"
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
    
    // these are the "clefs"
    let clefTreble = SKSpriteNode(imageNamed: "clefTreble")
    let clefBass = SKSpriteNode(imageNamed: "clefBass")
    
    let trashcan = SKSpriteNode(imageNamed: "trashcan")
    let trashcanLid = SKSpriteNode(imageNamed: "trashcanLid")
    
    required init(coder aDecoder: NSCoder) {
        fatalError("NSCoding not supported")
    }
    
    override init(size: CGSize) {
        super.init(size: size)
    }
    
    override func didMoveToView(view: SKView) {
        addBackground()
        addStaffLines()
        addNoti()
        addClef()
        addTrashcanAndTrashcanLid()
        addStartMsg()
        
        if gameState == .StartingLevel {
            paused = true  // would false serves a better purpose?
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
                
                if CGRectIntersectsRect(destinationRect(S3.frame), roamingNoti!.scoringRect()) {
                    draggingNoti = false
                    return         // what does this block do?
                }
                
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
            
            //println("roamingNoti.frame is \(roamingNoti!.frame)")
            //println("scoringRect is \(roamingNoti!.scoringRect())")
            //println("S3.frame is \(S3.frame)")
            //println("destinationRect is \(destinationRect(S3.frame))")

            roamingNoti!.position.y = S3.position.y    // this does not work if addNoti() is effective

            celebrate()
            score++
            showScore()
            println("score is \(score)")
            addNoti()
            followRoamingPath()
            
        } else {
            die()
            showDeadCount()
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
        startMsg.fontSize = 88
        startMsg.position = CGPoint(x: 0 , y: 20)
        startMsg.position = CGPointMake(CGRectGetMidX(self.frame) - 100, CGRectGetMidY(self.frame) + 200)
        //startMsg.zPosition = 100
        addChild(startMsg)
    }
    
    func addInstruction() {
        var instruction = SKLabelNode(fontNamed: "Verdana-Bold")
        instruction.text = "C in a Space" // how to feed value from plist?
        instruction.fontSize = 63
        instruction.fontColor = UIColor.blackColor()
        instruction.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame) + 180)
        self.addChild(instruction)
        
        let fadeinAction = SKAction.fadeInWithDuration(0.5)
        let fadeoutAction = SKAction.fadeOutWithDuration(0.5)
        instruction.runAction(SKAction.sequence([fadeinAction, fadeoutAction, fadeinAction, fadeoutAction, fadeinAction]))    
    }
    
    func addBackground() {
        let bg = SKSpriteNode(imageNamed: "bg8")
        // bg raw size is 2048x1536
        bg.anchorPoint = CGPoint(x: 0, y: 0)
        bg.size = self.frame.size
        bg.zPosition = -1
        addChild(bg)
    }
    
    func addStaffLines() {
        S0.position = CGPoint(x: frame.width/2 , y: frame.height/2 - 7*68*frame.width/1680)
        S0.setScale(frame.width/1680)
        self.addChild(S0)
        L1.position = CGPoint(x: frame.width/2 , y: frame.height/2 - 6*68*frame.width/1680)
        L1.setScale(frame.width/1680)
        self.addChild(L1)
        S1.position = CGPoint(x: frame.width/2 , y: frame.height/2 - 5*68*frame.width/1680)
        S1.setScale(frame.width/1680)
        self.addChild(S1)
        L2.position = CGPoint(x: frame.width/2 , y: frame.height/2 - 4*68*frame.width/1680)
        L2.setScale(frame.width/1680)
        self.addChild(L2)
        S2.position = CGPoint(x: frame.width/2 , y: frame.height/2 - 3*68*frame.width/1680)
        S2.setScale(frame.width/1680)
        self.addChild(S2)
        L3.position = CGPoint(x: frame.width/2 , y: frame.height/2 - 2*68*frame.width/1680)
        L3.setScale(frame.width/1680)
        self.addChild(L3)
        S3.position = CGPoint(x: frame.size.width/2 , y: frame.size.height/2 - 68*frame.size.width/1680)
        S3.setScale(frame.size.width/1680)
        //S3.anchorPoint = CGPointMake(0.5, 0.5)
        self.addChild(S3)
        L4.position = CGPoint(x: frame.width/2 , y: frame.height/2)
        L4.setScale(frame.width/1680)
        self.addChild(L4)
        S4.position = CGPoint(x: frame.width/2 , y: frame.height/2 + 68*frame.width/1680)
        S4.setScale(frame.width/1680)
        self.addChild(S4)
        L5.position = CGPoint(x: frame.width/2, y: frame.height/2 + 2*68*frame.width/1680)
        L5.setScale(frame.width/1680)
        self.addChild(L5)
        S5.position = CGPoint(x: frame.width/2 , y: frame.height/2 + 3*68*frame.width/1680)
        S5.setScale(frame.width/1680)
        self.addChild(S5)
        //println("S5 y.Scale is \(S5.yScale)")
    }

    func addNoti() {
        //var noti = MusicNotes(imageNamed: "notiPinkU")
        var noti = MusicNotes(imageNamed: String())
        noti.setScale(0.5)
        roamingNoti = noti
        noti.name = "noti"
        println("noti is \(noti)")  // note this does specify exactly which noti is roaming
        noti.anchorPoint = CGPointMake(0.38, 0.25)  // should this line be here or in MusicNotes?
        noti.zPosition = 3
        noti.position = CGPoint(x: frame.width*3/5, y: frame.height*4/5)
        addChild(noti)
        //followRoamingPath()
    }
    
    func followRoamingPath() {
        var path = CGPathCreateMutable()
        //CGPathMoveToPoint(path, nil, 560, 360)  // (path, nil, x, y)
        CGPathAddArc(path!, nil, 560, 360, 280, CGFloat(M_PI_2) , CGFloat(2*M_PI + M_PI_2) , false)
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
        
        clefTreble.anchorPoint = CGPointMake(0.5, 0.33)
        clefTreble.position = CGPoint(x: L2.position.x - frame.width/3.5, y: L2.position.y)
        clefTreble.setScale(L2.size.height / 118)
        self.addChild(clefTreble)
        
        clefBass.anchorPoint = CGPointMake(0.5, 0.71)
        clefBass.position = CGPoint(x: L4.position.x + frame.width/3.6, y: L4.position.y)
        clefBass.setScale(L4.size.height / 56)
        self.addChild(clefBass)
    }
    
    func addTrashcanAndTrashcanLid() {
        trashcan.position = CGPoint(x: frame.width - frame.width*0.12 , y: trashcan.frame.height/1.68)
        trashcan.setScale(frame.width/900)
        self.addChild(trashcan)
        trashcanLid.position = CGPoint(x: frame.width - frame.width*0.095 + trashcanLid.frame.width/8 , y: trashcan.frame.height - trashcan.frame.height/4)
        trashcanLid.setScale(frame.width/900)
        trashcanLid.anchorPoint = CGPointMake(1, 0)
        addChild(trashcanLid)
    }
    
    func showScore() {
        var scoreLabel = UILabel(frame: CGRectMake(frame.width/6 , frame.height/10, 300, 60))
        
        scoreLabel.center = CGPoint(x: frame.width/6 , y: frame.height/10)
        scoreLabel.textAlignment = NSTextAlignment.Center
        scoreLabel.text = "Score: \(score)"
        scoreLabel.font = UIFont(name: "Verdana-Bold", size: 24.0) // Courier-Bold
        scoreLabel.textColor = UIColor.redColor()
        //scoreLabel.shadowColor = UIColor.blackColor()
        //scoreLabel.shadowOffset = CGSize(width: -5.0, height: -5.0)
        //scoreLabel.clearsContextBeforeDrawing = true
        //scoreLabel.setNeedsDisplay()
        self.view?.addSubview(scoreLabel)
    }
    
    func showDeadCount() {
        var deadCountLabel = UILabel(frame: trashcan.frame)
        deadCountLabel.center = CGPoint(x: frame.width - frame.width*0.12 , y: 725)
        deadCountLabel.textAlignment = NSTextAlignment.Center
        deadCountLabel.text = "\(deadCount)"
        deadCountLabel.font = UIFont(name: "Verdana-Bold", size: 58.0) // Courier-Bold
        deadCountLabel.textColor = UIColor.redColor()
        //deadCountLabel.shadowColor = UIColor.blackColor()
        //deadCountLabel.shadowOffset = CGSize(width: -5.0, height: -5.0)
        //deadCountLabel.clearsContextBeforeDrawing = true
        //deadCountLabel.setNeedsDisplay()
        self.view?.addSubview(deadCountLabel)
    }
    
    func flashGameOver() { // when deadCount = 3
        let gameoverLabel = SKLabelNode(fontNamed: "MarkerFelt-Wide")
        gameoverLabel.fontSize = 138
        gameoverLabel.position = CGPoint(x: frame.width/2 , y: frame.height/2)
        gameoverLabel.fontColor = SKColor.redColor()
        gameoverLabel.text = "Game Over"
        gameoverLabel.zPosition = 4
        gameoverLabel.alpha = 0

        let fadeinAction = SKAction.fadeInWithDuration(0.5)
        let fadeoutAction = SKAction.fadeOutWithDuration(0.5)
        let deleteAction = SKAction.removeFromParent()
        gameoverLabel.runAction(SKAction.sequence([fadeinAction, fadeoutAction, fadeinAction, fadeoutAction, fadeinAction, fadeoutAction, deleteAction]))
        
        if (deadCount == 3) {
            addChild(gameoverLabel)
            // how to stop new note appearing and segue back to LevelViewController
        } else {
            return
        }
    }
    
    func celebrate() {
        clefTreble.runAction(SKAction.rotateByAngle (CGFloat(2*M_PI), duration: 1.8))
        clefBass.runAction(SKAction.rotateByAngle (CGFloat(2*M_PI), duration: 1.8))
        
        var soundC5 = SKAction.playSoundFileNamed("soundC5.wav", waitForCompletion: false)
        self.runAction(soundC5)
        
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
    
    func die() {
        let shrinkAction = SKAction.scaleBy(0.25, duration: 1.0)
        let rotateAction = SKAction.rotateByAngle(CGFloat(3*M_PI), duration: 1.0)
        let recycleAction = SKAction.moveTo(CGPoint( x: trashcan.position.x , y: trashcan.position.y + trashcan.frame.height*2) , duration: 1.0)
        let fallAction = SKAction.moveToY(30.0, duration: 1.0)
        let removeAction = SKAction.removeFromParent()
        roamingNoti!.runAction(SKAction.sequence([shrinkAction, rotateAction, recycleAction, fallAction, removeAction]))
        
        let openAction = SKAction.rotateByAngle(CGFloat(-M_PI / 2), duration: 1.0)
        let waitAction1 = SKAction.waitForDuration(3.0)
        let closeAction = SKAction.rotateByAngle(CGFloat(M_PI / 2), duration: 1.0)
        trashcanLid.runAction(SKAction.sequence([openAction, waitAction1, closeAction]))
        deadCount++
        println("deadCount is \(deadCount)")
    }

}