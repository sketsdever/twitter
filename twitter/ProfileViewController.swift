//
//  ProfileViewController.swift
//  twitter
//
//  Created by Shea Ketsdever on 6/29/16.
//  Copyright © 2016 Shea Ketsdever. All rights reserved.
//

import UIKit

class ProfileViewController: UIViewController {

    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var tweetsLabel: UILabel!
    @IBOutlet weak var followingLabel: UILabel!
    @IBOutlet weak var followersLabel: UILabel!
    @IBOutlet weak var likesLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var screennameLabel: UILabel!
    @IBOutlet weak var taglineLabel: UILabel!
    
    var user: User?
    var userIsCurrentUser: Bool?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
        
        usernameLabel.text = user?.name as? String
        taglineLabel.text = user?.tagline as? String
        if let screenname = user?.screenname as? String {
            screennameLabel.text = "@\(screenname)"
        }
        
        if let url = user?.profileUrl {
            if let imageData = NSData(contentsOfURL: url) {
                profileImageView.image = UIImage(data: imageData)
            }
        }

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
