//
//  HeaderView.swift
//  Pic
//
//  Created by Shreyas Patankar on 2/5/16.
//  Copyright © 2016 Shreyas Patankar. All rights reserved.
//

import UIKit
import Parse

class HeaderView: UICollectionReusableView {
    //Basic User Information
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var profilePicture: UIImageView!
    
    //Edit Profile Button
    @IBOutlet weak var editProfileButton: UIButton!
    
    //Text below numbers
    @IBOutlet weak var followingTxt: UILabel!
    @IBOutlet weak var followersTxt: UILabel!
    @IBOutlet weak var postsTxt: UILabel!
    
    //Number followers, following, posts
    @IBOutlet weak var numFollowing: UILabel!
    @IBOutlet weak var numFollowers: UILabel!
    @IBOutlet weak var numPosts: UILabel!
    
    //biography
    @IBOutlet weak var bio: UILabel!
    
    @IBAction func followIsClicked(sender: AnyObject) {
        let flwTitle = editProfileButton.titleForState(.Normal)
        
        
        //follow new user
        if(flwTitle == "Follow"){
            let flwObj = PFObject(className: "follow")
            flwObj["follower"] = PFUser.currentUser()?.username
            flwObj["following"] = guestName.last!
            flwObj.saveInBackgroundWithBlock({ (success:Bool, error:NSError?) -> Void in
                if success {
                    self.editProfileButton.setTitle("Following", forState: UIControlState.Normal)
                    self.editProfileButton.backgroundColor = .greenColor()
                }
            })
        }else{
            //unfollow user
            let myQuery = PFQuery(className: "follow")
            myQuery.whereKey("follower", equalTo: PFUser.currentUser()!.username!)
            myQuery.whereKey("following", equalTo: guestName.last!)
            myQuery.findObjectsInBackgroundWithBlock({ (objects:[PFObject]?, error:NSError?) -> Void in
                if error == nil{
                    for object in objects!{
                        object.deleteInBackgroundWithBlock({ (success:Bool, error:NSError?) -> Void in
                            if success{
                                self.editProfileButton.setTitle("Follow", forState: UIControlState.Normal)
                                self.editProfileButton.backgroundColor = .lightGrayColor()
                            }
                        })
                    }
                }
            })
            
        }

    }
    
}

