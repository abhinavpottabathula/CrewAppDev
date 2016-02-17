//
//  PostCell.swift
//  Pic
//
//  Created by Shreyas Patankar on 2/7/16.
//  Copyright © 2016 Shreyas Patankar. All rights reserved.
//

import UIKit
import Parse

class PostCell: UITableViewCell {
    @IBOutlet weak var profilePicture: UIImageView!
    @IBOutlet weak var username: UIButton!
    @IBOutlet weak var timestamp: UILabel!

    @IBOutlet weak var picture: UIImageView!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var commentButton: UIButton!
    @IBOutlet weak var moreInfoButton: UIButton!
    
    @IBOutlet weak var likeTxt: UILabel!
    @IBOutlet weak var captionTxt: UILabel!
    @IBOutlet weak var uuidLbl: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        likeButton.setTitleColor(UIColor.clearColor(), forState: .Normal)
        
        // Initialization code
        let width = UIScreen.mainScreen().bounds.width
        
        /*
        let likeTap = UITapGestureRecognizer(target: self, action: "likeTap")
        likeTap.numberOfTapsRequired = 2
        picture.userInteractionEnabled = true
        picture.addGestureRecognizer(likeTap)
        */
        
        profilePicture.translatesAutoresizingMaskIntoConstraints = false
        username.translatesAutoresizingMaskIntoConstraints = false
        timestamp.translatesAutoresizingMaskIntoConstraints = false
        picture.translatesAutoresizingMaskIntoConstraints = false
        likeButton.translatesAutoresizingMaskIntoConstraints = false
        commentButton.translatesAutoresizingMaskIntoConstraints = false
        moreInfoButton.translatesAutoresizingMaskIntoConstraints = false
        likeTxt.translatesAutoresizingMaskIntoConstraints = false
        captionTxt.translatesAutoresizingMaskIntoConstraints = false
        uuidLbl.translatesAutoresizingMaskIntoConstraints = false
        
        let picWidth = width - 20
        
        //constraints
        
        
        //vertical constraints
        self.contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat(
            "V:|-5-[prof(30)]-10-[img(\(picWidth))]-0-[like(50)]",
            options: [], metrics: nil, views: ["prof":profilePicture, "img":picture, "like":likeButton]))
        
        self.contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat(
            "V:|-5-[username]",
            options: [], metrics: nil, views: ["username":username]))
        
        self.contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat(
            "V:[pic]-10-[comment(30)]",
            options: [], metrics: nil, views: ["pic":picture, "comment":commentButton]))
        
        self.contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat(
            "V:|-12-[timestamp]",
            options: [], metrics: nil, views: ["timestamp":timestamp]))
        
        self.contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat(
            "V:[like]-5-[caption]-5-|",
            options: [], metrics: nil, views: ["like":likeButton, "caption":captionTxt]))

        self.contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat(
            "V:[pic]-15-[more]",
            options: [], metrics: nil, views: ["pic":picture, "more":moreInfoButton]))
        
        self.contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat(
            "V:[pic]-15-[likes]",
            options: [], metrics: nil, views: ["pic":picture, "likes":likeTxt]))
        
        //horizontal constraints
        self.contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat(
            "H:|-10-[prof(30)]-10-[username]|",
            options: [], metrics: nil, views: ["prof":profilePicture, "username":username]))
        
        self.contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat(
            "H:|-10-[img]-10-|",
            options: [], metrics: nil, views: ["img":picture]))
        
        self.contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat(
            "H:|-15-[like(50)]-10-[likeLbl]-40-[comment(30)]",
            options: [], metrics: nil, views: ["like":likeButton, "likeLbl":likeTxt, "comment":commentButton]))
        
        self.contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat(
            "H:[more(37)]-15-|",
            options: [], metrics: nil, views: ["more":moreInfoButton]))
        
        self.contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat(
            "H:|-15-[caption]-15-|",
            options: [], metrics: nil, views: ["caption":captionTxt]))
        
        self.contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat(
            "H:|[timestamp]-10-|",
            options: [], metrics: nil, views: ["timestamp":timestamp]))
        
        //round profile image
        profilePicture.layer.cornerRadius = profilePicture.frame.size.width / 2
        profilePicture.clipsToBounds = true
    }
    
    func likeTap(){
        let likeImg = UIImageView(image: UIImage(named: "like_unselected.png"))
        likeImg.frame.size.width = picture.frame.size.width / 1.5
        likeImg.frame.size.height = picture.frame.size.height / 1.5
        likeImg.center = picture.center
        likeImg.alpha = 0.8
        self.addSubview(likeImg)
        
        picture.translatesAutoresizingMaskIntoConstraints = false
        
        let picWidth = picture.frame.size.width
        let picHeight = picture.frame.size.height
        
        UIView.animateWithDuration(0.4) { () -> Void in
            likeImg.alpha = 0
            likeImg.transform = CGAffineTransformMakeScale(0.1, 0.1)
            self.picture.frame.size.width = picWidth
            self.picture.frame.size.height = picHeight
        }
        
        let title = likeButton.titleForState(.Normal)
        
        if title == "unlike"{
            let object = PFObject(className: "likes")
            object["by"] = PFUser.currentUser()?.username
            object["to"] = uuidLbl.text
            object.saveInBackgroundWithBlock({ (success:Bool, error:NSError?) -> Void in
                if success {
                    print("liked")
                    self.likeButton.setTitle("like", forState: .Normal)
                    self.likeButton.setBackgroundImage(UIImage(named: "like_unselected.png"), forState: .Normal)
                    
                    let countLikes = PFQuery(className: "likes")
                    countLikes.whereKey("to", equalTo: self.uuidLbl.text!)
                    countLikes.countObjectsInBackgroundWithBlock { (count:Int32, error:NSError?) -> Void in
                        self.likeTxt.text = "\(count)"
                    }
                    
                    // send notification if we liked to refresh TableView
                    NSNotificationCenter.defaultCenter().postNotificationName("liked", object: nil)
                    
                }
            })
        }
        picture.translatesAutoresizingMaskIntoConstraints = false
        //awakeFromNib()
        self.picture.frame.size.width = picWidth
        self.picture.frame.size.height = picHeight
        self.picture.sizeToFit()
    }
    
    @IBAction func likeIsClicked(sender: AnyObject) {
        // declare title of button
        let title = sender.titleForState(.Normal)
        
        // to like
        if title == "unlike" {
            
            let object = PFObject(className: "likes")
            object["by"] = PFUser.currentUser()?.username
            object["to"] = uuidLbl.text
            object.saveInBackgroundWithBlock({ (success:Bool, error:NSError?) -> Void in
                if success {
                    print("liked")
                    self.likeButton.setTitle("like", forState: .Normal)
                    self.likeButton.setBackgroundImage(UIImage(named: "like_unselected.png"), forState: .Normal)
                    
                    let countLikes = PFQuery(className: "likes")
                    countLikes.whereKey("to", equalTo: self.uuidLbl.text!)
                    countLikes.countObjectsInBackgroundWithBlock { (count:Int32, error:NSError?) -> Void in
                        self.likeTxt.text = "\(count)"
                    }
                    
                    // send notification if we liked to refresh TableView
                    NSNotificationCenter.defaultCenter().postNotificationName("liked", object: nil)
                    
                }
            })
            
            // to dislike
        } else {
            
            // request existing likes of current user to show post
            let query = PFQuery(className: "likes")
            query.whereKey("by", equalTo: PFUser.currentUser()!.username!)
            query.whereKey("to", equalTo: uuidLbl.text!)
            query.findObjectsInBackgroundWithBlock({ (objects:[PFObject]?, error:NSError?) -> Void in
                
                // find objects - likes
                for object in objects! {
                    
                    // delete found like(s)
                    object.deleteInBackgroundWithBlock({ (success:Bool, error:NSError?) -> Void in
                        if success {
                            print("disliked")
                            self.likeButton.setTitle("unlike", forState: .Normal)
                            self.likeButton.setBackgroundImage(UIImage(named: "like_selected.png"), forState: .Normal)
                            
                            let countLikes = PFQuery(className: "likes")
                            countLikes.whereKey("to", equalTo: self.uuidLbl.text!)
                            countLikes.countObjectsInBackgroundWithBlock { (count:Int32, error:NSError?) -> Void in
                                self.likeTxt.text = "\(count)"
                            }
                            
                            // send notification if we liked to refresh TableView
                            NSNotificationCenter.defaultCenter().postNotificationName("liked", object: nil)
                            
                        }
                    })
                }
            })
        }
    }
}
