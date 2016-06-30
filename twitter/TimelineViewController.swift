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
    var tappedUser: User?
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var composeTweetView: UIView!
    @IBOutlet weak var tweetTextField: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //tableView.estimatedRowHeight = 400
        //tableView.rowHeight = UITableViewAutomaticDimension
            
        tableView.delegate = self
        tableView.dataSource = self
        
        composeTweetView.hidden = true
        
        loadTweets()
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshControlAction), forControlEvents: UIControlEvents.ValueChanged)
        tableView.insertSubview(refreshControl, atIndex: 0)
        
        NSNotificationCenter.defaultCenter().addObserverForName(Tweet.retweetNotification, object: nil, queue: NSOperationQueue.mainQueue()) { (notification: NSNotification) in
            
            print("retweet notification received in view did load")
            if let retweetedTweet = notification.object as? Tweet {
                print("got retweeted tweet")
                self.tweets.append(retweetedTweet)
            }
            self.tableView.reloadData()

            /*
            let retweet = notification.object as? Tweet
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
        
        NSNotificationCenter.defaultCenter().addObserverForName(Tweet.unRetweetNotification, object: nil, queue: NSOperationQueue.mainQueue()) { (notification: NSNotification) in
            
            print("unretweet notification received in view did load")
            self.loadTweets()
        }
        
        NSNotificationCenter.defaultCenter().addObserverForName(Tweet.favoriteNotification, object: nil, queue: NSOperationQueue.mainQueue()) { (notification: NSNotification) in
            
            print("favorite notification received in view did load")
            self.loadTweets()
        }
        
        NSNotificationCenter.defaultCenter().addObserverForName(Tweet.unFavoriteNotification, object: nil, queue: NSOperationQueue.mainQueue()) { (notification: NSNotification) in
            
            print("unfavorite notification received in view did load")
            self.loadTweets()
        }
        
        NSNotificationCenter.defaultCenter().addObserverForName(User.userPostedTweetNotification, object: nil, queue: NSOperationQueue.mainQueue()) { (notification: NSNotification) in
            
            print("userPostedTweetNotification received in view did load")
            self.loadTweets()
        }
        
        NSNotificationCenter.defaultCenter().addObserverForName(TimelineTableViewCell.profileImageTappedNotification, object: nil, queue: NSOperationQueue.mainQueue()) { (notification: NSNotification) in
            
            self.tappedUser = notification.object as? User
            self.performSegueWithIdentifier("TimelineToProfileSegue", sender: nil)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(animated: Bool) {
        loadTweets()
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
    
    @IBAction func onComposeTweetButton(sender: AnyObject) {
        print("hihihihihihi")
        composeTweetView.hidden = false
    }
    
    @IBAction func onSubmitTweetButton(sender: AnyObject) {
        print("submit tweet!")
        
        if let tweetTextAsString = tweetTextField.text {
            if let tweetTextAsUrlString = tweetTextAsString.stringByAddingPercentEncodingForRFC3986() {
                print("tweetTextAsUrlString: \(tweetTextAsUrlString)")
                TwitterClient.sharedInstance.postTweet(tweetTextAsUrlString, success: {
                    print("success")
                    
                    NSNotificationCenter.defaultCenter().postNotificationName(User.userPostedTweetNotification, object: nil)
                    
                    }, failure: { (error: NSError) in
                        print(error.localizedDescription)
                })
            }
        }
        
        composeTweetView.hidden = true
    }
    
    @IBAction func onTap(sender: UITapGestureRecognizer) {
        print("tapped")
        composeTweetView.hidden = true
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "TimelineToDetailSegue" {
            let cell = sender as! UITableViewCell
            let indexPath = tableView.indexPathForCell(cell)
            let tweet = tweets[indexPath!.row]
            print("\(tweet)")
            
            let detailViewController = segue.destinationViewController as! DetailViewController
            
            detailViewController.tweet = tweet
        }
        if segue.identifier == "TimelineToProfileSegue" {
            let profileViewController = segue.destinationViewController as! ProfileViewController
            profileViewController.user = tappedUser
            if tappedUser == User.currentUser {
                profileViewController.userIsCurrentUser = true
            } else {
                profileViewController.userIsCurrentUser = false
            }
            
        }
    }
}