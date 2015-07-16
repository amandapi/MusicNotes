//
//  GameScene.swift
//  MusicNotes
//
//  Created by Amanda Pi on 2015-05-31.
//  Copyright (c) 2015 Amanda. All rights reserved.
//

import SpriteKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var noti = MusicNotes(imageNamed: String())
    var roamingNoti: MusicNotes?
    var draggingNoti: Bool = false
    var movingNoti: MusicNotes?
    
    var lastUpdateTime: NSTimeInterval = 0.0
    var dt: NSTimeInterval = 0.0 
    
    var score : Int = 0
    var deadCount : Int = 0
    
    var instruction = SKLabelNode()  // retrieve from plist
    var destination = SKSpriteNode()  // retrieve from plist
    var clef = SKSpriteNode()  // retrieve from plist
    var background = SKSpriteNode()  // retrieve from plist
    var gameLevel = Int()  // retrieve from plist
    
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
    
    // here is the path to Level.plist
    let path = NSBundle.mainBundle().pathForResource("Level", ofType: "plist")!
    
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
        addInstruction()
    }
    
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {

        roamingNoti!.removeAllActions()
        roamingNoti?.name = "noti"
        
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
            
            println("roamingNoti.frame is \(roamingNoti!.frame)")
            println("scoringRect is \(roamingNoti!.scoringRect())")
            println("S3.frame is \(S3.frame)")
            println("destinationRect is \(destinationRect(S3.frame))")

            roamingNoti!.position.y = S3.position.y    // this does not work if addNoti() is effective
            
            // clef rotates
            clefTreble.runAction(SKAction.rotateByAngle (CGFloat(2*M_PI), duration: 1.0))
            clefBass.runAction(SKAction.rotateByAngle (CGFloat(2*M_PI), duration: 1.0))
           
            // count score
            score++
            showScore()
            println("score is \(score)")
            addNoti()
            
        } else {
            dies()
            showDeadCount()
            flashGameOver()
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
    }
    
    func dies() {
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
        // count how many is dead
        deadCount++
        println("deadCount is \(deadCount)")
    }
    
    func addInstruction() {
        
        // generate text for instruction        
        var instruction = SKLabelNode(fontNamed: "Verdana-Bold")
        instruction.text = "C in a Space" // how to feed value from plist?
        instruction.fontSize = 58
        instruction.fontColor = UIColor.redColor()
        instruction.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame) + 230)
        self.addChild(instruction)
    }

    
 /*   func retrieveValuesFromLevel.plist() {
       
        let path = NSBundle.mainBundle().pathForResource("Level", ofType: "plist")!
        let myDictionary = NSDictionary(contentsOfFile: path)
        println("myDictionary: \(myDictionary)")  // this prints "Optional({ levels = ({ background = bg1 ..." the whole dictionary

        var arrayOfLevels = myDictionary!.allKeys as! [String]
        println("arrayOfLevels: \(arrayOfLevels)") // this prints "[levels]"
        println("arrayOfLevels.count: \(arrayOfLevels.count)") // this prints "1"
        println("arrayOfLevels[0]: \(arrayOfLevels[0])") // this prints "levels"
    
        let levels = myDictionary!["levels"] as! [[String:AnyObject]]
        println("levels: \(levels)")  // this prints "[[clef: clefTreble, challenges: { ..." the whole array of levels and then everything
        println("levels[3] : \(levels[3])")  // this prints [clef: clefBass, challenges: { ...
        println(levels[3]["background"])  // this prints "Optional(bg4)"
        println(levels[3]["clef"])  // this prints "Optional(clefBass)"
        println(levels[3]["challenges"])  // this prints "Optional({ challenge01 = ..." 
        println(levels[3]["challenges"]!["challenge04"]!!)  // this prints "("E in a Space", S3)"
        println(levels[3]["challenges"]!["challenge04"]!![0])  // this prints "E in a Space"
        println(levels[3]["challenges"]!["challenge04"]!![1])  // this prints "S3"

        // return random values from dictionary through a random int
        let randomIndex: Int = Int(arc4random_uniform(UInt32(myDictionary!.count)))
        let value = Array(myDictionary.values)[randomIndex]
        let key = Array(myDictionary.keys)[randomIndex]
        let value = myDictionary[key]
        return (key, value!)
    }
*/
    
    func addBackground() {
        let bg = SKSpriteNode(imageNamed: "background1")
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
        noti.position = CGPoint(x: frame.width/2, y: frame.height*3/4)
        addChild(noti)
        followRoamingPath()
    }
    
    func followRoamingPath() {

        var path = CGPathCreateMutable()
        //CGPathMoveToPoint(path, nil, 0, 0)
        CGPathAddArc(path!, nil, 560, 360, 280, CGFloat(M_PI_2) , CGFloat(2*M_PI + M_PI_2) , false)
        var followArc = SKAction.followPath(path, asOffset: false, orientToPath: false, duration: 12.0)
        roamingNoti!.runAction(SKAction.repeatActionForever(followArc))

/*
        let pathCenter = CGPoint(x: frame.width/6 , y: frame.height/6)
        let pathDiameter = CGFloat(frame.height/2)
        let path = CGPathCreateWithEllipseInRect(CGRect(origin: pathCenter, size: CGSize(width: pathDiameter * 2.0, height: pathDiameter * 1.2)), nil)
        let followPath = SKAction.followPath(path, asOffset: false, orientToPath: false, duration: 12.0)
        roamingNoti!.runAction(SKAction.repeatActionForever(followPath))
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

}