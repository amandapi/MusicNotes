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

    var instruction: String = "C in a Space"
    var location: String = "S3"
    var selectedLevel: Int = 1
//    var levels: NSDictionary?
    let level : NSDictionary? = NSDictionary(contentsOfFile: NSBundle.mainBundle().pathForResource("Level", ofType: "plist")!)
    
/*
    if let path = NSBundle.mainBundle().pathForResource("level", ofType: plist) {
        myDict = NSDictionary(contentsOfFile: path)
    }
    if let level = myDict {
        // use dictionary
    }
*/



    @IBAction func levelOne(sender: AnyObject) { // so all 8 buttons can segue to gameViewController
        self.performSegueWithIdentifier("levelToGame", sender: self)
        self.selectedLevel = sender.tag
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

 /*
        if let path = NSBundle.mainBundle().pathForResource("level", ofType: "plist") {
            levels = NSDictionary(contentsOfFile: path)
        }
*/

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
