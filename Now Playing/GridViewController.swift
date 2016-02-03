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
    
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate;
    var time : Float = 0.0
    var timer: NSTimer?
    var tracker = NSDate().timeIntervalSince1970;
    
    var refreshControl: UIRefreshControl?;
    var refreshing = false;
    
    override func viewDidLoad() {
        super.viewDidLoad()

        collectionView.dataSource = self;
        collectionView.delegate = self;
        
        self.title = appDelegate.navbarHeader;
        
        let flow = UICollectionViewFlowLayout();
        let screenWidth = UIScreen.mainScreen().bounds.width;
        if(screenWidth > 410) { // for wider screens, 3 columns per row
            flow.itemSize = CGSizeMake(screenWidth/3, 240);
        } else { // for narrower screens, 2 columns per row
            flow.itemSize = CGSizeMake(screenWidth/2+4, 240);
        }
        flow.minimumInteritemSpacing = 0;
        flow.minimumLineSpacing = 0;
        collectionView.collectionViewLayout = flow;
        
        
        if(appDelegate.skipFetch == true) {
            appDelegate.skipFetch = false;
            loadSkip();
            collectionView.reloadData();
        } else {
            loadStarted();
            reloadList();
        }
        
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
                    if let responseDictionary = try! NSJSONSerialization.JSONObjectWithData( data, options:[]) as? NSDictionary {
                        self.appDelegate.movies = responseDictionary["results"] as? [NSDictionary];
                        self.appDelegate.movies!.sortInPlace {
                        if let a = $0 as? NSDictionary, b = $1 as? NSDictionary {
                                return (b["popularity"]?.integerValue < a["popularity"]?.integerValue)
                            } else {
                                return false
                            }
                        }
                        self.appDelegate.allMovies = self.appDelegate.movies;
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
            }
        )
        
        task.resume()
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let movies = appDelegate.movies {
            return movies.count;
        }
        return 0;
    }
    
    // The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:

    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("collectionCell", forIndexPath: indexPath) as! CollectionCell;
        
        let movie = appDelegate.movies![indexPath.row];
        let voteAverage = movie["vote_average"] as! NSNumber;
        let smallPosterURL = NSURL(string: "http://image.tmdb.org/t/p/w45" + (movie["poster_path"] as! String));
        let posterURL = NSURL(string: "http://image.tmdb.org/t/p/w500" + (movie["poster_path"] as! String));
        let releaseDate = movie["release_date"] as! String;
        let popularity = movie["popularity"] as! NSNumber;
        
        cell.smallImageRequest = NSURLRequest(URL: smallPosterURL!);
        cell.largeImageRequest = NSURLRequest(URL: posterURL!);
        cell.collectionPosterBlurBackground.setImageWithURL(posterURL!);
        
        let dateFormatter = NSDateFormatter();
        dateFormatter.dateFormat = "yyyy-MM-dd";
        let date = dateFormatter.dateFromString(releaseDate);
        dateFormatter.dateFormat = "MMM d";
        let dateText = dateFormatter.stringFromDate(date!);
        cell.collectionYearLabel.text = dateText;
        
        cell.collectionRatingLabel.text = voteAverage.stringValue;
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
    
    func loadSkip() {
        progressBar.alpha = 0.0;
        collectionView.hidden = false;
        UIView.animateWithDuration(0.5, animations: {
            self.collectionView.alpha = 1.0;
        });
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
    
    @IBAction func backButtonPress(sender: AnyObject) {
        appDelegate.showingGrid = false;
        appDelegate.skipFetch = true;
        navigationController?.popToViewController((navigationController?.childViewControllers[0])!, animated: true);
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if(segue.identifier == "toDetails") {
            let cell = sender as! UICollectionViewCell;
            let indexPath = collectionView.indexPathForCell(cell);
            let movie = appDelegate.movies![indexPath!.row];
            let detailViewController = segue.destinationViewController as! DetailViewController;
            detailViewController.movieID = movie["id"]!.integerValue;
            detailViewController.movieTitle = movie["title"]! as! String;
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
