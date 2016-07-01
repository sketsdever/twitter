//
//  ProfileViewController.swift
//  twitter
//
//  Created by Shea Ketsdever on 6/29/16.
//  Copyright © 2016 Shea Ketsdever. All rights reserved.
//

import UIKit

class ProfileViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var bannerImageView: UIImageView!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var tweetsLabel: UILabel!
    @IBOutlet weak var followingLabel: UILabel!
    @IBOutlet weak var followersLabel: UILabel!
    @IBOutlet weak var likesLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var screennameLabel: UILabel!
    @IBOutlet weak var taglineLabel: UILabel!
    
    @IBOutlet weak var tableView: UITableView!
    
    var comingFromSegue: Bool = false
    var user: User?
    var userIsCurrentUser: Bool?
    var tweets: [Tweet]!
    var tappedUser: User?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if comingFromSegue == false {
            user = User.currentUser
            userIsCurrentUser = true
        }
        
        tableView.delegate = self
        tableView.dataSource = self
        
        loadTweets()
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshControlAction), forControlEvents: UIControlEvents.ValueChanged)
        tableView.insertSubview(refreshControl, atIndex: 0)
        
        
        if userIsCurrentUser == true {
            print("user is current user")
        } else {
            print("user is guest user")
        }
        
        if let tweetsCount = user?.tweetsCount {
            if tweetsCount >= 1000000000 {
                tweetsLabel.text = "\((tweetsCount / 1000000000))B"
            } else if tweetsCount >= 1000000 {
                tweetsLabel.text = "\((tweetsCount / 1000000))M"
            } else if tweetsCount >= 1000 {
                tweetsLabel.text = "\((tweetsCount / 1000))K"
            } else {
                tweetsLabel.text = "\(tweetsCount)"
            }
            
        }
        tweetsLabel.sizeToFit()
        
        if let followingCount = user?.followingCount {
            if followingCount >= 1000000000 {
                followingLabel.text = "\((followingCount / 1000000000))B"
            } else if followingCount >= 1000000 {
                followingLabel.text = "\((followingCount / 1000000))M"
            } else if followingCount >= 1000 {
                followingLabel.text = "\((followingCount / 1000))K"
            } else {
                followingLabel.text = "\(followingCount)"
            }
        }
        followingLabel.sizeToFit()
        
        if let followersCount = user?.followersCount {
            if followersCount >= 1000000000 {
                followersLabel.text = "\((followersCount / 1000000000))B"
            } else if followersCount >= 1000000 {
                followersLabel.text = "\((followersCount / 1000000))M"
            } else if followersCount >= 1000 {
                followersLabel.text = "\((followersCount / 1000))K"
            } else {
                followersLabel.text = "\(followersCount)"
            }
        }
        followersLabel.sizeToFit()
        
        if let likesCount = user?.likesCount {
            if likesCount >= 1000000000 {
                likesLabel.text = "\((likesCount / 1000000000))B"
            } else if likesCount >= 1000000 {
                likesLabel.text = "\((likesCount / 1000000))M"
            } else if likesCount >= 1000 {
                likesLabel.text = "\((likesCount / 1000))K"
            } else {
                likesLabel.text = "\(likesCount)"
            }
        }
        likesLabel.sizeToFit()
        
        usernameLabel.text = user?.name as? String
        usernameLabel.sizeToFit()
        taglineLabel.text = user?.tagline as? String
        taglineLabel.sizeToFit()
        if let screenname = user?.screenname as? String {
            screennameLabel.text = "@\(screenname)"
            screennameLabel.sizeToFit()
        }
        
        if let url = user?.profileUrl {
            if let imageData = NSData(contentsOfURL: url) {
                profileImageView.image = UIImage(data: imageData)
            }
        }
        
        if let url2 = user?.bannerUrl {
            if let imageData = NSData(contentsOfURL: url2) {
                bannerImageView.image = UIImage(data: imageData)
            }
        }


        // Do any additional setup after loading the view.
    }
    
    func refreshControlAction(refreshControl: UIRefreshControl) {
        loadTweets()
        refreshControl.endRefreshing()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
