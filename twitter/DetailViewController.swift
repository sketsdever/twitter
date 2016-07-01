//
//  DetailViewController.swift
//  twitter
//
//  Created by Shea Ketsdever on 6/28/16.
//  Copyright © 2016 Shea Ketsdever. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tweetUserProfileImage: UIImageView!
    @IBOutlet weak var currentUserProfileImage: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var timestampLabel: UILabel!
    @IBOutlet weak var timestampUnitLabel: UILabel!
    @IBOutlet weak var tweetTextLabel: UILabel!
    @IBOutlet weak var replyTextField: UITextField!
    @IBOutlet weak var retweetButton: UIButton!
    @IBOutlet weak var favoriteButton: UIButton!
    @IBOutlet weak var favoritesCountLabel: UILabel!
    @IBOutlet weak var retweetsCountLabel: UILabel!
    
    @IBOutlet weak var tableView: UITableView!
    
    var tweet: Tweet?
    var replies: [Tweet]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if tweet?.retweetedStatus != nil {
            print("eventually display some sort of bar saying that this is a retweet")
            tweet = tweet?.retweetedStatus
        }
        
        loadReplies()
        
        loadData()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        let currentUserProfileTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(currentUserProfileImageTapped))
        currentUserProfileImage.userInteractionEnabled = true
        currentUserProfileImage.addGestureRecognizer(currentUserProfileTapGestureRecognizer)
        
        let tweetUserProfileTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tweetUserProfileImageTapped))
        tweetUserProfileImage.userInteractionEnabled = true
        tweetUserProfileImage.addGestureRecognizer(tweetUserProfileTapGestureRecognizer)
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshControlAction), forControlEvents: UIControlEvents.ValueChanged)
        tableView.insertSubview(refreshControl, atIndex: 0)
        
        NSNotificationCenter.defaultCenter().addObserverForName(User.userPostedReplyNotification, object: nil, queue: NSOperationQueue.mainQueue()) { (notification: NSNotification) in
            
            print("unretweet notification received in view did load")
            self.loadReplies()
        }
    }
    
    func refreshControlAction(refreshControl: UIRefreshControl) {
        loadReplies()
        refreshControl.endRefreshing()
    }
    
    func loadReplies() {
        TwitterClient.sharedInstance.findReplies(tweet!, success: { (result: [Tweet]) in
            print("got results!!!")
            self.replies = result
            self.tableView.reloadData()
        }) { (error: NSError) in
            print(error.localizedDescription)
        }
    }
    
    func loadData() {
        if tweet?.retweeted == true {
            retweetButton.setImage(UIImage(named: "retweet_logo_green"), forState: UIControlState.Normal)
        } else {
            retweetButton.setImage(UIImage(named: "retweet_logo_gray"), forState: UIControlState.Normal)
        }
        
        if tweet?.favorited == true {
            favoriteButton.setImage(UIImage(named: "like_logo_red"), forState: UIControlState.Normal)
        } else {
            favoriteButton.setImage(UIImage(named: "like_logo_gray"), forState: UIControlState.Normal)
        }
        
        favoritesCountLabel.text = "\((tweet?.favoritesCount)!)"
        retweetsCountLabel.text = "\((tweet?.retweetCount)!)"
        
        tweetTextLabel.text = tweet?.text as? String
        usernameLabel.text = tweet?.user?.name as? String
        
        if let tweetTimestamp = tweet?.timestamp {
            
            let timeElapsed = Int(NSDate().timeIntervalSinceDate(tweetTimestamp))
            
            if timeElapsed >= 3600 {
                timestampLabel.text = "\((timeElapsed / 3600))"
                timestampUnitLabel.text = "h"
            } else if timeElapsed >= 60 {
                timestampLabel.text = "\((timeElapsed / 60))"
                timestampUnitLabel.text = "m"
            } else {
                timestampLabel.text = "\((timeElapsed / 1))"
                timestampUnitLabel.text = "s"
            }
            //print(timeElapsed)
        }
        
        if let tweetUserProfileImageUrl = tweet?.user?.profileUrl {
            if let imageData = NSData(contentsOfURL: tweetUserProfileImageUrl) {
                tweetUserProfileImage.image = UIImage(data: imageData)
            }
        }
        
        if let currentUserProfileImageUrl = User.currentUser?.profileUrl {
            if let imageData = NSData(contentsOfURL: currentUserProfileImageUrl) {
                currentUserProfileImage.image = UIImage(data: imageData)
            }
        }
    }
    
    func currentUserProfileImageTapped(profileImage: AnyObject) {
        self.performSegueWithIdentifier("DetailToCurrentUserProfileSegue", sender: nil)
    }
    
    func tweetUserProfileImageTapped(profileImage: AnyObject) {
        self.performSegueWithIdentifier("DetailToTweetUserProfileSegue", sender: nil)
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onRetweetButton(sender: AnyObject) {
        print("retweet button clicked")
        if tweet?.retweeted == true {
            print("unretweet")
            if let tweetId = tweet?.idString {
                TwitterClient.sharedInstance.unretweet(tweetId, success: { (result: Tweet) in
                    
                    dispatch_async(dispatch_get_main_queue()) {
                        self.tweet = result
                        self.loadData()
                        NSNotificationCenter.defaultCenter().postNotificationName(Tweet.unRetweetNotification, object: result)
                    }
                    
                }) { (error: NSError) in
                    print(error.localizedDescription)
                    print(error)
                }
            }
        } else {
            print("retweet")
            if let tweetId = tweet?.idString {
                TwitterClient.sharedInstance.retweet(tweetId, success: { (result: Tweet) in
                    
                    dispatch_async(dispatch_get_main_queue()) {
                        self.tweet = result
                        self.loadData()
                        print(self.tweet)
                        NSNotificationCenter.defaultCenter().postNotificationName(Tweet.retweetNotification, object: result)
                    }
                    
                }) { (error: NSError) in
                    print(error.localizedDescription)
                    print(error)
                }
            }
        }
    }
    
    @IBAction func onFavoriteButton(sender: AnyObject) {
        print("favorite button clicked")
        if tweet?.favorited == true {
            print("unfavorite")
            if let tweetId = tweet?.idString {
                TwitterClient.sharedInstance.unfavorite(tweetId, success: { (result: Tweet) in
                    
                    dispatch_async(dispatch_get_main_queue()) {
                        self.tweet = result
                        self.loadData()
                        NSNotificationCenter.defaultCenter().postNotificationName(Tweet.unFavoriteNotification, object: result)
                    }
                    
                }) { (error: NSError) in
                    print(error.localizedDescription)
                    print(error)
                }
            }
        } else {
            print("favorite")
            if let tweetId = tweet?.idString {
                TwitterClient.sharedInstance.favorite(tweetId, success: { (result: Tweet) in
                    
                    dispatch_async(dispatch_get_main_queue()) {
                        self.tweet = result
                        self.loadData()
                        NSNotificationCenter.defaultCenter().postNotificationName(Tweet.favoriteNotification, object: result)
                    }
                    
                }) { (error: NSError) in
                    print(error.localizedDescription)
                    print(error)
                }
            }
        }
        
    }
    
    @IBAction func onReplyButton(sender: AnyObject) {
        print("reply clicked")
        
        if let tweetUserScreenname = tweet?.user?.screenname as? String {
            print("tweetUserScreenname: \(tweetUserScreenname)")
            if let comment = replyTextField.text {
                let replyAsString = "@\(tweetUserScreenname) \(comment)"
                if let replyAsUrlString = replyAsString.stringByAddingPercentEncodingForRFC3986() {
                    print("replyAsUrlString: \(replyAsUrlString)")
                    if let tweetId = tweet?.idString {
                        print("tweetId: \(tweetId)")
                        
                        TwitterClient.sharedInstance.reply(replyAsUrlString, tweetIdString: tweetId, success: {
                            print("success-ish")
                            
                            NSNotificationCenter.defaultCenter().postNotificationName(User.userPostedReplyNotification, object: nil)
                            
                            }, failure: { (error: NSError) in
                                print(error.localizedDescription)
                        })
                    }
                }
            }
        }
        
        replyTextField.text = ""
    }
    
    //let replyUrlString = NSURL(string: reply)
    //print("replyUrlString: \(replyUrlString)")

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "DetailToCurrentUserProfileSegue" {
            let profileViewController = segue.destinationViewController as! ProfileViewController
            profileViewController.user = User.currentUser
            profileViewController.userIsCurrentUser = true
            profileViewController.comingFromSegue = true
        }
        if segue.identifier == "DetailToTweetUserProfileSegue" {
            let profileViewController = segue.destinationViewController as! ProfileViewController
            profileViewController.user = tweet?.user
            if tweet?.user == User.currentUser {
                profileViewController.userIsCurrentUser = true
            } else {
                profileViewController.userIsCurrentUser = false
            }
            profileViewController.comingFromSegue = true
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let replies = replies {
            return replies.count
        } else {
            return 0
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("TimelineTableViewCell", forIndexPath: indexPath) as! TimelineTableViewCell
        
        let reply = replies![indexPath.row]
        cell.tweet = reply
        cell.inDetailView = true
        
        return cell
    }

}

extension String {
    func stringByAddingPercentEncodingForRFC3986() -> String? {
        let unreserved = "-._~/?"
        let allowed = NSMutableCharacterSet.alphanumericCharacterSet()
        allowed.addCharactersInString(unreserved)
        return stringByAddingPercentEncodingWithAllowedCharacters(allowed)
    }
}
