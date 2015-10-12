//
//  LevelButton.swift
//  MusicNotes
//
//  Created by Amanda Pi on 2015-10-07.
//  Copyright © 2015 Amanda. All rights reserved.
//

import UIKit

class LevelButton : UIButton {
    var starImageView: UIImageView?
    var starImageName: String?
    
    func setNumberOfStars(highNumStars: Int) {
    
        if (highNumStars == 1) {
            starImageName = "stars1.png"
            } else if (highNumStars == 2) {
            starImageName = "stars2.png"
            } else if (highNumStars == 3) {
            starImageName = "stars3.png"
            } else {
            starImageName = "starsOutline.png"
            }
        
        if (starImageView != nil) {
            starImageView?.removeFromSuperview()
            }
        
        starImageView = UIImageView(image: UIImage(named: starImageName!))
        
        let buttonHeight = self.frame.size.height
        let buttonWidth = self.frame.size.width
        starImageView?.frame = CGRectMake(0 - buttonWidth*0.05, 0 + buttonHeight * 0.56, buttonWidth*1.1, buttonHeight/2.3)
            
        self.addSubview(starImageView!)
            }
    }
