//
//  HomeViewController.swift
//  Pic
//
//  Created by Shreyas Patankar on 2/5/16.
//  Copyright © 2016 Shreyas Patankar. All rights reserved.
//

import UIKit
import Parse

class HomeViewController: UICollectionViewController {

    var refresher : UIRefreshControl!
    
    //num Posts per page
    var postsPerPage: Int = 12
    
    var uuids = [String]()
    var pics = [PFFile]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.collectionView?.alwaysBounceVertical = true
        
        collectionView?.backgroundColor = .whiteColor()
        self.navigationItem.title = PFUser.currentUser()?.username?.uppercaseString
        
        //refresh the page
        refresher = UIRefreshControl()
        refresher.addTarget(self, action: "refresh", forControlEvents: UIControlEvents.ValueChanged)
        collectionView?.addSubview(refresher)
        
        //recieve update from uploadViewCntrlr
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "uploaded:", name: "uploaded", object: nil)
        
        loadPosts()
        self.refresh()
    }
    
    func uploaded(notif:NSNotification){
        loadPosts()
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
            postsQry.whereKey("username", equalTo: PFUser.currentUser()!.username!)
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
                    
                    self.collectionView?.reloadData()
                }
            })
        }
    }
    
    //load the user's posts
    func loadPosts(){
        let query = PFQuery(className: "Posts")
        query.whereKey("username", equalTo: (PFUser.currentUser()?.username)!)
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
                
                self.collectionView?.reloadData()
            }
        })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    override func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        print("Home Loaded!")
        
        //get the header object
        let header = collectionView.dequeueReusableSupplementaryViewOfKind(UICollectionElementKindSectionHeader, withReuseIdentifier: "Header", forIndexPath: indexPath) as! HeaderView
        
        header.name.text = (PFUser.currentUser()?.objectForKey("username") as? String)?.uppercaseString
        header.bio.text = (PFUser.currentUser()?.objectForKey("bio") as? String)
        header.bio.sizeToFit()
        header.editProfileButton.setTitle("Edit Profile...", forState: UIControlState.Normal)
        
        //get the profile image data
        let profileQry = PFUser.currentUser()?.objectForKey("profilePicture") as! PFFile
        profileQry.getDataInBackgroundWithBlock{ (data:NSData?, error:NSError?) -> Void in
            header.profilePicture.image = UIImage(data: data!)
            header.profilePicture.layer.cornerRadius = header.profilePicture.frame.size.width / 2
            header.profilePicture.clipsToBounds = true
            
        }
        
        //count num posts
        let postQry = PFQuery(className: "Posts")
        postQry.whereKey("username", equalTo: (PFUser.currentUser()!.username)!)
        postQry.countObjectsInBackgroundWithBlock({(count:Int32, error:NSError?) -> Void in
            if error == nil{
                header.numPosts.text = "\(count)"
            }
        })
        
        //count the number of followers
        let flwQry = PFQuery(className: "follow")
        flwQry.whereKey("following", equalTo: (PFUser.currentUser()!.username)!)
        flwQry.countObjectsInBackgroundWithBlock({(count:Int32, error:NSError?) -> Void in
            if error == nil{
                header.numFollowers.text = "\(count)"
            }
        })
        
        //count the number following
        let flwingQry = PFQuery(className: "follow")
        flwingQry.whereKey("follower", equalTo: (PFUser.currentUser()!.username)!)
        flwingQry.countObjectsInBackgroundWithBlock({(count:Int32, error:NSError?) -> Void in
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
        user = (PFUser.currentUser()?.username)!
        show = "Followers"
        
        self.refresher.enabled = false
        
        let flwrs = self.storyboard?.instantiateViewControllerWithIdentifier("FollowersViewController") as! FollowersViewController
        self.navigationController?.pushViewController(flwrs, animated: true)
    }
    
    //if the following number is pressed do this...
    func followingClicked(){
        user = (PFUser.currentUser()?.username)!
        show = "Followings"
        
        self.refresher.enabled = false
        
        let flwings = self.storyboard?.instantiateViewControllerWithIdentifier("FollowersViewController") as! FollowersViewController
        self.navigationController?.pushViewController(flwings, animated: true)
    }

    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("Cell", forIndexPath: indexPath) as! ImageArea
        
        pics[indexPath.row].getDataInBackgroundWithBlock{(data: NSData?, error:NSError?) -> Void in
            if error == nil{
                cell.image.image = UIImage(data: data!)
                
            }
        }
        return cell
    }
    
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return pics.count
    }
    
    @IBAction func logout(sender: AnyObject) {
        PFUser.logOutInBackgroundWithBlock { (error:NSError?) -> Void in
            if error == nil{
                NSUserDefaults.standardUserDefaults().removeObjectForKey("username")
                NSUserDefaults.standardUserDefaults().synchronize()
                
                let signIn = self.storyboard?.instantiateViewControllerWithIdentifier("SignInViewController") as! SignInViewController
                let delegate : AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
                delegate.window?.rootViewController = signIn
            }
        }
    }
    
    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        postuuid.append(uuids[indexPath.row])
        
        let myPost = self.storyboard?.instantiateViewControllerWithIdentifier("PostViewController") as! PostViewController
        self.navigationController?.pushViewController(myPost, animated: true)
    }
    
    
    
/*
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath)
    
        // Configure the cell
    
        return cell
    }
*/
    // MARK: UICollectionViewDelegate

    /*
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(collectionView: UICollectionView, shouldHighlightItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(collectionView: UICollectionView, shouldSelectItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(collectionView: UICollectionView, shouldShowMenuForItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return false
    }

    override func collectionView(collectionView: UICollectionView, canPerformAction action: Selector, forItemAtIndexPath indexPath: NSIndexPath, withSender sender: AnyObject?) -> Bool {
        return false
    }

    override func collectionView(collectionView: UICollectionView, performAction action: Selector, forItemAtIndexPath indexPath: NSIndexPath, withSender sender: AnyObject?) {
    
    }
    */

}
