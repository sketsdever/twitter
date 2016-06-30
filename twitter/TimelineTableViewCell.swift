//
//  TimelineTableViewCell.swift
//  twitter
//
//  Created by Shea Ketsdever on 6/27/16.
//  Copyright © 2016 Shea Ketsdever. All rights reserved.
//

import UIKit

class TimelineTableViewCell: UITableViewCell {
    
    @IBOutlet weak var tweetTextLabel: UILabel!
    @IBOutlet weak var timestampLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var timestampUnitLabel: UILabel!
    @IBOutlet weak var favoriteButton: UIButton!
    @IBOutlet weak var retweetButton: UIButton!
    
    static let profileImageTappedNotification = "ProfileImageTappedNotification"
    
    var tweet: Tweet? {
        didSet {
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
            
            if let url = tweet?.user?.profileUrl {
                if let imageData = NSData(contentsOfURL: url) {
                    profileImage.image = UIImage(data: imageData)
                }
            }
            
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
        }
    }
    
    @IBAction func onRetweetButton(sender: AnyObject) {
        print("retweet button clicked")
        if tweet?.retweeted == true {
            print("unretweet")
            retweetButton.setImage(UIImage(named: "retweet_logo_grey"), forState: UIControlState.Normal)
            if let tweetId = tweet?.idString {
                TwitterClient.sharedInstance.unretweet(tweetId, success: { (result: Tweet) in
                    
                    dispatch_async(dispatch_get_main_queue()) {
                        //self.tweet = result
                        NSNotificationCenter.defaultCenter().postNotificationName(Tweet.unRetweetNotification, object: result)
                    }
                    
                }) { (error: NSError) in
                    print(error.localizedDescription)
                    print(error)
                }
            }
        } else {
            print("retweet")
            retweetButton.setImage(UIImage(named: "retweet_logo_green"), forState: UIControlState.Normal)
            if let tweetId = tweet?.idString {
                TwitterClient.sharedInstance.retweet(tweetId, success: { (result: Tweet) in
                    
                    dispatch_async(dispatch_get_main_queue()) {
                        //self.tweet = result
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
            favoriteButton.setImage(UIImage(named: "like_logo_gray"), forState: UIControlState.Normal)
            if let tweetId = tweet?.idString {
                TwitterClient.sharedInstance.favorite(tweetId, success: { (result: Tweet) in
                    
                    dispatch_async(dispatch_get_main_queue()) {
                        //self.tweet = result
                        NSNotificationCenter.defaultCenter().postNotificationName(Tweet.unFavoriteNotification, object: result)
                    }
                    
                }) { (error: NSError) in
                    print(error.localizedDescription)
                    print(error)
                }
            }
        } else {
            print("favorite")
            favoriteButton.setImage(UIImage(named: "like_logo_red"), forState: UIControlState.Normal)
            if let tweetId = tweet?.idString {
                TwitterClient.sharedInstance.unfavorite(tweetId, success: { (result: Tweet) in
                    
                    dispatch_async(dispatch_get_main_queue()) {
                        //self.tweet = result
                        NSNotificationCenter.defaultCenter().postNotificationName(Tweet.favoriteNotification, object: result)
                    }
                    
                }) { (error: NSError) in
                    print(error.localizedDescription)
                    print(error)
                }
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let profileImageTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(profileImageTapped))
        profileImage.userInteractionEnabled = true
        profileImage.addGestureRecognizer(profileImageTapGestureRecognizer)
        
    }
    
    func profileImageTapped(image: AnyObject) {
        NSNotificationCenter.defaultCenter().postNotificationName(TimelineTableViewCell.profileImageTappedNotification, object: tweet?.user)
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
