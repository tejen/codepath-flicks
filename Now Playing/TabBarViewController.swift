//
//  TabBarViewController.swift
//  Now Playing
//
//  Created by Tejen Hasmukh Patel on 2/2/16.
//  Copyright © 2016 Tejen. All rights reserved.
//

import UIKit

class TabBarViewController: UITabBarController, UITabBarControllerDelegate {

    let appDelegate = UIApplication.sharedApplication().delegate  as! AppDelegate;
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.delegate = self

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // UITabBarDelegate
    override func tabBar(tabBar: UITabBar, didSelectItem item: UITabBarItem) {

    }
    
    // UITabBarControllerDelegate
    func tabBarController(tabBarController: UITabBarController, didSelectViewController viewController: UIViewController) {
        let vc = viewController as! TabViewController;
        let NavigationController = vc.childViewControllers[0] as! UINavigationController;
        let Storyboard = UIStoryboard(name: "Main", bundle: nil);
        let TableVC = Storyboard.instantiateViewControllerWithIdentifier("FlicksViewController") as! UIViewController;
        
        switch(vc.title!) {
            case "Left Tab":
                appDelegate.navbarHeader = "Now Playing";
                appDelegate.endpoint = "now_playing";
            case "Right Tab":
                appDelegate.navbarHeader = "Popular";
                appDelegate.endpoint = "top_rated";
            default: break;
        }
        
        if(appDelegate.showingGrid == true) {
            let GridVC = Storyboard.instantiateViewControllerWithIdentifier("GridViewController") as! UIViewController;
            NavigationController.setViewControllers([TableVC, GridVC], animated: false);
        } else {
            NavigationController.setViewControllers([TableVC], animated: false);
        }
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
