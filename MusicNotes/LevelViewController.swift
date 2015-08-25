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

    //var introductionBannerView = UIView()
    var introductionBannerView = UIView(frame: CGRectMake(0, 0, 100, 100))
    //let status = UIImageView(image: UIImage(named: "introductionBanner"))
    
    // could not put together a valid init method - does a viewController needs an init?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        addChooseLevelLabel()
        
        var levelButton = UIButton.buttonWithType(.System) as! UIButton
        
        var buttonWidth = self.view.frame.width / 5.8
        var buttonHeight = buttonWidth * 0.75
        var gap = buttonWidth / 10.0
        var x5 = self.view.frame.width/2.0 - buttonWidth/2.0
        var y5 = self.view.frame.height/2.0 - buttonHeight/2.0
        var dx: CGFloat = gap + buttonWidth
        var dy: CGFloat = gap + buttonHeight
        //var i: Int = currentLevel
        
        let levels = getLevels()
        
        for i in 1...levels.count {
            
            var levelButton = UIButton.buttonWithType(.System) as! UIButton
  
            if i <= 3 {
                levelButton.frame = CGRectMake(x5 + CGFloat(i)*dx - dx - dx , y5 - dy + gap*3, buttonWidth, buttonHeight)
            } else if i < 7 {
                levelButton.frame = CGRectMake(x5 + CGFloat(i - 3)*dx - dx - dx , y5 + gap*3, buttonWidth, buttonHeight)
            } else {
                levelButton.frame = CGRectMake(x5 + CGFloat(i - 6)*dx - dx - dx , y5 + dy + gap*3, buttonWidth, buttonHeight)
            }
            
            levelButton.setTitle("LEVEL \(i)", forState: UIControlState.Normal)
            levelButton.tag = i
            levelButton.titleLabel!.font = UIFont.systemFontOfSize(36)
            levelButton.titleLabel!.adjustsFontSizeToFitWidth = true
            //levelButton.titleLabel!.textColor = UIColor.blackColor()
            levelButton.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
            //levelButton.titleLabel!.shadowColor = UIColor.blackColor()
            levelButton.setTitleShadowColor(UIColor.blackColor(), forState: UIControlState.Normal)
            levelButton.titleLabel!.shadowOffset = CGSize(width: 3, height: 3)
            //find out about shadowOpacity and shadowRadius on layer
            levelButton.titleLabel!.textAlignment = .Center
            levelButton.setBackgroundImage(UIImage(named: "bg\(i).png"), forState: UIControlState.Normal)
            levelButton.addTarget(self, action: "buttonPressed:", forControlEvents: UIControlEvents.TouchUpInside)
            
            self.view.addSubview(levelButton)
        }
        
       // add introductionBanner
        introductionBannerView.frame = CGRectMake(0, 0, self.view.frame.width, self.view.frame.height/2.8)
        introductionBannerView.center = self.view.center
        introductionBannerView.backgroundColor = UIColor(patternImage: UIImage(named: "introductionBanner.png")!)
        //introductionBannerView.autoresizingMask = UIViewAutoresizing.FlexibleBottomMargin | UIViewAutoresizing.FlexibleHeight | UIViewAutoresizing.FlexibleRightMargin | UIViewAutoresizing.FlexibleLeftMargin | UIViewAutoresizing.FlexibleTopMargin | UIViewAutoresizing.FlexibleWidth
        introductionBannerView.contentMode = UIViewContentMode.ScaleAspectFit
        introductionBannerView.layer.borderWidth = 2
        introductionBannerView.layer.cornerRadius = 25
        self.view.addSubview(introductionBannerView)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
 
        // move banner off the screen to start
        introductionBannerView.center.y -= view.bounds.width
        
        // animate banner back to the screen
        UIView.animateWithDuration(1.2, delay: 0.0,
            options: .CurveEaseIn, animations: {
                self.introductionBannerView.center.y += self.view.bounds.width
            }, completion: nil)

        // animate banner away
        UIView.animateWithDuration(2.8, delay: 3.8,
            options: .CurveEaseIn | .CurveEaseOut, animations: {
                self.introductionBannerView.center.y += self.view.bounds.width
            }, completion: nil)

    }



    
        //self.view.backgroundColor = UIColor(patternImage: UIImage(named: "introductionBanner.png")!)
        
        
        
/*        var myButton = UIButton.buttonWithType(.System) as! UIButton
        //let myImage = UIImage(named: "introductionBanner.png") as UIImage?
        //let myButton = UIButton.buttonWithType(UIButtonType.System) as! UIButton
        myButton.frame = CGRectMake(200, 300, 800, 300)
        myButton.setBackgroundImage(UIImage(named: "introductionBanner.png"), forState: UIControlState.Normal)
        myButton.addTarget(self, action: "myButtonTouched:", forControlEvents: UIControlEvents.TouchUpInside)
        self.view.addSubview(myButton)
        println(myButton)
*/
    
    
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
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        var destinationViewController: GameViewController = segue.destinationViewController as! GameViewController
        destinationViewController.setLevel(currentLevel!)
    }
    
    func addChooseLevelLabel() {
        
        var chooseLevelLabel = UILabel(frame: CGRectMake(self.view.frame.size.width/3 , self.view.frame.size.height/6 , self.view.frame.size.width/3, self.view.frame.size.width/10))
        //chooseLevelLabel.center = CGPointMake(self.view.frame.width/2 , self.view.frame.height)
        chooseLevelLabel.textAlignment = NSTextAlignment.Center
        chooseLevelLabel.text = "Choose Your Level"
        chooseLevelLabel.textColor = UIColor.blackColor()
        //chooseLevelLabel.font = UIFont(name: "Verdana-Bold", size: chooseLevelLabel.font.pointSize)
        chooseLevelLabel.font = UIFont(name: "Verdana-Bold", size: 33)
        chooseLevelLabel.sizeToFit()
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
