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
    //var introductionView1: UIView?
    //var introductionView2: UIView?
    var introductionView1 = UIView(frame: CGRectMake(0, 0, 100, 100))
    var introductionView2 = UIView(frame: CGRectMake(0, 0, 100, 100))
    var introductionNotiView = UIView(frame: CGRectMake(0, 0, 100, 100))
    var backgroundImageView: UIView?
    var goButton: UIButton?
    
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
        let buttonWidth = self.view.frame.width / 5.8
        let buttonHeight = buttonWidth * 0.75
        let gap = buttonWidth / 8.0
        let x5 = self.view.frame.width/2.0 - buttonWidth/2.0
        let y5 = self.view.frame.height/2.0 - buttonHeight/1.2
        let dx: CGFloat = gap + 1.2*buttonWidth
        let dy: CGFloat = gap + buttonHeight
        
        let levels = getLevels()
        
        for i in 1...levels.count {
             levelButton = UIButton(type: .Custom)
            if i <= 3 {
                levelButton.frame = CGRectMake(x5 + CGFloat(i)*dx - dx - dx , y5 - dy + gap*3, buttonWidth, buttonHeight)
            } else if i < 7 {
                levelButton.frame = CGRectMake(x5 + CGFloat(i - 3)*dx - dx - dx , y5 + gap*3, buttonWidth, buttonHeight)
            } else {
                levelButton.frame = CGRectMake(x5 + CGFloat(i - 6)*dx - dx - dx , y5 + dy + gap*3, buttonWidth, buttonHeight)
            }
            levelButton.setTitle("Level \(i)", forState: UIControlState.Normal)
            levelButton.tag = i
            
            // set background images
            levelButton.setBackgroundImage(UIImage(named: "bg\(i).png"), forState: UIControlState.Normal)
            
            //shadow for the 9 buttons
            levelButton.layer.shadowColor = UIColor.grayColor().CGColor;
            levelButton.layer.shadowOpacity = 0.8
            levelButton.layer.shadowRadius = 8
            levelButton.layer.shadowOffset = CGSizeMake(8.0, 8.0)
            
            // set titleLabel
            levelButton.titleLabel!.font = UIFont.boldSystemFontOfSize(36)
            //levelButton.titleLabel!.font = UIFont(name: "Komikax Display", size: 38)
            levelButton.titleLabel?.adjustsFontSizeToFitWidth = true
            levelButton.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
            levelButton.titleLabel!.shadowColor = UIColor.blackColor()
            levelButton.setTitleShadowColor(UIColor.blackColor(), forState: UIControlState.Normal)
            levelButton.titleLabel!.shadowOffset = CGSize(width: 2.3, height: 2.3)
            
            // set image
            //var starImage = UIImage(named: "scoreStars3")
            //levelButton.setImage(starImage, forState: UIControlState.Normal)
            //levelButton.imageEdgeInsets = UIEdgeInsets(top: 80, left: 20, bottom: 20, right: 20)
            //levelButton.titleEdgeInsets = UIEdgeInsets(top: 20, left: -200, bottom: 80, right: 0)
            //levelButton.contentEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: -20, right: 0)
            
            // set action target for each button
            levelButton.addTarget(self, action: "levelButtonPressed:", forControlEvents: UIControlEvents.TouchUpInside)
            
            // add the 9 buttons
            self.view.addSubview(levelButton)
        }
        
        addIntroduction()
    }
    
    func addIntroduction() {
        
        // create introductionView
        self.introductionView1 = UIImageView(image: UIImage(named: "introduction1.png"))
        introductionView1.frame = view.frame
        introductionView1.userInteractionEnabled = true
        introductionView1.alpha = 0.0
        view.addSubview(introductionView1)
        
        self.introductionView2 = UIImageView(image: UIImage(named: "introduction2.png"))
        introductionView2.frame = view.frame
        introductionView2.userInteractionEnabled = true
        introductionView2.alpha = 0.0
        view.addSubview(introductionView2)
        
        let introductionNotiImage = UIImage(named: "introductionNoti.png")!
        self.introductionNotiView = UIImageView(image: introductionNotiImage)
        introductionNotiView.frame = CGRectMake(0, 0, introductionNotiImage.size.width/2, introductionNotiImage.size.height/2)
        introductionNotiView.frame.size.width = view.frame.width * 0.38
        introductionNotiView.contentMode = UIViewContentMode.ScaleAspectFit
        introductionNotiView.userInteractionEnabled = true
        introductionNotiView.alpha = 0.0
        view.addSubview(introductionNotiView)
        
        introductionView1.center = self.view.center
        UIView.animateWithDuration(0.0, delay: 0.0, options: .CurveEaseOut, animations:{
            self.introductionView1.alpha = 1.0
            }, completion: nil)
        
        introductionView2.center = self.view.center
        UIView.animateWithDuration(1.8, delay: 0.8, options: .CurveEaseOut, animations:{
            self.introductionView2.alpha = 1.0
            }, completion: nil)
        
        introductionNotiView.center = CGPointMake(self.view.frame.width/2 - introductionNotiView.frame.width/2 , self.view.frame.height/2)
        UIView.animateWithDuration(0.1,  delay: 1.8, // this got called first
            options: [],
            animations: {
                self.introductionNotiView.alpha = 1.0
            },
            completion: {  // then this got called
                (value: Bool ) in
                UIView.animateWithDuration(2.8, delay: 0.0,
                  //  options: UIViewAnimationOptions.Repeat | .CurveEaseInOut | .Autoreverse ,
                    options: [.Repeat, .CurveEaseInOut, .Autoreverse] ,
                    animations: {
                        self.introductionNotiView.layer.position.x += self.view.frame.width/5
                    }, completion: {
                        (value: Bool ) in
                    }
                )
            } )
        
        // create "Ready!" button in introductionView
        let goButton = UIButton(type: .System)
        goButton.setTitle("Ready!", forState: UIControlState.Normal)
        goButton.setTitleColor(UIColor.redColor(), forState: .Normal)
        goButton.titleLabel!.font = UIFont(name: "Komika Display", size: 68)
        goButton.backgroundColor = UIColor.clearColor()
        goButton.frame = CGRectMake(0 , self.view.frame.height/1.38 , introductionView2.bounds.width, introductionView2.bounds.height/6)
        goButton.addTarget(self, action: "goButtonPressed", forControlEvents: UIControlEvents.TouchUpInside)
        goButton.userInteractionEnabled = true
        introductionView2.addSubview(goButton)
        goButton.alpha = 0
        
        let bounds = goButton.bounds
        
        UIView.animateWithDuration(0.0,  delay: 3.8, // this got called first
            options: [],
            animations: {
                goButton.alpha = 1
            },
            completion: {  // then this got called
                (value: Bool ) in
                self.introductionView2.addSubview(goButton)
                UIView.animateWithDuration(1.0, delay: 1.0, usingSpringWithDamping: 0.08, initialSpringVelocity: 13, options: [], //.Repeat | .Autoreverse,
                    animations: {
                    goButton.bounds = CGRect(x: bounds.origin.x, y: bounds.origin.y - 80, width: bounds.size.width, height: bounds.size.height + 100)
                    goButton.enabled = true
                    }, completion: {
                        (value: Bool ) in
                    }
                )
        } )
    }
    
    func goButtonPressed() {
        UIView.animateWithDuration(1.8, animations: { () -> Void in
            self.introductionView1.alpha = 0.0
            self.introductionView2.alpha = 0.0
            self.introductionNotiView.alpha = 0.0
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
                let challenges = levelData["challenges"] as! NSDictionary
                let timeLimit = levelData["timeLimit"] as! Int
                levels!.addObject(Level(background: background, timeLimit: timeLimit, challenges: challenges ))
            }
        }
        return levels!
    }
    
    func levelButtonPressed(sender: AnyObject) {
        let levelNumber = sender.tag
        let levels = getLevels()
        currentLevel = levels.objectAtIndex(levelNumber - 1) as? Level 
        self.performSegueWithIdentifier("levelViewToGameView", sender: self)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let destinationViewController: GameViewController = segue.destinationViewController as! GameViewController
        destinationViewController.setLevel(currentLevel!)
    }
    
    func addChooseLevelLabel() {
//        var chooseLevelLabel = UILabel(frame: CGRectMake(self.view.frame.width/3.3 , self.view.frame.height*0.01 , self.view.frame.width/2.3, self.view.frame.width/10))
        let chooseLevelLabel = UILabel(frame: CGRectMake(self.view.frame.width/3.3 , self.view.frame.height*0.001 , self.view.frame.width/2.3, self.view.frame.height/8))
        //chooseLevelLabel.center = view.center
        chooseLevelLabel.textAlignment = NSTextAlignment.Center
        chooseLevelLabel.text = "Choose Your Level"
        chooseLevelLabel.textColor = UIColor.blackColor()
        chooseLevelLabel.font = UIFont(name: "Komika Display", size: 48)
        chooseLevelLabel.adjustsFontSizeToFitWidth = true
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
