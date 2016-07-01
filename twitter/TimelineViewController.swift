//
//  TimelineViewController.swift
//  twitter
//
//  Created by Shea Ketsdever on 6/28/16.
//  Copyright © 2016 Shea Ketsdever. All rights reserved.
//

import UIKit

class TimelineViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextViewDelegate {
    
    var tweets: [Tweet]!
    var tappedUser: User?
    var characterCount = 140
    
    @IBOutlet weak var submitTweetButton: UIButton!
    @IBOutlet weak var characterCountLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var composeTweetView: UIView!
    @IBOutlet weak var tweetTextField: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //tableView.estimatedRowHeight = 400
        //tableView.rowHeight = UITableViewAutomaticDimension
            
        tableView.delegate = self
        tableView.dataSource = self
        
        tweetTextField.delegate = self
        
        composeTweetView.hidden = true
        
        loadTweets()
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshControlAction), forControlEvents: UIControlEvents.ValueChanged)
        tableView.insertSubview(refreshControl, atIndex: 0)
        
        NSNotificationCenter.defaultCenter().addObserverForName(Tweet.retweetNotification, object: nil, queue: NSOperationQueue.mainQueue()) { (notification: NSNotification) in
            
            print("retweet notification received in view did load")
            if let retweetedTweet = notification.object as? Tweet {
                print("got retweeted tweet: \(retweetedTweet)")
                self.tweets.append(retweetedTweet)
            }
            self.tableView.reloadData()
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
        
        if characterCount >= 0 {
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
        } else {
            submitTweetButton.enabled = false
            print("character limit exceeded")
        }
        
        composeTweetView.hidden = true
    }
    
    func textViewDidChange(textView: UITextView) {
        let tweetText = tweetTextField.text
        let count = tweetText.characters.count
        if count > 140 {
            submitTweetButton.enabled = false
            print("character limit exceeded")
        } else {
            submitTweetButton.enabled = true
            characterCount = 140 - count
            characterCountLabel.text = "\(characterCount)"
        }
    }
    
    @IBAction func onTap(sender: UITapGestureRecognizer) {
        print("tapped")
        composeTweetView.hidden = true
    }
//    
//    func textView(textView: UITextView, shouldChangeCharactersInRange range: NSRange, replacementText text: String) -> Bool {
//        let newLength = tweetTextField.text.utf16.count + String().utf16.count - range.length
//        if newLength <= 14 {
//            self.characterCountLabel.text = "\(140 - newLength)"
//            return true
//        } else {
//            return false
//        }
//    }
    
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
            profileViewController.comingFromSegue = true
            
        }
    }
}