//
//  GameScene.swift
//  MusicNotes
//
//  Created by Amanda Pi on 2015-05-31.
//  Copyright (c) 2015 Amanda. All rights reserved.
//

import SpriteKit

class GameScene: SKScene {
    
    var RoamingNoti = MusicNotes(imageNamed: "notiRed")  //replace SKSpriteNode with subclass MusicNotes
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
    
    override init(size: CGSize) {
        super.init(size: size)
        
      //  noti = MusicNotes(imageNamed: "notiRed")
        RoamingNoti.name = "noti"
        addBackground()
        addStaffLines()
        addNoti()
        followRoamingPath()
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        RoamingNoti.removeAllActions()
        
        if CGRectIntersectsRect(S3.frame, self.RoamingNoti.frame) {
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
        if CGRectIntersectsRect(S3.frame, self.RoamingNoti.frame) {
            println("S3.frame is \(S3.frame)")
            println("S3.position.y is \(S3.position.y)")
            //RoamingNoti.position.y = S3.position.y - (S3.frame.size.height/2)
            RoamingNoti.position.y = S3.position.y
            addNoti()
        } else {
            //noti.removeFromParent()
            RoamingNoti.setScale(0.25)
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
        let noti = MusicNotes(imageNamed: "notiRed")  // replace SKSpriteNode with new subclass MusicNotes
        RoamingNoti = noti
        noti.name = "noti"
        println("noti.name is \(noti.name)")
        //childNodeWithName("noti1")

        noti.anchorPoint = CGPointMake(0.5, 0.25)
        //noti.physicsBody = SKPhysicsBody(circleOfRadius:noti.size.width/4)
        noti.position = CGPoint(x: size.width / 2, y: size.height / 2)
        noti.zPosition = 3
        addChild(noti)
        followRoamingPath()
    }
    
    func followRoamingPath() {
        let pathCenter = CGPoint(x: frame.width/6 , y: frame.height/6)
        let pathDiameter = CGFloat(frame.height/2)
        let path = CGPathCreateWithEllipseInRect(CGRect(origin: pathCenter, size: CGSize(width: pathDiameter * 2.0, height: pathDiameter * 0.8)), nil)

        let followPath = SKAction.followPath(path, asOffset: false, orientToPath: false, duration: 12.0)
        RoamingNoti.runAction(SKAction.repeatActionForever(followPath))
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

