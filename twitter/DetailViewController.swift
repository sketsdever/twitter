//
//  DetailViewController.swift
//  twitter
//
//  Created by Shea Ketsdever on 6/28/16.
//  Copyright © 2016 Shea Ketsdever. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {

    @IBOutlet weak var tweetUserProfileImage: UIImageView!
    @IBOutlet weak var currentUserProfileImage: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var timestampLabel: UILabel!
    @IBOutlet weak var timestampUnitLabel: UILabel!
    @IBOutlet weak var tweetTextLabel: UILabel!
    @IBOutlet weak var replyTextField: UITextField!
    @IBOutlet weak var retweetButton: UIButton!
    @IBOutlet weak var favoriteButton: UIButton!
    
    var tweet: Tweet?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadData()
        
        let currentUserProfileTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(currentUserProfileImageTapped))
        currentUserProfileImage.userInteractionEnabled = true
        currentUserProfileImage.addGestureRecognizer(currentUserProfileTapGestureRecognizer)
        
        let tweetUserProfileTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tweetUserProfileImageTapped))
        tweetUserProfileImage.userInteractionEnabled = true
        tweetUserProfileImage.addGestureRecognizer(tweetUserProfileTapGestureRecognizer)
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
            //retweetButton.setImage(UIImage(named: "retweet_logo_grey"), forState: UIControlState.Normal)
            if let tweetId = tweet?.idString {
                TwitterClient.sharedInstance.unretweet(tweetId, success: { (result: Tweet) in
                    
                    dispatch_async(dispatch_get_main_queue()) {
                        //self.tweet = result
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
            //retweetButton.setImage(UIImage(named: "retweet_logo_green"), forState: UIControlState.Normal)
            if let tweetId = tweet?.idString {
                TwitterClient.sharedInstance.retweet(tweetId, success: { (result: Tweet) in
                    
                    dispatch_async(dispatch_get_main_queue()) {
                        //self.tweet = result
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
            //favoriteButton.setImage(UIImage(named: "like_logo_gray"), forState: UIControlState.Normal)
            if let tweetId = tweet?.idString {
                TwitterClient.sharedInstance.favorite(tweetId, success: { (result: Tweet) in
                    
                    dispatch_async(dispatch_get_main_queue()) {
                        //self.tweet = result
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
            //favoriteButton.setImage(UIImage(named: "like_logo_red"), forState: UIControlState.Normal)
            if let tweetId = tweet?.idString {
                TwitterClient.sharedInstance.unfavorite(tweetId, success: { (result: Tweet) in
                    
                    dispatch_async(dispatch_get_main_queue()) {
                        //self.tweet = result
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
        }
        if segue.identifier == "DetailToTweetUserProfileSegue" {
            let profileViewController = segue.destinationViewController as! ProfileViewController
            profileViewController.user = tweet?.user
            if tweet?.user == User.currentUser {
                profileViewController.userIsCurrentUser = true
            } else {
                profileViewController.userIsCurrentUser = false
            }
        }
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
