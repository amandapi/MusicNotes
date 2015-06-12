//
//  MusicNotes.swift
//  MusicNotes
//
//  Created by Amanda Pi on 2015-05-31.
//  Copyright (c) 2015 Amanda. All rights reserved.
//

import Foundation
import SpriteKit

class MusicNotes: SKSpriteNode {
    
    let POINTS_PER_SEC: CGFloat = 200.0
    var wayPoints: [CGPoint] = []
    var velocity = CGPoint(x: 0, y: 0)
    
    init(imageNamed name: String) {
       // let texture = SKTexture(imageNamed: name)
       // super.init(texture: texture, color: nil, size: texture.size())
        
        //create random noti's
        var textures = [SKTexture]()
        textures.append(SKTexture(imageNamed: "notiPinkU"))
        textures.append(SKTexture(imageNamed: "notiBlueU"))
        textures.append(SKTexture(imageNamed: "notiRedU"))
        textures.append(SKTexture(imageNamed: "notiGreenU"))
        textures.append(SKTexture(imageNamed: "notiGrayU"))
        let rand = Int(arc4random_uniform(UInt32(textures.count)))
        let texture = textures[rand] as SKTexture
        //noti.texture = texture
        super.init(texture: texture, color: nil, size: texture.size())
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func addMovingPoint(point: CGPoint) {
        wayPoints.append(point)
    }
    
    func move(dt: NSTimeInterval) {
        let currentPosition = position
        var newPosition = position
        
        if wayPoints.count > 0 {
            let targetPoint = wayPoints[0]
            
            // calculate vector to point to direction of pig travel
            let offset = CGPoint(x: targetPoint.x - currentPosition.x, y: targetPoint.y - currentPosition.y)
            let length = Double(sqrtf(Float(offset.x * offset.x) + Float(offset.y * offset.y)))
            let direction = CGPoint(x:CGFloat(offset.x) / CGFloat(length), y: CGFloat(offset.y) / CGFloat(length))
            velocity = CGPoint(x: direction.x * POINTS_PER_SEC, y: direction.y * POINTS_PER_SEC)
            
            // calculate noti's's new position
            newPosition = CGPoint(x:currentPosition.x + velocity.x * CGFloat(dt), y:currentPosition.y + velocity.y * CGFloat(dt))
            position = newPosition
            
            //  check if noti reached wayPoint
            if frame.contains(targetPoint) {
                wayPoints.removeAtIndex(0)
            }
        }
    }
    
    func createPathToMove() -> CGPathRef? {
        
        if wayPoints.count <= 1 {  // enough point for path?
            return nil
        }
        
        var ref = CGPathCreateMutable()  // create mutable CGPathRef so to add points to it
        
        for var i = 0; i < wayPoints.count; ++i { //iterate all waypoints to build the path
            let p = wayPoints[i]
            
            if i == 0 { // path is just starting
                CGPathMoveToPoint(ref, nil, p.x, p.y)
            } else {  // add a line to the point
                CGPathAddLineToPoint(ref, nil, p.x, p.y)
            }
        }
        
        return ref  // return the path
    }
    
}


