//
//  LevelViewController.swift
//  MusicNotes
//
//  Created by Amanda Pi on 2015-06-08.
//  Copyright (c) 2015 Amanda. All rights reserved.
//

import UIKit
import SpriteKit
import Foundation

class LevelViewController: UIViewController {
    
    // create func to (1) load plist, (2) create level objects from plist (3) create button on screen for each level object from plist

    var currentLevel: Int = 0 // this is level number 1...9
    
    // could not put together a valid init method

    override func viewDidLoad() {
        super.viewDidLoad()
        
//    (1) load plist
        
        let myPlist = NSDictionary(contentsOfFile: NSBundle.mainBundle().pathForResource("Levels", ofType: "plist")!)!
        
        let levels = myPlist["levels"] as![[String:AnyObject]] 
/*
        println("levels.count is \(levels.count)") //this prints "levels.count is 9"
        println("levels[3]\(levels[3])") //this prints complete level 4
        println((levels[3]["clef"]!)) //this prints "clefBass"
        println((levels[3]["background"]!)) //this prints "bg4"
        println(levels[3]["challenges"]!) //this prints all 6 challenges in level04
        println(levels[3]["challenges"]!["challenge04"]!!) //this prints ""E in a Space", S3, soundE3"
        println(levels[3]["challenges"]!["challenge04"]!![0]) //this prints "E in a Space"
        println(levels[3]["challenges"]!["challenge04"]!![1]) //this prints "S3"
        println(levels[3]["challenges"]!["challenge04"]!![2]) //this prints "soundE3"
        println("levels \(levels)") //this prints complete plist
*/
//      (2) create levelObjects from plist
        
        for i in 1...levels.count {
            currentLevel = i
            //println("currentLevel is \(currentLevel)") //this prints 1 2 3 4 5 6 7 8 9
            
            var levelData = levels[currentLevel - 1] // this levelObject carries data in levels 1...9
            
            if (i == 2) {
                //println("levelObject is \(levelObject)") //this prints complete level2 data
                //println(levelData["clef"]!) //this prints "clefBass"
                //println(levelData["challenges"]!) //this prints all challenges in level 2
                //println(levelData["background"]!) //this prints "bg2"
                //println("currentLevel is \(currentLevel)") //this prints "2"
            }
        }

//       (3) create button on screen for each level object from plist
        
        var levelButton = UIButton.buttonWithType(.System) as! UIButton
        
        var buttonWidth = self.view.frame.width / 5.0
        var buttonHeight = buttonWidth * 0.75
        var gap = buttonWidth / 10.0
        var x5 = self.view.frame.width/2.0 - buttonWidth/2.0
        var y5 = self.view.frame.height/2.0 - buttonHeight/2.0
        var dx: CGFloat = gap + buttonWidth
        var dy: CGFloat = gap + buttonHeight
        var i: Int = currentLevel
        
        for i in 1...9 {
            
            if i <= 3 {
            
            var levelButton = UIButton.buttonWithType(.System) as! UIButton
            currentLevel = i
            levelButton.frame = CGRectMake(x5 + CGFloat(currentLevel)*dx - dx - dx , y5-dy, buttonWidth, buttonHeight)
            levelButton.setTitle("LEVEL \(currentLevel)", forState: UIControlState.Normal)
            levelButton.titleLabel!.font = UIFont.systemFontOfSize(36)
            levelButton.titleLabel!.adjustsFontSizeToFitWidth = true
            levelButton.titleLabel!.textColor = UIColor.blackColor()
            levelButton.titleLabel!.textAlignment = .Center
            levelButton.setBackgroundImage(UIImage(named: "bg\(currentLevel).png"), forState: UIControlState.Normal)
            levelButton.addTarget(self, action: "buttonPressed:", forControlEvents: UIControlEvents.TouchUpInside) // from plist

            self.view.addSubview(levelButton)
                
            } else if i < 7 {
                
                var levelButton = UIButton.buttonWithType(.System) as! UIButton
                currentLevel = i
                levelButton.frame = CGRectMake(x5 + CGFloat(currentLevel - 3)*dx - dx - dx , y5, buttonWidth, buttonHeight)
                levelButton.setTitle("LEVEL \(currentLevel)", forState: UIControlState.Normal)
                levelButton.titleLabel!.font = UIFont.systemFontOfSize(36)
                levelButton.titleLabel!.adjustsFontSizeToFitWidth = true
                levelButton.titleLabel!.textColor = UIColor.blackColor()
                levelButton.titleLabel!.textAlignment = .Center
                levelButton.setBackgroundImage(UIImage(named: "bg\(currentLevel).png"), forState: UIControlState.Normal)
                levelButton.addTarget(self, action: "buttonPressed:", forControlEvents: UIControlEvents.TouchUpInside) // from plist
                
                self.view.addSubview(levelButton)
                
            } else {
                
                var levelButton = UIButton.buttonWithType(.System) as! UIButton
                currentLevel = i
                levelButton.frame = CGRectMake(x5 + CGFloat(currentLevel - 6)*dx - dx - dx , y5 + dy, buttonWidth, buttonHeight)
                levelButton.setTitle("LEVEL \(currentLevel)", forState: UIControlState.Normal)
                levelButton.titleLabel!.font = UIFont.systemFontOfSize(36)
                levelButton.titleLabel!.adjustsFontSizeToFitWidth = true
                levelButton.titleLabel!.textColor = UIColor.blackColor()
                levelButton.titleLabel!.textAlignment = .Center
                levelButton.setBackgroundImage(UIImage(named: "bg\(currentLevel).png"), forState: UIControlState.Normal)
                levelButton.addTarget(self, action: "buttonPressed:", forControlEvents: UIControlEvents.TouchUpInside) // from plist
                
                self.view.addSubview(levelButton)
            }
        }
    }

    func buttonPressed(sender: AnyObject) {
        self.performSegueWithIdentifier("levelViewToGameView", sender: self)
        //selectedLevel = sender.tag
        //load respective levelData from plist
    }
    
/*  // somehow these 2 inits are not useful after creating classes Level and Challenge
    
    init(size: CGSize) {
        super.init(size: size)
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

*/

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
/*
    MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
*/    

}
