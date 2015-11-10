//
//  MusicNotes.swift
//  MusicNotes
//
//  Created by Amanda Pi on 2015-05-31.
//  Copyright (c) 2015 Amanda. All rights reserved.
//

import SpriteKit

class MusicNotes: SKSpriteNode {
    
    let pointsPerSec: CGFloat = 200.0
    var wayPoints: [CGPoint] = []
    var velocity = CGPoint(x: 0, y: 0)
    var textures: [SKTexture] = []
    
    init(imageNamed: String) {
        //create random noti's
        textures.append(SKTexture(imageNamed: "notiPinkU.png"))
        textures.append(SKTexture(imageNamed: "notiBlueU.png"))
        textures.append(SKTexture(imageNamed: "notiGreenU.png"))
        textures.append(SKTexture(imageNamed: "notiGreyU.png"))
        textures.append(SKTexture(imageNamed: "notiRedU.png"))
        textures.append(SKTexture(imageNamed: "notiYellowU.png"))
        textures.append(SKTexture(imageNamed: "notiBrownU.png"))
        let rand = Int(arc4random_uniform(UInt32(textures.count)))
        let texture = textures[rand] as SKTexture
        super.init(texture: texture, color: UIColor.clearColor(), size: texture.size())
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func addMovingPoint(point: CGPoint) {  // MovingPoints in gameScene for roaming
        wayPoints.append(point)
    }
    
    func move(dt: NSTimeInterval) {
        let currentPosition = position
        var newPosition = position
        
        if wayPoints.count > 0 {  // if distance > targetPoint = destinationPoint
            let targetPoint = wayPoints[0]
            
            // calculate vector to point to direction of pig travel
            let offset = CGPoint(x: targetPoint.x - currentPosition.x, y: targetPoint.y - currentPosition.y)
            let length = Double(sqrtf(Float(offset.x * offset.x) + Float(offset.y * offset.y)))
            let direction = CGPoint(x:CGFloat(offset.x) / CGFloat(length), y: CGFloat(offset.y) / CGFloat(length))
            velocity = CGPoint(x: direction.x * pointsPerSec, y: direction.y * pointsPerSec)
            
            // calculate noti's's new position
            newPosition = CGPoint(x:currentPosition.x + velocity.x * CGFloat(dt), y:currentPosition.y + velocity.y * CGFloat(dt))
            position = newPosition
            
            //  check if noti reached wayPoint
            if frame.contains(targetPoint) {
                wayPoints.removeAtIndex(0)      
            }
        }
    }
    
    func scoringRect() -> CGRect {
        return CGRectMake(self.frame.origin.x, self.frame.origin.y + frame.size.height/6, self.frame.size.width * 0.76, self.frame.size.height/6)
        }

}


