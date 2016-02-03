//
//  TabViewController.swift
//  Now Playing
//
//  Created by Tejen Hasmukh Patel on 2/1/16.
//  Copyright © 2016 Tejen. All rights reserved.
//

import UIKit

class TabViewController: UIViewController, UITabBarDelegate {
    
    @IBOutlet var containerView: UIView!
    

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func loadGridOnRight() {
        performSegueWithIdentifier("embedGrid", sender: self);
    }
//    
//    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
//        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate;
//        if(segue.identifier == "embedLeft") {
//            print("embed left segue");
//            if(appDelegate.showingGrid == true) {
//                segue.setValue(GridViewController.self, forKey: "destinationViewController");
//            } else {
//                segue.setValue(GridViewController.self, forKey: "destinationViewController");
//            }
//        }
//        
//        if(segue.identifier == "embedRight") {
//            print("embed left segue");
//            if(appDelegate.showingGrid == true) {
//                let destination = segue.destinationViewController as! FlicksViewController;
//            } else {
//                let destination = segue.destinationViewController as! GridViewController;
//            }
//        }
//    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
