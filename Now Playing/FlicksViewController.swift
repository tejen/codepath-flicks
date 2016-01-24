//
//  FlicksViewController.swift
//  Now Playing
//
//  Created by Tejen Hasmukh Patel on 1/23/16.
//  Copyright © 2016 Tejen. All rights reserved.
//

import UIKit
import AFNetworking

class FlicksViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var progressBar: UIProgressView!
    
    var time : Float = 0.0
    var timer: NSTimer?
    var tracker = NSDate().timeIntervalSince1970;
    
    var refreshControl: UIRefreshControl?;
    var refreshing = false;
    
    var movies: [NSDictionary]?;
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tracker = NSDate().timeIntervalSince1970;
        
        tableView.frame.origin.y = CGFloat(0);
        tableView.contentInset = UIEdgeInsetsMake(60, 0, 0, 0);
        tableView.dataSource = self;
        tableView.delegate = self;
        
        loadStarted();
        
        reloadList();
        
        let refreshControl = UIRefreshControl();
        refreshControl.addTarget(self, action: "refreshControlAction:", forControlEvents: UIControlEvents.ValueChanged)
        tableView.insertSubview(refreshControl, atIndex: 0);
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func runAfterDelay(delay: NSTimeInterval, block: dispatch_block_t) {
        let time = dispatch_time(DISPATCH_TIME_NOW, Int64(delay * Double(NSEC_PER_SEC)))
        dispatch_after(time, dispatch_get_main_queue(), block)
    }
    
    func reloadList() {
        let apiKey = "a07e22bc18f5cb106bfe4cc1f83ad8ed"
        let url = NSURL(string: "https://api.themoviedb.org/3/movie/now_playing?api_key=\(apiKey)")
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
                if let data = dataOrNil {
                    if let responseDictionary = try! NSJSONSerialization.JSONObjectWithData(
                        data, options:[]) as? NSDictionary {
                            self.movies = responseDictionary["results"] as! [NSDictionary];
                            self.movies!.sortInPlace {
                                if let a = $0 as? NSDictionary, b = $1 as? NSDictionary {
                                    return (b["vote_average"]?.integerValue < a["vote_average"]?.integerValue)
                                } else {
                                    return false
                                }
                            }
                            self.tableView.reloadData();
                            let curTrack = NSDate().timeIntervalSince1970;
                            print(curTrack);
                            if((self.refreshing == false) && (curTrack - self.tracker > 5)) {
                                self.loadComplete();
                            } else {
                                self.runAfterDelay(1.0) {
                                    self.loadComplete();
                                }
                            }
                    }
                }
        })
        
        task.resume()
    }
    
    @IBAction func loadStarted() {
        progressBar.progress = 0.0;
        time = 0.0;
        UIView.animateWithDuration(0.5, animations: {
            self.progressBar.alpha = 1.0;
        });
        timer = NSTimer.scheduledTimerWithTimeInterval(0.001, target: self, selector:Selector("setProgress"), userInfo: nil, repeats: true);
    }
    
    @IBAction func loadComplete() {
        timer!.invalidate();
        progressBar.setProgress(1.0, animated: true);
        UIView.animateWithDuration(2.0, animations: {
            self.progressBar.alpha = 0.0;
        });
        UIView.animateWithDuration(1.0, animations: {
            self.tableView.alpha = 1.0;
        });
        if(refreshing == true) {
            refreshing = false;
            self.refreshControl!.endRefreshing();
        }
    }
    
    func refreshControlAction(refreshControl: UIRefreshControl) {
        refreshing = true;
        self.refreshControl = refreshControl;
        loadStarted();
        reloadList();
    }
    
    func setProgress() {
        time += 0.001
        progressBar.setProgress(time / 3, animated: true)
        if time >= 2.7 {
            timer!.invalidate()
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let movies = movies {
            return movies.count;
        }
        // network error
        return 0;
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("tableCell", forIndexPath: indexPath) as! tableCell;
        
        let movie = movies![indexPath.row];
        let title = movie["title"] as! String;
        let overview = movie["overview"] as! String;
        let posterURL = NSURL(string: "http://image.tmdb.org/t/p/w500/" + (movie["poster_path"] as! String));
        let releaseDate = movie["release_date"] as! String;
        let voteAverage = movie["vote_average"] as! NSNumber;
        let popularity = movie["popularity"] as! NSNumber;
        
        cell.titleLabel.text = title;

        cell.synopsisView.text = overview;
        cell.synopsisView.contentInset = UIEdgeInsetsMake(-4,-4,0,0);

        cell.posterImageView.setImageWithURL(posterURL!);

        
        let dateFormatter = NSDateFormatter();
        dateFormatter.dateFormat = "yyyy-MM-dd";
        let date = dateFormatter.dateFromString(releaseDate);
        dateFormatter.dateFormat = "MMM d";
        let dateText = dateFormatter.stringFromDate(date!);
        cell.subtitleLabel.text = dateText;
        
        cell.ratingLabel.text = voteAverage.stringValue;
        
//        
//        var color = UIColor(red: 0.18, green: 0.8, blue: 0.44, alpha: 1);
//        // rgb(46, 204, 113)
//        if(popularity.integerValue < 40) { // rgb(39, 174, 96)
//            color = UIColor(red: 0.15, green: 0.68, blue: 0.38, alpha: 1);
//        }
//        if(popularity.integerValue < 30) { // rgb(241, 196, 15)
//            color = UIColor(red: 0.95, green: 0.77, blue: 0.059, alpha: 1);
//        }
        
        var color = UIColor(red: 0.27, green: 0.62, blue: 0.27, alpha: 1);
        if(popularity.integerValue < 40) {
            color = UIColor(red: 0.223, green: 0.52, blue: 0.223, alpha: 1);
        }
        if(popularity.integerValue < 20) { // rgb(243, 156, 18)
            color = UIColor(red: 0.95, green: 0.6, blue: 0.071, alpha: 1);
        }
        if(popularity.integerValue < 10) { // rgb(230, 126, 34)
            color = UIColor(red: 0.90, green: 0.5, blue: 0.13, alpha: 1);
        }
        if(popularity.integerValue < 6) { // rgb(211, 84, 0)
            color = UIColor(red: 0.83, green: 0.33, blue: 0.33, alpha: 1);
        }
        if(popularity.integerValue < 5) { // rgb(231, 76, 60)
            color = UIColor(red: 0.91, green: 0.3, blue: 0.235, alpha: 1);
        }
        if(popularity.integerValue < 4) { // rgb(192, 57, 43)
            color = UIColor(red: 0.75, green: 0.22, blue: 0.22, alpha: 1);
        }
        
        cell.ratingLabel.layer.backgroundColor = color.CGColor;
        cell.ratingLabel.layer.cornerRadius = 5;
        
        return cell;
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
