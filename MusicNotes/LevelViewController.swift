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
    var introductionView1 = UIView(frame: CGRectMake(0, 0, 100, 100))
    var greenNotiView = UIView(frame: CGRectMake(0, 0, 100, 100))
    var yellowNotiView = UIView(frame: CGRectMake(0, 0, 100, 100))
    var pinkNotiView = UIView(frame: CGRectMake(0, 0, 100, 100))
    var greyNotiView = UIView(frame: CGRectMake(0, 0, 100, 100))
    var brownNotiView = UIView(frame: CGRectMake(0, 0, 100, 100))
    var blueNotiView = UIView(frame: CGRectMake(0, 0, 100, 100))
    var introductionNotiView = UIView(frame: CGRectMake(0, 0, 100, 100))
    var backgroundImageView: UIView?
    var starImage = UIImage(named: "starsOutline.png")
    var goButton: UIButton?
    var starImageName: String!
    var starImageView: UIImageView?
    var levelButton = UIButton()
    
    // could not put together a valid init method - does a viewController needs an init?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // add background
        let backgroundImageView = UIImageView(image: UIImage(named: "introduction1.png"))
        backgroundImageView.frame = view.frame
        backgroundImageView.contentMode = .ScaleAspectFill
        self.view.addSubview(backgroundImageView)
        self.view.sendSubviewToBack(backgroundImageView)
        
        // add page title
        addChooseLevelLabel()
        
        // add buttons
        //var levelButton = UIButton()
        let buttonWidth = self.view.frame.width / 5.8
        let buttonHeight = buttonWidth * 0.75
        let gap = buttonWidth / 8.0
        let x5 = self.view.frame.width/2.0 - buttonWidth/2.0
        let y5 = self.view.frame.height/2.0 - buttonHeight/1.2
        let dx: CGFloat = gap + 1.2*buttonWidth
        let dy: CGFloat = gap + buttonHeight
        
        let levels = getLevels()
        
        for i in 1...levels.count {
            
            // read numStars from defaults
            let level = levels.objectAtIndex(i-1) as! Level
            let numStars = NSUserDefaults.standardUserDefaults().integerForKey(level.keyForLevelScore())
            
            if (numStars == 1) {
                starImageName = "stars1.png"
            } else if (numStars == 2) {
                starImageName = "stars2.png"
            } else if (numStars == 3) {
                starImageName = "stars3.png"
            } else {
                starImageName = "starsOutline.png"
            }
            //how to refresh starImageView immediately, without having to re-open game?
            
            print("level \(i): \(level.keyForLevelScore())")
            print("numStars: \(numStars)")
            
            levelButton = UIButton(type: .Custom)
            
            let starImageView = UIImageView(image: UIImage(named: starImageName))

            if i <= 3 {
                levelButton.frame = CGRectMake(x5 + CGFloat(i)*dx - dx - dx , y5 - dy + gap*3, buttonWidth, buttonHeight)
            } else if i < 7 {
                levelButton.frame = CGRectMake(x5 + CGFloat(i - 3)*dx - dx - dx , y5 + gap*3, buttonWidth, buttonHeight)
            } else {
                levelButton.frame = CGRectMake(x5 + CGFloat(i - 6)*dx - dx - dx , y5 + dy + gap*3, buttonWidth, buttonHeight)
            }
            levelButton.setTitle("Level \(i)", forState: UIControlState.Normal)
            levelButton.tag = i
            
            // add stars for all 9 levelButton
            starImageView.frame = CGRectMake(levelButton.frame.origin.x - buttonWidth/18, levelButton.frame.origin.y + buttonHeight/1.6, buttonWidth*1.1, buttonHeight/2.3)
            starImageView.tag = i
            
            // set background images
            levelButton.setBackgroundImage(UIImage(named: "bg\(i).png"), forState: UIControlState.Normal)
            
            // shadow for the 9 buttons
            levelButton.layer.shadowColor = UIColor.grayColor().CGColor;
            levelButton.layer.shadowOpacity = 0.8
            levelButton.layer.shadowRadius = 8
            levelButton.layer.shadowOffset = CGSizeMake(8.0, 8.0)
            
            // set titleLabel
            if (UIDevice.currentDevice().userInterfaceIdiom == .Pad) {
                levelButton.titleLabel!.font = UIFont(name: "Komika Display", size: 43)
            } else if (UIDevice.currentDevice().userInterfaceIdiom == .Phone) {
                levelButton.titleLabel!.font = UIFont(name: "Komika Display", size: 23)
            }
            levelButton.titleLabel?.adjustsFontSizeToFitWidth = true
            levelButton.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
            levelButton.titleLabel!.shadowColor = UIColor.blackColor()
            levelButton.setTitleShadowColor(UIColor.blackColor(), forState: UIControlState.Normal)
            levelButton.titleLabel!.shadowOffset = CGSize(width: 2.3, height: 2.3)
            levelButton.titleLabel!.contentMode = .ScaleAspectFit
            levelButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: buttonHeight/8, right: 0)
            
            // set action target for each button
            levelButton.addTarget(self, action: "levelButtonPressed:", forControlEvents: UIControlEvents.TouchUpInside)
            
            // add the 9 buttons and stars
            self.view.addSubview(levelButton)
            self.view.insertSubview(starImageView, aboveSubview: levelButton)
            
            // add resetStarsButton for temporary use
            let resetStarsButton = UIButton(type: .System)
            resetStarsButton.frame = CGRectMake(0, 0, self.view.frame.width/6, self.view.frame.height/8)
            resetStarsButton.backgroundColor = UIColor.redColor()
            resetStarsButton.setTitle("resetStars", forState: .Normal)
            resetStarsButton.titleLabel?.adjustsFontSizeToFitWidth = true
            resetStarsButton.addTarget(self, action: "resetStarsButtonPressed", forControlEvents: UIControlEvents.TouchUpInside)
            self.view.addSubview(resetStarsButton)

        }
        addIntroduction()
    }
    
    
    func resetStarsButtonPressed() {
        print("keys.count: \(NSUserDefaults.standardUserDefaults().dictionaryRepresentation().keys.count)")
        print("keys: \(NSUserDefaults.standardUserDefaults())")
        for key in NSUserDefaults.standardUserDefaults().dictionaryRepresentation().keys {
            NSUserDefaults.standardUserDefaults().removeObjectForKey(key)
        }
        // how to refresh starImageView immediately, without having to re-open game?
        //self.view.reloadInputViews()
       // self.view.insertSubview(starImageView!, aboveSubview: levelButton)
    }
    
    func addIntroduction() {
        
        // create introductionView
        self.introductionView1 = UIImageView(image: UIImage(named: "introduction1.png"))
        introductionView1.frame = view.frame
        introductionView1.userInteractionEnabled = true
        introductionView1.alpha = 0.0
        view.addSubview(introductionView1)
        
        // add 6 background noti
        _ = UIImage(named: "notiGreenU.png")
        self.greenNotiView = UIImageView(image: UIImage(named: "notiGreenU.png"))
        greenNotiView.frame = CGRectMake(self.view.frame.width * 0.09, self.view.center.y/3, self.view.frame.width/5, self.view.frame.height/5)
        greenNotiView.frame.size.width = view.frame.width * 0.1
        print("greenNotiView: \(greenNotiView)")
        print("self.view: \(self.view)")
        greenNotiView.contentMode = UIViewContentMode.ScaleAspectFit
        view.addSubview(greenNotiView)
        greenNotiView.alpha = 0.0
        _ = UIImage(named: "notiYellowU.png")
        self.yellowNotiView = UIImageView(image: UIImage(named: "notiYellowU.png"))
        yellowNotiView.frame = CGRectMake(self.view.frame.width * 0.232, self.view.center.y/5, self.view.frame.width/5, self.view.frame.height/5)
        yellowNotiView.frame.size.width = view.frame.width * 0.1
        yellowNotiView.contentMode = UIViewContentMode.ScaleAspectFit
        view.addSubview(yellowNotiView)
        yellowNotiView.alpha = 0.0
        _ = UIImage(named: "notiPinkU.png")
        self.pinkNotiView = UIImageView(image: UIImage(named: "notiPinkU.png"))
        pinkNotiView.frame = CGRectMake(self.view.frame.width * 0.375, self.view.center.y/7, self.view.frame.width/5, self.view.frame.height/5)
        pinkNotiView.frame.size.width = view.frame.width * 0.1
        pinkNotiView.contentMode = UIViewContentMode.ScaleAspectFit
        view.addSubview(pinkNotiView)
        pinkNotiView.alpha = 0.0
        _ = UIImage(named: "notiGreyU.png")
        self.greyNotiView = UIImageView(image: UIImage(named: "notiGreyU.png"))
        greyNotiView.frame = CGRectMake(self.view.frame.width * 0.519, self.view.center.y/7, self.view.frame.width/5, self.view.frame.height/5)
        greyNotiView.frame.size.width = view.frame.width * 0.1
        greyNotiView.contentMode = UIViewContentMode.ScaleAspectFit
        view.addSubview(greyNotiView)
        greyNotiView.alpha = 0.0
        _ = UIImage(named: "notiBrownU.png")
        self.brownNotiView = UIImageView(image: UIImage(named: "notiBrownU.png"))
        brownNotiView.frame = CGRectMake(self.view.frame.width * 0.662, self.view.center.y/5, self.view.frame.width/5, self.view.frame.height/5)
        brownNotiView.frame.size.width = view.frame.width * 0.1
        brownNotiView.contentMode = UIViewContentMode.ScaleAspectFit
        view.addSubview(brownNotiView)
        brownNotiView.alpha = 0.0
        _ = UIImage(named: "notiBlueU.png")
        self.blueNotiView = UIImageView(image: UIImage(named: "notiBlueU.png"))
        blueNotiView.frame = CGRectMake(self.view.frame.width * 0.805, self.view.center.y/3, self.view.frame.width/5, self.view.frame.height/5)
        blueNotiView.frame.size.width = view.frame.width * 0.1
        blueNotiView.contentMode = UIViewContentMode.ScaleAspectFit
        view.addSubview(blueNotiView)
        blueNotiView.alpha = 0.0
        
        // add where-do-i-go noti
        let introductionNotiImage = UIImage(named: "introductionNoti.png")!
        self.introductionNotiView = UIImageView(image: introductionNotiImage)
        introductionNotiView.frame = CGRectMake(0, 0, introductionNotiImage.size.width/2, introductionNotiImage.size.height/2)
        introductionNotiView.frame.size.width = view.frame.width * 0.38
        introductionNotiView.contentMode = UIViewContentMode.ScaleAspectFit
        introductionNotiView.userInteractionEnabled = true
        introductionNotiView.alpha = 0.0
        view.addSubview(introductionNotiView)
        
        // animate introductionView1
        introductionView1.center = self.view.center
        UIView.animateWithDuration(0.0, delay: 0.0, options: .CurveEaseOut, animations:{
            self.introductionView1.alpha = 1.0
            }, completion: nil)

        // animate 6 background noti
        UIView.animateWithDuration(0.1,  delay: 0.0, // greenNoti appears
            options: [],
            animations: {
                self.greenNotiView.alpha = 1.0
            },
            completion: {
                (value: Bool ) in
                UIView.animateWithDuration(0.1, delay: 0.06, // yellowNoti appears
                    options: [] ,
                    animations: {
                        self.yellowNotiView.alpha = 1
                    }, completion: {
                        (value: Bool ) in
                        UIView.animateWithDuration(0.1, delay: 0.12, // pinkNoti appears
                            options: [] ,
                            animations: {
                                self.pinkNotiView.alpha = 1
                            }, completion: {
                                (value: Bool ) in
                                UIView.animateWithDuration(0.1, delay: 0.16, // greyNoti appears
                                    options: [] ,
                                    animations: {
                                        self.greyNotiView.alpha = 1
                                    }, completion: {
                                        (value: Bool ) in
                                        UIView.animateWithDuration(0.1, delay: 0.18, // brownNoti appears
                                            options: [] ,
                                            animations: {
                                                self.brownNotiView.alpha = 1
                                            }, completion: {
                                                (value: Bool ) in
                                                UIView.animateWithDuration(0.1, delay: 0.22, // blueNoti appears
                                                    options: [] ,
                                                    animations: {
                                                        self.blueNotiView.alpha = 1
                                                    }, completion: {
                                                        (value: Bool ) in
                                                    })
        } )  } )  } )  } )  } )
        
        // animate where-do-i-go noti
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
        if (UIDevice.currentDevice().userInterfaceIdiom == .Pad) {
            goButton.titleLabel!.font = UIFont(name: "Komika Display", size: 128)
        } else if (UIDevice.currentDevice().userInterfaceIdiom == .Phone) {
            goButton.titleLabel!.font = UIFont(name: "Komika Display", size: 68)
        }
        goButton.backgroundColor = UIColor.clearColor()
        goButton.frame = CGRectMake(0 , self.view.frame.height/1.38 , introductionView1.bounds.width, introductionView1.bounds.height/6)
        goButton.addTarget(self, action: "goButtonPressed", forControlEvents: UIControlEvents.TouchUpInside)
        goButton.userInteractionEnabled = true
        introductionView1.addSubview(goButton)
        goButton.alpha = 0
        
        let bounds = goButton.bounds
        
        // animate Ready! button
        UIView.animateWithDuration(0.0,  delay: 3.8, // this got called first
            options: [],
            animations: {
                goButton.alpha = 1
            },
            completion: {  // then this got called
                (value: Bool ) in
                self.introductionView1.addSubview(goButton)
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
            self.greenNotiView.alpha = 0.0
            self.yellowNotiView.alpha = 0.0
            self.pinkNotiView.alpha = 0.0
            self.greyNotiView.alpha = 0.0
            self.brownNotiView.alpha = 0.0
            self.blueNotiView.alpha = 0.0
            self.introductionNotiView.alpha = 0.0 // should these be .removeFromSuperView to save memory
        })
    }
        
    func getLevels() -> NSArray {
        if levels == nil {
            let myPlist = NSDictionary(contentsOfFile: NSBundle.mainBundle().pathForResource("Levels", ofType: "plist")!)!
            let plistLevels = myPlist["levels"] as! [[String:AnyObject]] // the array of levels
            levels = NSMutableArray()
            for i in 0...(plistLevels.count-1) {
                var levelData = plistLevels[i]
                let background = levelData["background"] as! String
                let challenges = levelData["challenges"] as! NSDictionary
                let timeLimit = levelData["timeLimit"] as! Int
                levels!.addObject(Level(number: i, background: background, timeLimit: timeLimit, challenges: challenges ))
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
        let chooseLevelLabel = UILabel(frame: CGRectMake(self.view.frame.width/3.3 , self.view.frame.height*0.01 , self.view.frame.width/2.3, self.view.frame.height/8))
        
        self.view.frame.height/2.0
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
