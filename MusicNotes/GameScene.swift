//
//  GameScene.swift
//  MusicNotes
//
//  Created by Amanda Pi on 2015-05-31.
//  Copyright (c) 2015 Amanda. All rights reserved.
//

import SpriteKit


class GameScene: SKScene {
    
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
    
    var movingNoti: MusicNotes?
    var lastUpdateTime: NSTimeInterval = 0.0
    var dt: NSTimeInterval = 0.0
    let noti = MusicNotes(imageNamed: "notiRed")  // replace SKSpriteNode with new subclass MusicNotes
    
    override init(size: CGSize) {
        super.init(size: size)
        
        addBackground()
        addStaffLines()
        addNoti()
        followRoamingPath()
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        noti.removeAllActions()
        let touch = touches.first as? UITouch
        let location = touch!.locationInNode(self)
        let node = nodeAtPoint(location)
        if node.name == "noti" {
            let noti = node as! MusicNotes
            noti.addMovingPoint(location)
            movingNoti = noti
        }
    }
    
    override func touchesMoved(touches: Set<NSObject>, withEvent event: UIEvent) {
        let touch = touches.first as? UITouch
        let location = touch!.locationInNode(scene)
        if let noti = movingNoti {
            noti.addMovingPoint(location)
        }
    }
    
    override func touchesEnded(touches: Set<NSObject>, withEvent event: UIEvent) {
        //movingNoti = nil
        
        // check collision
        if CGRectIntersectsRect(S3.frame, self.noti.frame) {
            noti.setScale(2.0)
        } else {
            noti.setScale(0.5)
            //noti.removeFromParent()
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
/*        let S0 = SKSpriteNode(imageNamed: "S0")
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
*/
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
    }
    
    func addNoti() {
        //let noti = Noti(imageNamed: "notiRed")  // replace SKSpriteNode with new subclass Noti
        noti.name = "noti"
        noti.anchorPoint = CGPointMake(0.5, 0.25)
        //noti.physicsBody = SKPhysicsBody(circleOfRadius:noti.size.width/4)
        noti.position = CGPoint(x: size.width / 2, y: size.height / 2)
        noti.zPosition = 3
        addChild(noti)
    }
    
    func followRoamingPath() {
        let pathCenter = CGPoint(x: frame.width/6 , y: frame.height/6)
        let pathDiameter = CGFloat(frame.height/2)
        let path = CGPathCreateWithEllipseInRect(CGRect(origin: pathCenter, size: CGSize(width: pathDiameter * 2.0, height: pathDiameter * 0.8)), nil)
        let followPath = SKAction.followPath(path, asOffset: false, orientToPath: false, duration: 12.0)
        noti.runAction(SKAction.repeatActionForever(followPath))
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
                shapeNode.lineWidth = 18
                shapeNode.zPosition = 1
                self.addChild(shapeNode)
            }
        })
    }
}

