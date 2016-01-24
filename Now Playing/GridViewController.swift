//
//  GridViewController.swift
//  Now Playing
//
//  Created by Tejen Hasmukh Patel on 1/23/16.
//  Copyright © 2016 Tejen. All rights reserved.
//

import UIKit

class GridViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var progressBar: UIProgressView!
    @IBOutlet weak var networkError: UIView!
    
    var time : Float = 0.0
    var timer: NSTimer?
    var tracker = NSDate().timeIntervalSince1970;
    
    var refreshControl: UIRefreshControl?;
    var refreshing = false;
    
    var allMovies: [NSDictionary]?;
    var movies: [NSDictionary]?;
    
    override func viewDidLoad() {
        super.viewDidLoad()

        collectionView.dataSource = self;
        collectionView.delegate = self;
        
        var flow = UICollectionViewFlowLayout();
        flow.itemSize = CGSizeMake(160, 240);
        flow.minimumInteritemSpacing = 0;
        flow.minimumLineSpacing = 0;
        collectionView.collectionViewLayout = flow;
        
        loadStarted();
        
        reloadList();
        
        let refreshControl = UIRefreshControl();
        refreshControl.addTarget(self, action: "refreshControlAction:", forControlEvents: UIControlEvents.ValueChanged)
        collectionView.insertSubview(refreshControl, atIndex: 0);
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
        tracker = NSDate().timeIntervalSince1970;
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
                if error != nil {
                    self.loadComplete(false);
                    self.showNetworkError();
                } else if let data = dataOrNil {
                    if let responseDictionary = try! NSJSONSerialization.JSONObjectWithData(
                        data, options:[]) as? NSDictionary {
                            self.movies = responseDictionary["results"] as! [NSDictionary];
                            self.movies!.sortInPlace {
                                if let a = $0 as? NSDictionary, b = $1 as? NSDictionary {
                                    return (b["popularity"]?.integerValue < a["popularity"]?.integerValue)
                                } else {
                                    return false
                                }
                            }
                            self.allMovies = self.movies;
                            let curTrack = NSDate().timeIntervalSince1970;
                            print(curTrack);
                            if((self.refreshing == false) || (curTrack - self.tracker > 2)) {
                                self.collectionView.reloadData();
                                self.loadComplete();
                            } else {
                                self.runAfterDelay(1.0) {
                                    self.collectionView.reloadData();
                                    self.loadComplete();
                                }
                            }
                    }
                }
        })
        
        task.resume()
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let movies = movies {
            return movies.count;
        }
        return 0;
    }
    
    // The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:

    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("collectionCell", forIndexPath: indexPath) as! collectionCell;
        
        let movie = movies![indexPath.row];
        let voteAverage = movie["vote_average"] as! NSNumber;
        let posterURL = NSURL(string: "http://image.tmdb.org/t/p/w500/" + (movie["poster_path"] as! String));
        let releaseDate = movie["release_date"] as! String;
        let popularity = movie["popularity"] as! NSNumber;
        
        cell.collectionPosterImageView.setImageWithURL(posterURL!);
        cell.collectionPosterImageViewForeground.setImageWithURL(posterURL!);
        
        let dateFormatter = NSDateFormatter();
        dateFormatter.dateFormat = "yyyy-MM-dd";
        let date = dateFormatter.dateFromString(releaseDate);
        dateFormatter.dateFormat = "MMM d";
        let dateText = dateFormatter.stringFromDate(date!);
        cell.collectionYearLabel.text = dateText;
        
        cell.collectionRatingLabel.text = voteAverage.stringValue;
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
        
        cell.collectionRatingLabel.layer.backgroundColor = color.CGColor;
        cell.collectionRatingLabel.layer.cornerRadius = 5;
        

        
        return cell;
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
        progressBar.setProgress(1.0, animated: true);
        if(showContent != false) {
            UIView.animateWithDuration(2.0, animations: {
                self.progressBar.alpha = 0.0;
            });
            self.collectionView.hidden = false;
            UIView.animateWithDuration(1.0, animations: {
                self.collectionView.alpha = 1.0;
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
        reloadList();
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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
