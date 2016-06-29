//
//  TimelineViewController.swift
//  twitter
//
//  Created by Shea Ketsdever on 6/28/16.
//  Copyright © 2016 Shea Ketsdever. All rights reserved.
//

import UIKit

class TimelineViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var tweets: [Tweet]!
    
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //tableView.estimatedRowHeight = 400
        //tableView.rowHeight = UITableViewAutomaticDimension
            
        tableView.delegate = self
        tableView.dataSource = self
        
        loadTweets()
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshControlAction), forControlEvents: UIControlEvents.ValueChanged)
        tableView.insertSubview(refreshControl, atIndex: 0)
        
        NSNotificationCenter.defaultCenter().addObserverForName(Tweet.retweetNotification, object: nil, queue: NSOperationQueue.mainQueue()) { (notification: NSNotification) in
            
            print("retweet notification received in view did load")
            
            /*let retweet = notification.object as? Tweet
            if let retweet = retweet {
                var index = 0
                for tweet in self.tweets {
                    if tweet.idString == retweet.idString {
                        self.tweets[index] = retweet
                        self.tableView.reloadData()
                        print("tweet: \(tweet)")
                        print("retweet: \(retweet)")
                    }
                    index = index + 1
                }
            }*/
        }
        
        NSNotificationCenter.defaultCenter().addObserverForName(Tweet.favoriteNotification, object: nil, queue: NSOperationQueue.mainQueue()) { (notification: NSNotification) in
            
            print("favorite notification received in view did load")
            
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func refreshControlAction(refreshControl: UIRefreshControl) {
        loadTweets()
        refreshControl.endRefreshing()
    }
    
    func loadTweets() {
        TwitterClient.sharedInstance.homeTimeline({ (tweets: [Tweet]) in
            self.tweets = tweets
            self.tableView.reloadData()
            
            /*for tweet in tweets {
                print(tweet.text)
            }*/
        }) { (error: NSError) in
            print(error.localizedDescription)
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let tweets = tweets {
            return tweets.count
        } else {
            return 0
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("TimelineTableViewCell", forIndexPath: indexPath) as! TimelineTableViewCell
        
        let tweet = tweets[indexPath.row]
        cell.tweet = tweet
        
        return cell
    }
    
    
    @IBAction func onLogOutButton(sender: AnyObject) {
        TwitterClient.sharedInstance.logout()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let cell = sender as! UITableViewCell
        let indexPath = tableView.indexPathForCell(cell)
        let tweet = tweets[indexPath!.row]
        print("\(tweet)")
        
        let detailViewController = segue.destinationViewController as! DetailViewController
        
        detailViewController.tweet = tweet
    }
    
}