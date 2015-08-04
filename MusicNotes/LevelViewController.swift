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

    var currentLevel : Level?
    var levels: NSMutableArray?
    
    // could not put together a valid init method - does a viewController needs an init?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        var levelButton = UIButton.buttonWithType(.System) as! UIButton
        
        var buttonWidth = self.view.frame.width / 5.0
        var buttonHeight = buttonWidth * 0.75
        var gap = buttonWidth / 10.0
        var x5 = self.view.frame.width/2.0 - buttonWidth/2.0
        var y5 = self.view.frame.height/2.0 - buttonHeight/2.0
        var dx: CGFloat = gap + buttonWidth
        var dy: CGFloat = gap + buttonHeight
        //var i: Int = currentLevel
        
        let levels = getLevels()
        
        for i in 1...levels.count {
  
            if i <= 3 {
            
            var levelButton = UIButton.buttonWithType(.System) as! UIButton
            levelButton.frame = CGRectMake(x5 + CGFloat(i)*dx - dx - dx , y5-dy, buttonWidth, buttonHeight)
            levelButton.setTitle("LEVEL \(i)", forState: UIControlState.Normal)
            levelButton.tag = i
            levelButton.titleLabel!.font = UIFont.systemFontOfSize(36)
            levelButton.titleLabel!.adjustsFontSizeToFitWidth = true
            
            //levelButton.titleLabel!.textColor = UIColor.blackColor()
            levelButton.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
            //levelButton.titleLabel!.shadowColor = UIColor.blackColor()
            levelButton.setTitleShadowColor(UIColor.blackColor(), forState: UIControlState.Normal)
            levelButton.titleLabel!.shadowOffset = CGSize(width: 3, height: 3)
            //find ot about shadowOpacity and shadowRadius on layer

            levelButton.titleLabel!.textAlignment = .Center
            levelButton.setBackgroundImage(UIImage(named: "bg\(i).png"), forState: UIControlState.Normal)
            levelButton.addTarget(self, action: "buttonPressed:", forControlEvents: UIControlEvents.TouchUpInside) 

            self.view.addSubview(levelButton)
                
            } else if i < 7 {
                
                var levelButton = UIButton.buttonWithType(.System) as! UIButton
                levelButton.frame = CGRectMake(x5 + CGFloat(i - 3)*dx - dx - dx , y5, buttonWidth, buttonHeight)
                levelButton.setTitle("LEVEL \(i)", forState: UIControlState.Normal)
                levelButton.tag = i
                levelButton.titleLabel!.font = UIFont.systemFontOfSize(36)
                levelButton.titleLabel!.adjustsFontSizeToFitWidth = true
                levelButton.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
                levelButton.setTitleShadowColor(UIColor.blackColor(), forState: UIControlState.Normal)
                levelButton.titleLabel!.shadowOffset = CGSize(width: 3, height: 3)
                levelButton.titleLabel!.textAlignment = .Center
                levelButton.setBackgroundImage(UIImage(named: "bg\(i).png"), forState: UIControlState.Normal)
                levelButton.addTarget(self, action: "buttonPressed:", forControlEvents: UIControlEvents.TouchUpInside)
                
                self.view.addSubview(levelButton)
                
            } else {
                
                var levelButton = UIButton.buttonWithType(.System) as! UIButton
                levelButton.frame = CGRectMake(x5 + CGFloat(i - 6)*dx - dx - dx , y5 + dy, buttonWidth, buttonHeight)
                levelButton.setTitle("LEVEL \(i)", forState: UIControlState.Normal)
                levelButton.tag = i
                levelButton.titleLabel!.font = UIFont.systemFontOfSize(36)
                levelButton.titleLabel!.adjustsFontSizeToFitWidth = true
                levelButton.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
                levelButton.setTitleShadowColor(UIColor.blackColor(), forState: UIControlState.Normal)
                levelButton.titleLabel!.shadowOffset = CGSize(width: 3, height: 3)
                levelButton.titleLabel!.textAlignment = .Center
                levelButton.setBackgroundImage(UIImage(named: "bg\(i).png"), forState: UIControlState.Normal)
                levelButton.addTarget(self, action: "buttonPressed:", forControlEvents: UIControlEvents.TouchUpInside)
                
                self.view.addSubview(levelButton)
            }
        }
    }
    
    func getLevels() -> NSArray {
        
        if levels == nil {
            let myPlist = NSDictionary(contentsOfFile: NSBundle.mainBundle().pathForResource("Levels", ofType: "plist")!)!
            let plistLevels = myPlist["levels"] as! [[String:AnyObject]] // the array of levels
            
            levels = NSMutableArray()
            
            for i in 0...(plistLevels.count-1) {  //plistLevels.count=9
                
                var levelData = plistLevels[i] // this levelData carries data in levels 1...9
                
                let background = levelData["background"] as! String
                let clef = levelData["clef"] as! String
                let challenges = levelData["challenges"] as! NSDictionary
                //println(levelData["background"]!) //prints bg for each i
                //println(levelData["clef"]!) //prints clef for each i
                //println(levelData["challenges"]!) //prints challenges for each i
                
                levels!.addObject(Level(background : background , clef : clef , challenges : challenges ))
            }
        }
        return levels!
    }
    
    func buttonPressed(sender: AnyObject) {
        var levelNumber = sender.tag
        let levels = getLevels()
        currentLevel = levels.objectAtIndex(levelNumber - 1) as? Level 
        self.performSegueWithIdentifier("levelViewToGameView", sender: self)
        //println("sender.tag is \(sender.tag)") //5 (when pressed 5)
        //println("levelNumber is \(levelNumber)")  //5 (when pressed 5)
        //println("got bg as \(currentLevel!.background)")  //bg5 (when pressed 5)
        //println("got bg? as \(currentLevel!.background)?")  //bg5? (when pressed 5)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        var destinationViewController: GameViewController = segue.destinationViewController as! GameViewController
        destinationViewController.setLevel(currentLevel!)
    }
    
    /*    required init(currentLevel: Level()) {
    //fatalError("NSCoding not supported")
    self.currentLevel = currentLevel
    super.init(size : NSSize)
    }
    
    required init(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
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
