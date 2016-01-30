//
//  DetailViewController.swift
//  Now Playing
//
//  Created by Tejen Hasmukh Patel on 1/24/16.
//  Copyright © 2016 Tejen. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {

    var movie: NSDictionary?;
    var movieID: Int?;
    var movieTitle = "";
    
    @IBOutlet weak var navBar: UINavigationItem!
    @IBOutlet weak var progressBar: UIProgressView!
    @IBOutlet weak var networkError: UIView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var stallSpinner: UIActivityIndicatorView!
    @IBOutlet weak var staller: UILabel!
    @IBOutlet weak var blurredBackdrop: UIImageView!
    @IBOutlet weak var mainBackdrop: UIImageView!
    @IBOutlet weak var blurredSubBackdrop: UIImageView!
    @IBOutlet weak var posterImage: UIImageView!
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var taglineLabel: UILabel!
    @IBOutlet weak var releaseDateLabel: UILabel!
    @IBOutlet weak var runtimeLabel: UILabel!
    @IBOutlet weak var ratingLabel: UILabel!
    @IBOutlet weak var genresLabel: UILabel!
    @IBOutlet weak var budgetLabel: UILabel!
    @IBOutlet weak var salesLabel: UILabel!
    @IBOutlet weak var synopsisText: UITextView!
    
    var time : Float = 0.0
    var timer: NSTimer?
    var tracker = NSDate().timeIntervalSince1970;

    var refreshControl: UIRefreshControl?;
    var refreshing = false;
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        navBar.title = movieTitle;
        
        UIView.animateWithDuration(1.0, animations: {
            self.staller.alpha = 1.0;
            self.stallSpinner.alpha = 1.0;
        });
        
        scrollView.contentSize = CGSize(width: UIScreen.mainScreen().bounds.size.width, height: 823);
        scrollView.autoresizingMask = .FlexibleHeight;
        
        loadStarted();
        reloadDetails();
        
        let refreshControl = UIRefreshControl();
        refreshControl.addTarget(self, action: "refreshControlAction:", forControlEvents: UIControlEvents.ValueChanged)
        scrollView.insertSubview(refreshControl, atIndex: 0);

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func runAfterDelay(delay: NSTimeInterval, block: dispatch_block_t) {
        let time = dispatch_time(DISPATCH_TIME_NOW, Int64(delay * Double(NSEC_PER_SEC)))
        dispatch_after(time, dispatch_get_main_queue(), block)
    }
    
    func reloadData() { // repopulate elements in Details view
        if let movie = movie {
            titleLabel.text = movie["title"] as? String;
            
            taglineLabel.text = movie["tagline"] as? String;
            
            var genres = [""];
            genres.removeAll();
            for genre in (movie["genres"] as? [NSDictionary])! {
                genres.append(genre["name"] as! String);
            }
            genresLabel.text = genres.joinWithSeparator(", ");
            
            ratingLabel.text = movie["vote_average"]!.stringValue + " / 10";
            let popularity = movie["popularity"] as! NSNumber;
            var color = UIColor(red: 0.27, green: 0.62, blue: 0.27, alpha: 1);
            switch(popularity.integerValue) {
                case 20..<40: color = UIColor(red: 0.223, green: 0.52, blue: 0.223, alpha: 1);
                case 10..<20: color = UIColor(red: 0.95, green: 0.6, blue: 0.071, alpha: 1);
                case 6..<10: color = UIColor(red: 0.90, green: 0.5, blue: 0.13, alpha: 1);
                case 5..<6: color = UIColor(red: 0.83, green: 0.33, blue: 0.33, alpha: 1);
                case 4..<5: color = UIColor(red: 0.91, green: 0.3, blue: 0.235, alpha: 1);
                case 0..<4: color = UIColor(red: 0.75, green: 0.22, blue: 0.22, alpha: 1);
                default: break;
            }
            
            ratingLabel.layer.backgroundColor = color.CGColor;
            ratingLabel.layer.cornerRadius = 5;
            
            let releaseDate = movie["release_date"] as! String;
            let dateFormatter = NSDateFormatter();
            dateFormatter.dateFormat = "yyyy-MM-dd";
            let date = dateFormatter.dateFromString(releaseDate);
            dateFormatter.dateFormat = "MMMM d, yyyy";
            let dateText = dateFormatter.stringFromDate(date!);
            releaseDateLabel.text = dateText;
            
            var runtime = movie["runtime"]!.integerValue!;
            if(runtime == 0) {
                runtimeLabel.text = "Runtime Varies";
            } else {
                let minutes = runtime % 60;
                runtime /= 60;
                let hours = runtime % 24;
                runtimeLabel.text = "\(hours) hr \(minutes) min";
            }
            
            let formatter = NSNumberFormatter();
            formatter.numberStyle = .CurrencyStyle;
            formatter.locale = NSLocale.currentLocale();
            formatter.maximumFractionDigits = 0;
            
            let budget = movie["budget"]!.integerValue!;
            if(budget == 0) {
                budgetLabel.text = "Undisclosed Production Budget"; // LOL
            } else {
                budgetLabel.text = formatter.stringFromNumber(budget)! + " Budget";
            }
            
            let revenue = movie["revenue"]!.integerValue!;
            if(revenue == 0) {
                salesLabel.text = "Box Office Revenue Withheld"; // LOL
            } else {
                salesLabel.text = formatter.stringFromNumber(revenue)! + " Box Office Sales";
            }
            
            let synopsis = movie["overview"] as! String;
            if(synopsis == "") {
                synopsisText.text = "No Synopsis Available";
            } else {
                synopsisText.text = synopsis;
            }
            
            // encountered a movie in TMDB (WWE Royal Rumble 2016) that had no backdrop image! 1/28/16 @ 2:57am
            if let backgroundPath = movie["backdrop_path"] as? String {
                let backdropURL = NSURL(string: "http://image.tmdb.org/t/p/w500/" + backgroundPath);
                mainBackdrop.setImageWithURL(backdropURL!);
                blurredBackdrop.setImageWithURL(backdropURL!);
                blurredSubBackdrop.setImageWithURL(backdropURL!);
            }
            
            let posterURL = NSURL(string: "http://image.tmdb.org/t/p/w92/" + (movie["poster_path"] as! String));
            posterImage.setImageWithURL(posterURL!);
        }
    }
    
    func reloadDetails() {
        tracker = NSDate().timeIntervalSince1970;
        let apiKey = "a07e22bc18f5cb106bfe4cc1f83ad8ed"
        let url = NSURL(string: "http://api.themoviedb.org/3/movie/\(movieID!)?api_key=\(apiKey)")
        let request = NSURLRequest(
            URL: url!,
            cachePolicy: NSURLRequestCachePolicy.ReloadIgnoringLocalCacheData,
            timeoutInterval: 10)
        
        let session = NSURLSession(
            configuration: NSURLSessionConfiguration.defaultSessionConfiguration(),
            delegate: nil,
            delegateQueue: NSOperationQueue.mainQueue()
        )
        
        let task: NSURLSessionDataTask = session.dataTaskWithRequest(request,
            completionHandler: { (dataOrNil, response, error) in
                if error != nil {
                    self.loadComplete(false);
                    self.showNetworkError();
                } else if let data = dataOrNil {
                    if let responseDictionary = try! NSJSONSerialization.JSONObjectWithData(
                        data, options:[]) as? NSDictionary {
                            self.movie = responseDictionary;
                            let curTrack = NSDate().timeIntervalSince1970;
                            print(curTrack);
                            if(curTrack - self.tracker > 2) {
                                self.reloadData();
                                self.loadComplete();
                            } else {
                                self.runAfterDelay(1.0) {
                                    self.reloadData();
                                    self.loadComplete();
                                }
                            }
                    }
                }
        })
        
        task.resume()
    }
    
    
    
    func loadStarted() {
        progressBar.progress = 0.0;
        time = 0.0;
        hideNetworkError();
        UIView.animateWithDuration(0.5, animations: {
            self.progressBar.alpha = 1.0;
        });
        timer = NSTimer.scheduledTimerWithTimeInterval(0.001, target: self, selector:Selector("setProgress"), userInfo: nil, repeats: true);
    }
    
    func loadComplete(showContent : Bool? = true) {
        timer!.invalidate();
        
        if let staller = self.staller {
            UIView.animateWithDuration(0.25, animations: {
                self.staller.alpha = 0;
                self.stallSpinner.alpha = 0;
            });
            runAfterDelay(0.25, block: {
                    self.staller.removeFromSuperview();
                    self.stallSpinner.removeFromSuperview();
            });
        }
        
        runAfterDelay(2.0, block: {
            self.blurredBackdrop.hidden = false;
        });
        
        progressBar.setProgress(1.0, animated: true);
        if(showContent != false) {
            UIView.animateWithDuration(2.0, animations: {
                self.progressBar.alpha = 0.0;
            });
            self.scrollView.hidden = false;
            UIView.animateWithDuration(1.0, animations: {
                self.scrollView.alpha = 1.0;
            });
            runAfterDelay(1.0, block: {
                UIView.animateWithDuration(1.0, animations: {
                    self.blurredBackdrop.alpha = 1.0;
                });
            });
            if(refreshing == true) {
                refreshing = false;
                self.refreshControl!.endRefreshing();
            }
        } else {
            UIView.animateWithDuration(0.5, animations: {
                self.progressBar.alpha = 0.5;
            });
        }
    }
    
    func showNetworkError() {
        self.networkError.alpha = 0.0;
        self.networkError.hidden = false;
        UIView.animateWithDuration(0.5, animations: {
            self.networkError.alpha = 1.0;
        });
    }
    
    func hideNetworkError() {
        if(self.networkError.hidden == false) {
            UIView.animateWithDuration(0.5, animations: {
                self.networkError.alpha = 0.0;
            });
            runAfterDelay(0.5, block: {
                self.networkError.hidden = true;
            });
        }
    }
    
    @IBAction func tapOnNetworkError(sender: AnyObject) {
        hideNetworkError();
        loadStarted();
        reloadDetails();
    }
    
    func refreshControlAction(refreshControl: UIRefreshControl) {
        refreshing = true;
        self.refreshControl = refreshControl;
        loadStarted();
        reloadDetails();
    }
    
    func setProgress() {
        time += 0.001
        progressBar.setProgress(time / 3, animated: true)
        if time >= 2.7 {
            timer!.invalidate()
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if(segue.identifier == "toShowtimes") {
            let showtimesViewController = segue.destinationViewController as! ShowtimesViewController;
            showtimesViewController.navTitle = "Showtimes & Tickets";
            showtimesViewController.movieTitle = movie!["title"]! as! String;
            showtimesViewController.movieIMDBid = movie!["imdb_id"]! as! String;
        }
        if(segue.identifier == "toTrailer") {
            let showtimesViewController = segue.destinationViewController as! ShowtimesViewController;
            showtimesViewController.navTitle = "Watch Trailer";
            showtimesViewController.movieTitle = movie!["title"]! as! String;
            showtimesViewController.movieIMDBid = movie!["imdb_id"]! as! String;
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
