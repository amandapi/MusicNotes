//
//  LevelButton.swift
//  MusicNotes
//
//  Created by Michael Verde on 2015-10-06.
//  Copyright © 2015 Amanda. All rights reserved.
//

import UIKit

class LevelButton : UIButton {
    var starImageView: UIImageView?
    
    func setNumberOfStars(numStars: Int) {
        let starImageName: String!
        
        if (numStars == 1) {
            starImageName = "stars1.png"
        } else if (numStars == 2) {
            starImageName = "stars2.png"
        } else if (numStars == 3) {
            starImageName = "stars3.png"
        } else {
            starImageName = "starsOutline.png"
        }
        
        if (starImageView != nil) {
            starImageView?.removeFromSuperview()
        }
        
        starImageView = UIImageView(image: UIImage(named: starImageName))
        
        let buttonHeight = self.frame.size.height
        let buttonWidth = self.frame.size.width
        starImageView?.frame = CGRectMake(0 - buttonWidth*0.05, 0 + buttonHeight * 0.56, buttonWidth*1.1, buttonHeight/2.3)
        
        self.addSubview(starImageView!)
    }
}
