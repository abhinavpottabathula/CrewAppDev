//
//  FollowersItems.swift
//  Pic
//
//  Created by Shreyas Patankar on 2/5/16.
//  Copyright © 2016 Shreyas Patankar. All rights reserved.
//

import UIKit
import Parse

class FollowersItems: UITableViewCell {
    //properties of TableViewCell
    @IBOutlet weak var profilePicture: UIImageView!
    @IBOutlet weak var followButton: UIButton!
    @IBOutlet weak var username: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        //circular profile
        profilePicture.layer.cornerRadius = profilePicture.frame.size.width / 2
        profilePicture.clipsToBounds = true
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func flwButtonIsClicked(sender: AnyObject) {
        let flwTitle = followButton.titleForState(.Normal)
        
        
        //follow new user
        if(flwTitle == "Follow"){
            let flwObj = PFObject(className: "follow")
            flwObj["follower"] = PFUser.currentUser()?.username
            flwObj["following"] = username.text
            flwObj.saveInBackgroundWithBlock({ (success:Bool, error:NSError?) -> Void in
                if success {
                    self.followButton.setTitle("Following", forState: UIControlState.Normal)
                    self.followButton.backgroundColor = UIColor(red: 46.0/255.0, green: 204.0/255.0, blue: 113.0/255, alpha: 1) //.greenColor
                }
            })
        }else{
            //unfollow user
            let myQuery = PFQuery(className: "follow")
            myQuery.whereKey("follower", equalTo: PFUser.currentUser()!.username!)
            myQuery.whereKey("following", equalTo: username.text!)
            myQuery.findObjectsInBackgroundWithBlock({ (objects:[PFObject]?, error:NSError?) -> Void in
                if error == nil{
                    for object in objects!{
                        object.deleteInBackgroundWithBlock({ (success:Bool, error:NSError?) -> Void in
                            if success{
                                self.followButton.setTitle("Follow", forState: UIControlState.Normal)
                                self.followButton.backgroundColor = .lightGrayColor()
                            }
                        })
                    }
                }
            })

        }
    }
}
