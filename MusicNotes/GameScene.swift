//
//  GameScene.swift
//  MusicNotes
//
//  Created by Amanda Pi on 2015-05-31.
//  Copyright (c) 2015 Amanda. All rights reserved.
//

import SpriteKit

class GameScene: SKScene {
    
    //var roamingNoti = MusicNotes(imageNamed: String())  //replace SKSpriteNode with subclass MusicNotes
    //var roamingNoti = MusicNotes(imageNamed: "notiPinkU")
    //var noti = MusicNotes(imageNamed: "notiPinkU")
    //var noti = MusicNotes(imageNamed: String())
    
    var roamingNoti: MusicNotes?
    var draggingNoti: Bool = false
    var movingNoti: MusicNotes?
    var lastUpdateTime: NSTimeInterval = 0.0
    var dt: NSTimeInterval = 0.0
    
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
    
    override init(size: CGSize) {
        super.init(size: size)
        
        //var noti = MusicNotes(imageNamed: String()) // this is line necessary?
        //var noti = MusicNotes(imageNamed: "notiRedU")
        roamingNoti?.name = "noti"
        addBackground()
        addStaffLines()
        addNoti()
        followRoamingPath()
        addTrebleClef()
        addBassClef()
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        roamingNoti!.removeAllActions()
        
       // if CGRectIntersectsRect(S3.frame, UIEdgeInsetsInsetRect(self.roamingNoti.frame, UIEdgeInsetsMake(82, 0, 16.4, 0))) {
        
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
        //if CGRectIntersectsRect(S3.frame, UIEdgeInsetsInsetRect(self.roamingNoti.frame, UIEdgeInsetsMake(75, 0, 15, 0))) {
            println("S3.frame is \(S3.frame)")
            println("S3.position.y is \(S3.position.y)")
            println("roamingNoti.frame is \(roamingNoti!.frame)")
            //roamingNoti.position.y = S3.position.y - (S3.frame.size.height/2)
            roamingNoti!.position.y = S3.position.y
            // clef rotates
            clefTreble.runAction(SKAction.rotateByAngle (CGFloat(2*M_PI), duration: 1.0))
            clefBass.runAction(SKAction.rotateByAngle (CGFloat(2*M_PI), duration: 1.0))
            addNoti()
        } else {
            //noti.removeFromParent()
            roamingNoti!.setScale(0.20)
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
        println("S5 y.Scale is \(S5.yScale)")
    }
    
    func addNoti() {
        
        var noti = MusicNotes(imageNamed: "notiPinkU")  // replace SKSpriteNode with new subclass MusicNotes
        
        //var noti = MusicNotes(imageNamed: String())
        
    // the following block moved to MusicNotes.swift
        /*
        var textures = [SKTexture]()
        textures.append(SKTexture(imageNamed: "notiPinkU"))
        textures.append(SKTexture(imageNamed: "notiBlueU"))
        textures.append(SKTexture(imageNamed: "notiRedU"))
        textures.append(SKTexture(imageNamed: "notiGreenU"))
        textures.append(SKTexture(imageNamed: "notiGrayU"))
        let rand = Int(arc4random_uniform(UInt32(textures.count)))
        let texture = textures[rand] as SKTexture
        noti.texture = texture
   // end of block that calls for random noti
*/

        noti.setScale(0.5)
        roamingNoti = noti
        noti.name = "noti"
        println("noti.name is \(noti.name)") // noti.name is optional("noti")
        noti.anchorPoint = CGPointMake(0.5, 0.25)

        //noti.physicsBody = SKPhysicsBody(rectangleOfSize: CGSize(width: noti.frame.size.width, height: noti.frame.size.height/3))
        //println("noti.frame.size is \(noti.frame.size)")
        //noti.physicsBody?.dynamic = false
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
        println("L2.size.height is \(L2.size.height)" )
        clefTreble.setScale(L2.size.height / 118)
        self.addChild(clefTreble)
    }
    
    func addBassClef() {
        clefBass.anchorPoint = CGPointMake(0.5, 0.71)
        clefBass.position = CGPoint(x: L4.position.x + frame.width/8, y: L4.position.y)
        clefBass.setScale(L4.size.height / 56)
        self.addChild(clefBass)
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

