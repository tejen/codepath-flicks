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
    @IBOutlet weak var actIndicator: UIActivityIndicatorView!
    
    var movieTitle = "";
    var webLoaded = false;
    var navTitle = "More Info";
    var movieIMDBid = "";
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        actIndicator.startAnimating();
        navBar.title = navTitle;
        var url = "\(movieTitle)+fandango".stringByAddingPercentEncodingWithAllowedCharacters(.URLHostAllowedCharacterSet())!;
        url = "http://www.google.com/search?q="+url+"&btnI";
        
        if(movieIMDBid != "") {
            if(navTitle == "Showtimes & Tickets") {
                url = "http://m.imdb.com/showtimes/title/\(movieIMDBid)";
            }
            if(navTitle == "Watch Trailer") {
                url = "http://m.imdb.com/title/\(movieIMDBid)";
            }
        }
        
        let nsu = NSURL(string: url);
        let nsr = NSURLRequest(URL: nsu!);
        browserView.delegate = self;
        browserView.loadRequest(nsr);
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func runAfterDelay(delay: NSTimeInterval, block: dispatch_block_t) {
        let time = dispatch_time(DISPATCH_TIME_NOW, Int64(delay * Double(NSEC_PER_SEC)))
        dispatch_after(time, dispatch_get_main_queue(), block)
    }
    
    func doFandangoTrailer(){
        let initURL = browserView.stringByEvaluatingJavaScriptFromString("window.location.href");
        let FandangoMovieID = NSURL(string: initURL!)!.pathComponents![1];
        let newURL = "http://www.fandango.com/\(FandangoMovieID)/movietimes".stringByReplacingOccurrencesOfString("-", withString: "_");
        let nsu = NSURL(string: newURL);
        let nsr = NSURLRequest(URL: nsu!);
        browserView.loadRequest(nsr);
        
        self.runAfterDelay(1.0, block: {
            UIView.animateWithDuration(0.5, animations: {
                self.browserView.alpha = 1.0;
                self.actIndicator.alpha = 0.0;
            });
            self.runAfterDelay(1.0, block: {
                self.actIndicator.removeFromSuperview();
            });
        });
    }
    
    func doTrailer() {
        let initURL = browserView.stringByEvaluatingJavaScriptFromString(
            // scrape the client (IMDB uses jQuery... Yay!) for trailer video
            "$('#titleOverview .media a.video-link').attr('href')"
            // (will fallback to Fandango and Google's I'm Feeling Lucky algorithm)
        );
        
        browserView.stopLoading();
        
        // let FandangoMovieID = NSURL(string: initURL!)!.pathComponents![1];
        // let newURL = "http://www.fandango.com/\(FandangoMovieID)/movietimes".stringByReplacingOccurrencesOfString("-", withString: "_");
        
        var newURL = "";
        if(initURL == "") {
            // IMDB doesn't have trailer.
            // fallback to Fandango, Google's I'm Feeling Lucky algorithm
            var url = "\(self.movieTitle)+fandango".stringByAddingPercentEncodingWithAllowedCharacters(.URLHostAllowedCharacterSet())!;
            url = "http://www.google.com/search?q=" + url + "&btnI";
            let nsu = NSURL(string: url);
            let nsr = NSURLRequest(URL: nsu!);
            self.browserView.loadRequest(nsr);
            runAfterDelay(3.0, block: {
                self.doFandangoTrailer();
            });
            return;
        } else {
            newURL = "http://m.imdb.com" + initURL!; // direct IMDB trailer
        }
        
        let nsu = NSURL(string: newURL);
        let nsr = NSURLRequest(URL: nsu!);
        browserView.loadRequest(nsr);
        
        self.runAfterDelay(1.0, block: {
            UIView.animateWithDuration(0.5, animations: {
                self.browserView.alpha = 1.0;
                self.actIndicator.alpha = 0.0;
            });
            self.runAfterDelay(1.0, block: {
                self.actIndicator.removeFromSuperview();
            });
        });
    }
    
    func webViewDidFinishLoad(webView: UIWebView) {
        if(webLoaded == false) {
            webLoaded = true;
            if(self.navTitle == "Watch Trailer") {
                runAfterDelay(5.0, block: {
                    self.doTrailer();
                });
            } else {
                UIView.animateWithDuration(0.5, animations: {
                    self.browserView.alpha = 1.0;
                    self.actIndicator.alpha = 0.0;
                });
            }
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
