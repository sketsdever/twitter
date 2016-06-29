//
//  TwitterClient.swift
//  twitter
//
//  Created by Shea Ketsdever on 6/27/16.
//  Copyright © 2016 Shea Ketsdever. All rights reserved.
//

import UIKit
import BDBOAuth1Manager

class TwitterClient: BDBOAuth1SessionManager {
    
    static let sharedInstance = TwitterClient(baseURL: NSURL(string: "https://api.twitter.com")!, consumerKey: "qxjzdQyL7N7Z4CPvU5gZzjbSB", consumerSecret: "vcs0gOrmbxKwDbMjvFxasMt5XwJ9z1yGL2cAovWZC4fJUbTMA6")
    
    var loginSuccess: (() -> ())?
    var loginFailure: ((NSError) -> ())?
    
    func login(success: () -> (), failure: (NSError) -> ()) {
        
        loginSuccess = success
        loginFailure = failure
        
        TwitterClient.sharedInstance.deauthorize()
        TwitterClient.sharedInstance.fetchRequestTokenWithPath("oauth/request_token", method: "GET", callbackURL: NSURL(string: "twitterclient://oauth"), scope: nil, success: { (requestToken: BDBOAuth1Credential!) in
            print("I got a token!")
            
            let url = NSURL(string: "https://api.twitter.com/oauth/authorize?oauth_token=\(requestToken.token)")!
            UIApplication.sharedApplication().openURL(url)
            
        }) { (error: NSError!) in
            self.loginFailure?(error)
            print("error: \(error.localizedDescription)")
        }
    }
    
    func handleOpenUrl(url: NSURL) {
        let requestToken = BDBOAuth1Credential(queryString: url.query)
        fetchAccessTokenWithPath("oauth/access_token", method: "POST", requestToken: requestToken, success: { (accessToken: BDBOAuth1Credential!) in
            
            self.currentAccount({ (user: User) in
                User.currentUser = user
                self.loginSuccess?()
                }, failure: { (error: NSError) in
                    self.loginFailure?(error)
            })
        
        }) { (error: NSError!) in
            self.loginFailure?(error)
        }
    }
    
    func currentAccount(success: (User) -> (), failure: (NSError) -> ()) {
        GET("1.1/account/verify_credentials.json", parameters: nil, progress: nil, success: { (task: NSURLSessionDataTask, response: AnyObject?) in
            
            let userDictionary = response as! NSDictionary
            let user = User(dictionary: userDictionary)
            
            success(user)
            
            print("name: \(user.name!)")
            print("screen name: \(user.screenname!)")
            print("profile url: \(user.profileUrl!)")
            print("tagline: \(user.tagline!)")
            
        }, failure: { (task:NSURLSessionDataTask?, error: NSError) -> Void in
            failure(error)
        })
    }
    
    func homeTimeline(success: ([Tweet]) -> (), failure: (NSError) -> ()) {
        GET("1.1/statuses/home_timeline.json", parameters: nil, progress: nil, success: { (task: NSURLSessionDataTask, response: AnyObject?) -> Void in
            
            let dictionaries = response as! [NSDictionary]
            let tweets = Tweet.tweetsWithArray(dictionaries)
            success(tweets)
            
            }, failure: { (task: NSURLSessionDataTask?, error: NSError) -> Void in
                failure(error)
        })
    }
    
    func retweet(idString: String, success: (Tweet) -> (), failure: (NSError) -> ()) {
        //self.printRateStatus()
        
        POST("1.1/statuses/retweet/\(idString).json", parameters: nil, progress: nil, success: { (task: NSURLSessionDataTask, response: AnyObject?) -> Void in
            
            let tweetDictionary = response as! NSDictionary
            let tweet = Tweet(dictionary: tweetDictionary)
            success(tweet)
            
            }, failure: { (task: NSURLSessionDataTask?, error: NSError) -> Void in
                failure(error)
        })
    }
    
    func favorite(idString: String, success: (Tweet) -> (), failure: (NSError) -> ()) {
        //self.printRateStatus()
        
        POST("1.1/favorites/create.json?id=\(idString)", parameters: nil, progress: nil, success: { (task: NSURLSessionDataTask, response: AnyObject?) -> Void in
            
            let tweetDictionary = response as! NSDictionary
            let tweet = Tweet(dictionary: tweetDictionary)
            success(tweet)
            
            }, failure: { (task: NSURLSessionDataTask?, error: NSError) -> Void in
                failure(error)
        })
    }
    
    func reply(reply: String, tweetIdString: String, success: () -> (), failure: (NSError) -> ()) {
        POST("statuses/update.json?status=\(reply)+?in_reply_to_status_id=\(tweetIdString)", parameters: nil, progress: nil, success: { (task: NSURLSessionDataTask, response: AnyObject?) -> Void in
            
            //let responseDictionary = response as! NSDictionary
            success()
            
            }, failure: { (task: NSURLSessionDataTask?, error: NSError) -> Void in
                failure(error)
        })
    }

    
    func logout() {
        User.currentUser = nil
        deauthorize()
        
        NSNotificationCenter.defaultCenter().postNotificationName(User.userDidLogOutNotification, object: nil)
    }
    
    /*// In the Twitter Client add...
    func getRateStatuses(handler: ((response: AnyObject?, error: NSError?) -> Void)) {
        GET("1.1/application/rate_limit_status.json?resources=statuses", parameters:nil, progress:nil,
                     success: { (task: NSURLSessionDataTask, response: AnyObject?) -> Void in
                        handler(response: response, error:nil)
            }, failure: { (task: NSURLSessionDataTask?, error: NSError) -> Void in
                print("error getting rate statuses: \(error)")
                handler(response:nil, error: error)
        })
    }
    
    // And then to print out the rate status information at any point in time, just call:
    private static let ratePrintLabels = [
        "/statuses/home_timeline":"home timeline",
        "/statuses/retweets/:id":"retweet",
        "/statuses/user_timeline":"user timeline"]
    
    func printRateStatus() {
        // print rate status
        TwitterClient.sharedInstance.getRateStatuses() { (json: AnyObject?, error: NSError?) -> Void in
            if error == nil, let json = json as? NSDictionary {
                for (key,value) in TwitterClient.ratePrintLabels {
                    if let dict = json["resources"]?["statuses"]?![key] {
                        let limit = dict!["limit"] as! Int
                        let remaining = dict!["remaining"] as! Int
                        let epoch = dict!["reset"] as! Int
                        let resetDate = NSDate(timeIntervalSince1970: Double(epoch))
                        print("\(value) rate: limit=\(limit), remaining=\(remaining);")
                            //expires in \(TwitterClient.formatIntervalElapsed(resetDate.timeIntervalSinceNow))")
                    }
                }
            }else{
                print("error getting rate status: \(error)")
            }
        }
    }*/
    
}
