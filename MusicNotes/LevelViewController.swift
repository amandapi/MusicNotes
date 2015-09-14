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
    var chooseLevelLabel: UILabel?
    var introductionView = UIView(frame: CGRectMake(0, 0, 100, 100))
    var backgroundImageView: UIView?
    
    // could not put together a valid init method - does a viewController needs an init?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // add background
        let backgroundImageView = UIImageView(image: UIImage(named: "bgMainMenu.png"))
        backgroundImageView.frame = view.frame
        backgroundImageView.contentMode = .ScaleAspectFill
        self.view.addSubview(backgroundImageView)
        self.view.sendSubviewToBack(backgroundImageView)
        
        // add page title
        addChooseLevelLabel()
        
        //var levelButton = UIButton.buttonWithType(.System) as! UIButton
        var levelButton = UIButton()
        var buttonWidth = self.view.frame.width / 5.8
        var buttonHeight = buttonWidth * 0.75
        var gap = buttonWidth / 10.0
        var x5 = self.view.frame.width/2.0 - buttonWidth/2.0
        var y5 = self.view.frame.height/2.0 - buttonHeight/2.0
        var dx: CGFloat = gap + buttonWidth
        var dy: CGFloat = gap + buttonHeight
        
        let levels = getLevels()
        
        for i in 1...levels.count {
            //var levelButton = UIButton.buttonWithType(.Custom) as! UIButton
             levelButton = UIButton.buttonWithType(UIButtonType.Custom) as! UIButton
            //var levelButton = UIButton.buttonWithType(.System) as! UIButton
            //var levelButton = UIButton()
            if i <= 3 {
                levelButton.frame = CGRectMake(x5 + CGFloat(i)*dx - dx - dx , y5 - dy + gap*3, buttonWidth, buttonHeight)
            } else if i < 7 {
                levelButton.frame = CGRectMake(x5 + CGFloat(i - 3)*dx - dx - dx , y5 + gap*3, buttonWidth, buttonHeight)
            } else {
                levelButton.frame = CGRectMake(x5 + CGFloat(i - 6)*dx - dx - dx , y5 + dy + gap*3, buttonWidth, buttonHeight)
            }
            levelButton.setTitle("Level \(i)", forState: UIControlState.Normal)
            levelButton.tag = i
            
            //shadow for the 9 buttons
            levelButton.layer.shadowColor = UIColor.grayColor().CGColor;
            levelButton.layer.shadowOpacity = 0.8
            levelButton.layer.shadowRadius = 8
            levelButton.layer.shadowOffset = CGSizeMake(8.0, 8.0)
            
            // set background images
            levelButton.setBackgroundImage(UIImage(named: "bg\(i).png"), forState: UIControlState.Normal)
            
            // set titleLabel
            //levelButton.titleLabel!.font = UIFont.systemFontOfSize(36)
            levelButton.titleLabel!.font = UIFont.boldSystemFontOfSize(36)
            //levelButton.titleLabel!.font = UIFont(name: "Komikax Display Bold", size: 38)
            //levelButton.titleLabel!.adjustsFontSizeToFitWidth = true
            levelButton.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
            levelButton.titleLabel!.shadowColor = UIColor.blackColor()
            levelButton.setTitleShadowColor(UIColor.blackColor(), forState: UIControlState.Normal)
            levelButton.titleLabel!.shadowOffset = CGSize(width: 2.3, height: 2.3)
            
            // set image
            var starImage = UIImage(named: "scoreStars")
            levelButton.setImage(starImage, forState: UIControlState.Normal)
            levelButton.imageEdgeInsets = UIEdgeInsets(top: 70, left: 20, bottom: 20, right: 20)
            levelButton.titleEdgeInsets = UIEdgeInsets(top: 20, left: -200, bottom: 80, right: 0) // suppressing this line aligns title in iPad
            //levelButton.contentEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: -20, right: 0)
            
            // set action target for each button
            levelButton.addTarget(self, action: "buttonPressed:", forControlEvents: UIControlEvents.TouchUpInside)
            
            // add the 9 buttons
            self.view.addSubview(levelButton)
        }
        
        addIntroduction()
    }
    
    func addIntroduction() {
        
        // create introductionView
        self.introductionView = UIImageView(image: UIImage(named: "introduction.png"))
        introductionView.frame = view.frame
        introductionView.userInteractionEnabled = true
        
        introductionView.alpha = 0.0
        view.addSubview(introductionView)
        
        // create "OK!" button in introductionView
        var goButton = UIButton.buttonWithType(UIButtonType.System) as! UIButton
        goButton.setTitle("OK!", forState: UIControlState.Normal)
        goButton.setTitleColor(UIColor.blueColor(), forState: .Normal)
        goButton.titleLabel!.font = UIFont(name: "Komika Display", size: 68)
        goButton.backgroundColor = UIColor.clearColor()
        goButton.frame = CGRectMake(0 , self.view.frame.height/1.38 , introductionView.bounds.width, introductionView.bounds.height/6)
        goButton.addTarget(self, action: "goButtonPressed", forControlEvents: UIControlEvents.TouchUpInside)
        introductionView.addSubview(goButton)
        
        // animate appearance of introductionView
        introductionView.center = self.view.center
        UIView.animateWithDuration(0.0, delay: 0.0, options: .CurveEaseOut, animations:{
            self.introductionView.alpha = 1.0
            }, completion: nil)
    }
    
    func goButtonPressed() {
        UIView.animateWithDuration(3.8, animations: { () -> Void in
            self.introductionView.alpha = 0.0
        })
    }
        
    func getLevels() -> NSArray {
        
        if levels == nil {
            let myPlist = NSDictionary(contentsOfFile: NSBundle.mainBundle().pathForResource("Levels", ofType: "plist")!)!
            let plistLevels = myPlist["levels"] as! [[String:AnyObject]] // the array of levels
            
            levels = NSMutableArray()
            
            for i in 0...(plistLevels.count-1) {  //plistLevels.count=9
                
                var levelData = plistLevels[i] // this levelData carries data in levels 1...9
                
                let background = levelData["background"] as! String
                //let clef = levelData["clef"] as! String
                let challenges = levelData["challenges"] as! NSDictionary
                let timeLimit = levelData["timeLimit"] as! Int
                
               // levels!.addObject(Level(background : background , clef : clef , challenges : challenges ))
                levels!.addObject(Level(background: background, timeLimit: timeLimit, challenges: challenges ))
            }
        }
        return levels!
    }
    
    func buttonPressed(sender: AnyObject) {
        var levelNumber = sender.tag
        let levels = getLevels()
        currentLevel = levels.objectAtIndex(levelNumber - 1) as? Level 
        self.performSegueWithIdentifier("levelViewToGameView", sender: self)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        var destinationViewController: GameViewController = segue.destinationViewController as! GameViewController
        destinationViewController.setLevel(currentLevel!)
    }
    
    func addChooseLevelLabel() {
        
        var chooseLevelLabel = UILabel(frame: CGRectMake(self.view.frame.size.width/3.3 , self.view.frame.size.height/8.8 , self.view.frame.size.width/2.3, self.view.frame.size.width/10))
        chooseLevelLabel.textAlignment = NSTextAlignment.Center
        chooseLevelLabel.text = "Choose Your Level"
        chooseLevelLabel.textColor = UIColor.blackColor()
        chooseLevelLabel.font = UIFont(name: "Komika Display", size: 48)
        chooseLevelLabel.backgroundColor = UIColor.clearColor()
        self.view.addSubview(chooseLevelLabel)
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
