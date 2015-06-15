//
//  GameScene.swift
//  MusicNotes
//
//  Created by Amanda Pi on 2015-05-31.
//  Copyright (c) 2015 Amanda. All rights reserved.
//

import SpriteKit

class GameScene: SKScene {
    
    var roamingNoti: MusicNotes?  // replace SKSpriteNode with new subclass MusicNotes
    var draggingNoti: Bool = false
    var movingNoti: MusicNotes?
    
    var lastUpdateTime: NSTimeInterval = 0.0  // for drawLines
    var dt: NSTimeInterval = 0.0  // for drawLines
    
    var score : Int = 0 // to count score
    var deadCount : Int = 0  // to count dead notes
    
    // load dictionary and afilliated items
    //var instruction: String = "C in a Space"  // no hard coding please
    //var destination: String = "S3"
    //var clef: String = "treble"
    var instruction = SKLabelNode()
    var destination = SKSpriteNode()
    var clef = SKSpriteNode()
    //var stepInLevel: Int = 1  // for retrieving info in plist
    
//    let levels : NSDictionary? = NSDictionary(contentsOfFile: NSBundle.mainBundle().pathForResource("Level", ofType: "plist")!)
    
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
    
    let clefTreble = SKSpriteNode(imageNamed: "clefTreble")
    let clefBass = SKSpriteNode(imageNamed: "clefBass")
    
    let trashcan = SKSpriteNode(imageNamed: "trashcan")
    let trashcanLid = SKSpriteNode(imageNamed: "trashcanLid")
    
    override init(size: CGSize) {
        super.init(size: size)
        
        roamingNoti?.name = "noti"
        addBackground()
        addStaffLines()
        addNoti()
        followRoamingPath()
        addTrebleClef()
        //addBassClef()
        addTrashcanAndTrashcanLid()
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        roamingNoti!.removeAllActions()
        
        if CGRectIntersectsRect(S3.frame, self.roamingNoti!.frame) {
            draggingNoti = false
            return
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
    
    override func touchesEnded(touches: Set<NSObject>, withEvent event: UIEvent) {
        
        if (draggingNoti == false ) {
            return
        } else {
            draggingNoti = false
        }
        
        // check collision
 
        if CGRectIntersectsRect(S3.frame, self.roamingNoti!.frame) {
        
            //if CGRectIntersectsRect(S3.frame, UIEdgeInsetsInsetRect(self.roamingNoti!.frame, UIEdgeInsetsMake(84, -10, 20, -10))) {
            //if CGRectIntersectsRect(S3.frame, UIEdgeInsetsInsetRect(self.roamingNoti!.frame, UIEdgeInsetsMake(self.roamingNoti!.frame.height*5/8, 0, self.roamingNoti!.frame.height/8, 0))) {
            //println("S3.frame is \(S3.frame)")
            //println("S3.position.y is \(S3.position.y)")
            //println("roamingNoti.frame is \(roamingNoti!.frame)")
            //println("tighter roamingNoti.frame is \(UIEdgeInsetsInsetRect(self.roamingNoti!.frame, UIEdgeInsetsMake(self.roamingNoti!.frame.height*5/8, 0, self.roamingNoti!.frame.height/8, 0)))")
            //println("roamingNoti.position is \(roamingNoti!.position)")
            //roamingNoti.position.y = S3.position.y - (S3.frame.size.height/2)
            
            roamingNoti!.position.y = S3.position.y
            
            // clef rotates
            clefTreble.runAction(SKAction.rotateByAngle (CGFloat(2*M_PI), duration: 1.0))
            //clefBass.runAction(SKAction.rotateByAngle (CGFloat(2*M_PI), duration: 1.0))
            //let waitAction = SKAction.waitForDuration(3.0)
            changeInstructionAndPositionAndClef()
           
            // count score
            score++
            showScore()
            println("score is \(score)")
            addNoti()
            
        } else {
            dies()
            showDeadCount()
            flashGameOver()
            //let diesAction = SKAction(dies())
            //let waitAction2 = SKAction.waitForDuration(6.0)
            //let addNotiAction = SKAction(addNoti())
            addNoti()
        }
    }
    
    override func update(currentTime: CFTimeInterval) {
        dt = currentTime - lastUpdateTime
        lastUpdateTime = currentTime
        enumerateChildNodesWithName("noti", usingBlock: {node, stop in
            let noti = node as! MusicNotes
            noti.move(self.dt)
        })
        drawLines()
    }
    
    func dies() {
        let shrinkAction = SKAction.scaleBy(0.25, duration: 1.0)
        let rotateAction = SKAction.rotateByAngle(CGFloat(M_PI), duration: 1.0)
        let recycleAction = SKAction.moveTo(CGPoint( x: trashcan.position.x , y: trashcan.position.y + trashcan.frame.height*2) , duration: 1.0)
        let fallAction = SKAction.moveToY(30.0, duration: 1.0)
        let removeAction = SKAction.removeFromParent()
        roamingNoti!.runAction(SKAction.sequence([shrinkAction, rotateAction, recycleAction, fallAction, removeAction]))
        
        let openAction = SKAction.rotateByAngle(CGFloat(-M_PI / 2), duration: 1.0)
        let waitAction1 = SKAction.waitForDuration(3.0)
        let closeAction = SKAction.rotateByAngle(CGFloat(M_PI / 2), duration: 1.0)
        trashcanLid.runAction(SKAction.sequence([openAction, waitAction1, closeAction]))
        // count how many is dead
        deadCount++
        println("deadCount is \(deadCount)")
    }

    
    func changeInstructionAndPositionAndClef() {
       
        let path = NSBundle.mainBundle().pathForResource("Level", ofType: "plist")!
        let myDictionary = NSDictionary(contentsOfFile: path)
        //println("myDictionary: \(myDictionary)")  // this works
        //println(myDictionary!["Level1"])          // this works
        //println(myDictionary!["Level2"])          // this works
        //println(myDictionary?.valueForKeyPath("Level2.step1"))  // this works
        //println(myDictionary?.valueForKeyPath("Level2.step1.destination"))  // this returns "Optional(L5)
        println(myDictionary?.valueForKeyPath("Level2.step1.instruction"))  // this returns "Optional(A on a Line)
        //println(myDictionary?.valueForKeyPath("Level2.clef"))  // this returns "Optional(bass)"
    }

    
    func addBackground() {
        let bg = SKSpriteNode(imageNamed: "background1")
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
        S3.position = CGPoint(x: frame.width/2 , y: frame.height/2 - 68*frame.width/1680)
        S3.setScale(frame.width/1680)
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
        var noti = MusicNotes(imageNamed: "notiPinkU")  // replace SKSpriteNode with new subclass MusicNotes
        
        //var noti = MusicNotes(imageNamed: String())

        noti.setScale(0.5)
        roamingNoti = noti
        noti.name = "noti"
        println("noti is \(noti)")  // note this does give the color
        noti.anchorPoint = CGPointMake(0.38, 0.25)

        noti.physicsBody = SKPhysicsBody(rectangleOfSize: CGSize(width: noti.frame.size.width, height: noti.frame.size.height/4))
        //println("noti.frame.size is \(noti.frame.size)")
        noti.physicsBody?.dynamic = false
        //noti.position = CGPoint(x: size.width / 2, y: size.height / 2)
        noti.zPosition = 3
        addChild(noti)
        followRoamingPath()
    }
    
    func followRoamingPath() {
        let pathCenter = CGPoint(x: frame.width/6 , y: frame.height/6)
        let pathDiameter = CGFloat(frame.height/2)
        let path = CGPathCreateWithEllipseInRect(CGRect(origin: pathCenter, size: CGSize(width: pathDiameter * 2.0, height: pathDiameter * 1.2)), nil)
        let followPath = SKAction.followPath(path, asOffset: false, orientToPath: false, duration: 12.0)
        roamingNoti!.runAction(SKAction.repeatActionForever(followPath))
    }
    
    func addTrebleClef() {
        clefTreble.anchorPoint = CGPointMake(0.5, 0.33)
        //clefTreble.position = L2.position
        clefTreble.position = CGPoint(x: L2.position.x - frame.width/3.5, y: L2.position.y)
        //println("L2.size.height is \(L2.size.height)" )
        clefTreble.setScale(L2.size.height / 118)
        self.addChild(clefTreble)
    }
    
    func addBassClef() {
        clefBass.anchorPoint = CGPointMake(0.5, 0.71)
        clefBass.position = CGPoint(x: L4.position.x + frame.width/8, y: L4.position.y)
        clefBass.setScale(L4.size.height / 56)
        self.addChild(clefBass)
    }
    
    func addTrashcanAndTrashcanLid() {
        trashcan.position = CGPoint(x: frame.width - frame.width*0.12 , y: trashcan.frame.height/1.68)
        trashcan.setScale(frame.width/900)
        //trashcan.zPosition = 2
        self.addChild(trashcan)
        trashcanLid.position = CGPoint(x: frame.width - frame.width*0.095 + trashcanLid.frame.width/8 , y: trashcan.frame.height - trashcan.frame.height/4)
        trashcanLid.setScale(frame.width/900)
        trashcanLid.anchorPoint = CGPointMake(1, 0)
        addChild(trashcanLid)
    }
    
    func showScore() {
        var scoreLabel = UILabel(frame: CGRectMake(frame.width/8 , frame.height/8, 300, 60))
        scoreLabel.center = CGPoint(x: frame.width/8 , y: frame.height/8)
        scoreLabel.textAlignment = NSTextAlignment.Center
        scoreLabel.text = "Score: \(score)"
        scoreLabel.font = UIFont(name: "Verdana-Bold", size: 58.0) // Courier-Bold
        scoreLabel.textColor = UIColor.redColor()
        scoreLabel.shadowColor = UIColor.blackColor()
        scoreLabel.shadowOffset = CGSize(width: -5.0, height: -5.0)
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
        deadCountLabel.shadowColor = UIColor.blackColor()
        deadCountLabel.shadowOffset = CGSize(width: -5.0, height: -5.0)
        //deadCountLabel.clearsContextBeforeDrawing = true
        //deadCountLabel.setNeedsDisplay()
        self.view?.addSubview(deadCountLabel)
    }
    
    func flashGameOver() { // when deadCount = 3
        let gameoverLabel = SKLabelNode(fontNamed: "MarkerFelt-Wide")
        gameoverLabel.fontSize = 88
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
            addChild(gameoverLabel) // and also segue back to LevelViewController
        } else {
            return
        }
    }
    
    func drawLines() {
        enumerateChildNodesWithName("line", usingBlock: {node, stop in
            node.removeFromParent()  // redraw path every frame
        })
        enumerateChildNodesWithName("noti", usingBlock: {node, stop in
            // for each noti, try to get a new path
            let noti = node as! MusicNotes
            if let path = noti.createPathToMove() {
                let shapeNode = SKShapeNode()  // assign the path to its path property
                shapeNode.path = path
                shapeNode.name = "line"
                shapeNode.strokeColor = UIColor.yellowColor()
                shapeNode.lineWidth = 1
                shapeNode.glowWidth = 18
                shapeNode.lineCap = kCGLineCapRound
                shapeNode.zPosition = 2
                shapeNode.alpha = 0.3
                self.addChild(shapeNode)
            }
        })
    }
}

