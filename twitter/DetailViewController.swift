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
    
    var tweet: Tweet?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onRetweetButton(sender: AnyObject) {
        if let tweetId = tweet?.idString {
            TwitterClient.sharedInstance.retweet(tweetId, success: { (result: Tweet) in
                
                dispatch_async(dispatch_get_main_queue()) {
                    self.tweet = result
                    NSNotificationCenter.defaultCenter().postNotificationName(Tweet.retweetNotification, object: result)
                }
                
            }) { (error: NSError) in
                print(error.localizedDescription)
                print(error)
            }
        }
    }
    
    @IBAction func onFavoriteButton(sender: AnyObject) {
        if let tweetId = tweet?.idString {
            TwitterClient.sharedInstance.favorite(tweetId, success: { (result: Tweet) in
                
                dispatch_async(dispatch_get_main_queue()) {
                    self.tweet = result
                    NSNotificationCenter.defaultCenter().postNotificationName(Tweet.favoriteNotification, object: result)
                }
                
            }) { (error: NSError) in
                print(error.localizedDescription)
                print(error)
            }
        }
    }
    
    
    @IBAction func onReplyButton(sender: AnyObject) {
        
        let reply = replyTextField.text
        if let reply = reply {
            if let tweetId = tweet?.idString {
                TwitterClient.sharedInstance.reply(reply, tweetIdString: tweetId, success: {
                    print("success-ish")
                    }, failure: { (error: NSError) in
                        print(error.localizedDescription)
                })
            }
        }
        replyTextField.text = ""
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
