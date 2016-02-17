//
//  GuestViewController.swift
//  Pic
//
//  Created by Shreyas Patankar on 2/5/16.
//  Copyright © 2016 Shreyas Patankar. All rights reserved.
//

import UIKit
import Parse

/*
    TODO Fix glitchy load screen
*/

var guestName = [String]()

class GuestViewController: UICollectionViewController {

    var refresher : UIRefreshControl!
    
    //num Posts per page
    var postsPerPage: Int = 12
    
    var uuids = [String]()
    var pics = [PFFile]()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //set background color
        self.collectionView?.backgroundColor = .whiteColor()
        
        //refresh enabled
        self.collectionView!.alwaysBounceVertical = true
        
        //create refresh capabilities
        refresher = UIRefreshControl()
        refresher.addTarget(self, action: "refresh", forControlEvents: UIControlEvents.ValueChanged)
        collectionView?.addSubview(refresher)
        
        //page title
        self.navigationItem.title = guestName.last
        
        //back button
        /*
        self.navigationItem.hidesBackButton = true
        let moveBack = UIBarButtonItem(title: "back", style: UIBarButtonItemStyle.Plain, target: self, action: "back:")
        self.navigationItem.leftBarButtonItem = moveBack
        
        //alternative back method
        let moveBackWithSwipe = UISwipeGestureRecognizer(target: self, action: "back:")
        moveBackWithSwipe.direction = UISwipeGestureRecognizerDirection.Right
        self.view.addGestureRecognizer(moveBackWithSwipe)
        */
        loadPosts()
    }
    
    //configure the header
    override func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        print("Home Loaded!")
        
        //get the header object
        let header = collectionView.dequeueReusableSupplementaryViewOfKind(UICollectionElementKindSectionHeader, withReuseIdentifier: "Header", forIndexPath: indexPath) as! HeaderView
        
        let myQry = PFUser.query()
        myQry?.whereKey("username", equalTo: guestName.last!)
        myQry!.findObjectsInBackgroundWithBlock ({ (objects:[PFObject]?, error:NSError?) -> Void in
            if error == nil{
                
                if objects!.isEmpty{
                    print("wrong user")
                }
                //find relevant posts
                for object in objects! {
                    header.name.text = (object.objectForKey("actualName") as? String)?.uppercaseString
                    header.bio.text = object.objectForKey("bio") as? String
                    header.bio.sizeToFit()
                    
                    let profileQry = object.objectForKey("profilePicture") as! PFFile
                    profileQry.getDataInBackgroundWithBlock{ (data:NSData?, error:NSError?) -> Void in
                        header.profilePicture.image = UIImage(data: data!)
                        
                    }
                }
                
                self.collectionView?.reloadData()
            }
        })
        
        
        //Apply following query
        let flwingQry = PFQuery(className: "follow")
        flwingQry.whereKey("follower", equalTo: (PFUser.currentUser()!.username)!)
        flwingQry.whereKey("following", equalTo: guestName.last!)
        flwingQry.countObjectsInBackgroundWithBlock({(count:Int32, error:NSError?) -> Void in
            if error == nil{
                if count == 0{
                    //EDIT PROFILE BUTTON = FOLLOW BUTTON FOR GUEST VIEW
                    header.editProfileButton.setTitle("FOLLOW", forState:.Normal)
                    header.editProfileButton.backgroundColor = .lightGrayColor()
                }else{
                    header.editProfileButton.setTitle("FOLLOWING", forState:.Normal)
                    header.editProfileButton.backgroundColor = UIColor(red: 46.0/255.0, green: 204.0/255.0, blue: 113.0/255, alpha: 1)
                }
            }
        })
        
        //Count num posts
        let postQry = PFQuery(className: "Posts")
        postQry.whereKey("username", equalTo: guestName.last!)
        postQry.countObjectsInBackgroundWithBlock({(count:Int32, error:NSError?) -> Void in
            if error == nil{
                header.numPosts.text = "\(count)"
            }
        })
        
        //Count num followers
        let flwQry = PFQuery(className: "follow")
        flwQry.whereKey("following", equalTo: guestName.last!)
        flwQry.countObjectsInBackgroundWithBlock({(count:Int32, error:NSError?) -> Void in
            if error == nil{
                header.numFollowers.text = "\(count)"
            }
        })
        
        //count the number following
        let flwingQry2 = PFQuery(className: "follow")
        flwingQry2.whereKey("follower", equalTo: guestName.last!)
        flwingQry2.countObjectsInBackgroundWithBlock({(count:Int32, error:NSError?) -> Void in
            if error == nil{
                header.numFollowing.text = "\(count)"
            }
        })

        //tap responsiveness
        
        //posts
        let pClick = UITapGestureRecognizer(target: self, action: "postsClicked")
        pClick.numberOfTapsRequired = 1
        header.numPosts.userInteractionEnabled = true
        header.numPosts.addGestureRecognizer(pClick)
        
        //followers
        let flwClick = UITapGestureRecognizer(target: self, action: "followersClicked")
        flwClick.numberOfTapsRequired = 1
        header.numFollowers.userInteractionEnabled = true
        header.numFollowers.addGestureRecognizer(flwClick)
        
        //following
        let flwingClick = UITapGestureRecognizer(target: self, action: "followingClicked")
        flwingClick.numberOfTapsRequired = 1
        header.numFollowing.userInteractionEnabled = true
        header.numFollowing.addGestureRecognizer(flwingClick)
        
        return header
    }
    
    //if the post header is tapped do this...
    func postsClicked(){
        if !pics.isEmpty{
            let i = NSIndexPath(forItem: 0, inSection: 0)
            self.collectionView?.scrollToItemAtIndexPath(i, atScrollPosition: UICollectionViewScrollPosition.Top, animated: true)
        }
    }
    
    //if the followers number is pressed do this...
    func followersClicked(){
        user = guestName.last!
        show = "Followers"
        
        let flwrs = self.storyboard?.instantiateViewControllerWithIdentifier("FollowersViewController") as! FollowersViewController
        self.navigationController?.pushViewController(flwrs, animated: true)
    }
    
    //if the following number is pressed do this...
    func followingClicked(){
        user = guestName.last!
        show = "Followings"
        
        let flwings = self.storyboard?.instantiateViewControllerWithIdentifier("FollowersViewController") as! FollowersViewController
        self.navigationController?.pushViewController(flwings, animated: true)
    }

    
    //refresh page
    func refresh(){
        collectionView?.reloadData()
        refresher.endRefreshing()
    }
    
    //get new posts if at bottom
    override func scrollViewDidScroll(scrollView: UIScrollView) {
        if scrollView.contentOffset.y >= scrollView.contentSize.height - self.view.frame.size.height{
            self.loadMore()
        }
    }
    
    //pagination
    func loadMore(){
        if(postsPerPage <= pics.count){
            postsPerPage += 12
            
            let postsQry = PFQuery(className: "Posts")
            postsQry.whereKey("username", equalTo: guestName.last!)
            postsQry.limit = postsPerPage
            
            postsQry.findObjectsInBackgroundWithBlock ({ (objects:[PFObject]?, error:NSError?) -> Void in
                if error == nil{
                    
                    //clean old posts out
                    self.uuids.removeAll(keepCapacity: false)
                    self.pics.removeAll(keepCapacity: false)
                    
                    //find relevant posts
                    for object in objects! {
                        self.uuids.append(object.valueForKey("uuid") as! String)
                        self.pics.append(object.valueForKey("image") as! PFFile)
                    }
                    
                    
                }
            })
            self.collectionView?.reloadData()
        }
    }

    
    
    func loadPosts(){
        let query = PFQuery(className: "Posts")
        query.whereKey("username", equalTo: guestName.last!)
        query.limit = postsPerPage
        query.findObjectsInBackgroundWithBlock ({ (objects:[PFObject]?, error:NSError?) -> Void in
            if error == nil{
                
                //clean old posts out
                self.uuids.removeAll(keepCapacity: false)
                self.pics.removeAll(keepCapacity: false)
                
                //find relevant posts
                for object in objects! {
                    self.uuids.append(object.valueForKey("uuid") as! String)
                    self.pics.append(object.valueForKey("image") as! PFFile)
                }
                
                
            }
        })
        self.collectionView?.reloadData()
    }
    
    //how many posts to load
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return pics.count
    }
    
    //configure a cell
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("Cell", forIndexPath: indexPath) as! ImageArea
        
        pics[indexPath.row].getDataInBackgroundWithBlock{(data: NSData?, error:NSError?) -> Void in
            if error == nil{
                cell.image.image = UIImage(data: data!)
                
            }
        }
        return cell
    }
    
    //move back to previous page
    func back(sender:UIBarButtonItem){
        if !guestName.isEmpty{
            guestName.removeLast()
        }
        self.navigationController?.popViewControllerAnimated(true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        postuuid.append(uuids[indexPath.row])
        
        let myPost = self.storyboard?.instantiateViewControllerWithIdentifier("PostViewController") as! PostViewController
        self.navigationController?.pushViewController(myPost, animated: true)
    }
}
