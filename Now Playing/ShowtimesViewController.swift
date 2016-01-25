//
//  ShowtimesViewController.swift
//  Now Playing
//
//  Created by Tejen Hasmukh Patel on 1/24/16.
//  Copyright © 2016 Tejen. All rights reserved.
//

import UIKit

class ShowtimesViewController: UIViewController, UIWebViewDelegate {

    @IBOutlet weak var navBar: UINavigationItem!
    @IBOutlet weak var browserView: UIWebView!
    
    var movieTitle = "";
    var webLoaded = false;
    var navTitle = "More Info";
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        navBar.title = navTitle;
        var url = "\(movieTitle)+fandango".stringByAddingPercentEncodingWithAllowedCharacters(.URLHostAllowedCharacterSet())!;
        url = "http://www.google.com/search?q="+url+"&btnI";
        var nsu = NSURL(string: url);
        var nsr = NSURLRequest(URL: nsu!);
        browserView.delegate = self;
        browserView.loadRequest(nsr);
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func webView(webView: UIWebView, didFailLoadWithError error: NSError?) {
        print("Webview fail with error \(error)");
    }
    
    func webView(webView: UIWebView, shouldStartLoadWithRequest request: NSURLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        return true;
    }
    
    
    
    func webViewDidFinishLoad(webView: UIWebView) {
        if(webLoaded == false) {
            webLoaded = true;
            let initURL = webView.stringByEvaluatingJavaScriptFromString(
                "window.location.href"
            );
                
            webView.stopLoading();
            
            let FandangoMovieID = NSURL(string: initURL!)!.pathComponents![1];
            
            let newURL = "http://www.fandango.com/\(FandangoMovieID)/movietimes".stringByReplacingOccurrencesOfString("-", withString: "_");
            
            var nsu = NSURL(string: newURL);
            var nsr = NSURLRequest(URL: nsu!);
            webView.loadRequest(nsr);
            
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
