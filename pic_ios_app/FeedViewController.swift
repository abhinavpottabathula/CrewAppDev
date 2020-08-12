//
//  FeedViewController.swift
//  Pic
//
//  Created by Shreyas Patankar on 2/9/16.
//  Copyright © 2016 Shreyas Patankar. All rights reserved.
//

import UIKit
import Parse

/*
    TODO image resizes after double tap
*/

class FeedViewController: UITableViewController {

    @IBOutlet weak var indicator: UIActivityIndicatorView!
    
    var refresher = UIRefreshControl()
    
    var usernames = [String]()
    var profilePics = [PFFile]()
    var timestamps = [NSDate?]()
    var postImages = [PFFile]()
    var captions = [String]()
    var uuids = [String]()
    var following = [String]()
    
    var page : Int = 10
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.title = "FEED"
        
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 450
        
        // pull to refresh
        refresher.addTarget(self, action: "loadPosts", forControlEvents: UIControlEvents.ValueChanged)
        tableView.addSubview(refresher)

        loadPosts()
        self.tableView.reloadData()
    }

    func loadPosts(){
        // STEP 1. Find posts realted to people who we are following
        let followQuery = PFQuery(className: "follow")
        followQuery.whereKey("follower", equalTo: PFUser.currentUser()!.username!)
        followQuery.findObjectsInBackgroundWithBlock ({ (objects:[PFObject]?, error:NSError?) -> Void in
            if error == nil {
                
                // clean up
                self.following.removeAll(keepCapacity: false)
                
                // find related objects
                for object in objects! {
                    self.following.append(object.objectForKey("following") as! String)
                }
                
                // append current user to see own posts in feed
                self.following.append(PFUser.currentUser()!.username!)
                
                // STEP 2. Find posts made by people appended to followArray
                let query = PFQuery(className: "Posts")
                query.whereKey("username", containedIn: self.following)
                query.limit = self.page
                query.addDescendingOrder("createdAt")
                query.findObjectsInBackgroundWithBlock({ (objects:[PFObject]?, error:NSError?) -> Void in
                    if error == nil {
                        
                        // clean up
                        self.usernames.removeAll(keepCapacity: false)
                        self.profilePics.removeAll(keepCapacity: false)
                        self.timestamps.removeAll(keepCapacity: false)
                        self.postImages.removeAll(keepCapacity: false)
                        self.captions.removeAll(keepCapacity: false)
                        self.uuids.removeAll(keepCapacity: false)
                        
                        // find related objects
                        for object in objects! {
                            self.usernames.append(object.objectForKey("username") as! String)
                            self.profilePics.append(object.objectForKey("profilePicture") as! PFFile)
                            self.timestamps.append(object.createdAt)
                            self.postImages.append(object.objectForKey("image") as! PFFile)
                            self.captions.append(object.objectForKey("caption") as! String)
                            self.uuids.append(object.objectForKey("uuid") as! String)
                        }
                        
                        // reload tableView & end spinning of refresher
                        self.tableView.reloadData()
                        self.refresher.endRefreshing()
                        
                    } else {
                        print(error!.localizedDescription)
                    }
                })
            } else {
                print(error!.localizedDescription)
            }
        })

    }
    
    //pagination
    override func scrollViewDidScroll(scrollView: UIScrollView) {
        if scrollView.contentOffset.y >= scrollView.contentSize.height - self.view.frame.size.height * 2 {
            loadMore()
        }
    }
    
    func loadMore() {
        
        // if posts on the server are more than shown
        if page <= uuids.count {
            
            // start animating indicator
            indicator.startAnimating()
            
            // increase page size to load +10 posts
            page = page + 10
            
            // STEP 1. Find posts realted to people who we are following
            let followQuery = PFQuery(className: "follow")
            followQuery.whereKey("follower", equalTo: PFUser.currentUser()!.username!)
            followQuery.findObjectsInBackgroundWithBlock ({ (objects:[PFObject]?, error:NSError?) -> Void in
                if error == nil {
                    
                    // clean up
                    self.following.removeAll(keepCapacity: false)
                    
                    // find related objects
                    for object in objects! {
                        self.following.append(object.objectForKey("following") as! String)
                    }
                    
                    // append current user to see own posts in feed
                    self.following.append(PFUser.currentUser()!.username!)
                    
                    // STEP 2. Find posts made by people appended to followArray
                    let query = PFQuery(className: "Posts")
                    query.whereKey("username", containedIn: self.following)
                    query.limit = self.page
                    query.addDescendingOrder("createdAt")
                    query.findObjectsInBackgroundWithBlock({ (objects:[PFObject]?, error:NSError?) -> Void in
                        if error == nil {
                            
                            // clean up
                            self.usernames.removeAll(keepCapacity: false)
                            self.profilePics.removeAll(keepCapacity: false)
                            self.timestamps.removeAll(keepCapacity: false)
                            self.postImages.removeAll(keepCapacity: false)
                            self.captions.removeAll(keepCapacity: false)
                            self.uuids.removeAll(keepCapacity: false)
                            
                            // find related objects
                            for object in objects! {
                                self.usernames.append(object.objectForKey("username") as! String)
                                self.profilePics.append(object.objectForKey("profilePicture") as! PFFile)
                                self.timestamps.append(object.createdAt)
                                self.postImages.append(object.objectForKey("image") as! PFFile)
                                self.captions.append(object.objectForKey("caption") as! String)
                                self.uuids.append(object.objectForKey("uuid") as! String)
                            }
                            
                            // reload tableView & stop animating indicator
                            self.tableView.reloadData()
                            self.indicator.stopAnimating()
                            
                        } else {
                            print(error!.localizedDescription)
                        }
                    })
                } else {
                    print(error!.localizedDescription)
                }
            })
            
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return uuids.count
    }
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! PostCell
        // Configure the cell...
        cell.username.setTitle(usernames[indexPath.row], forState: UIControlState.Normal)
        cell.username.sizeToFit()
        cell.uuidLbl.text = uuids[indexPath.row]
        cell.captionTxt.text = captions[indexPath.row]
        cell.username.sizeToFit()
        
        profilePics[indexPath.row].getDataInBackgroundWithBlock { (data:NSData?, error:NSError?) -> Void in
            cell.profilePicture.image = UIImage(data: data!)
        }
        
        postImages[indexPath.row].getDataInBackgroundWithBlock { (data:NSData?, error:NSError?) -> Void in
            cell.picture.image = UIImage(data: data!)
        }
        
        //get date
        let from = timestamps[indexPath.row]
        let now = NSDate()
        let dateAspects : NSCalendarUnit = [.Second, .Minute, .Hour, .Day, .WeekOfMonth]
        let calcDiff = NSCalendar.currentCalendar().components(dateAspects, fromDate: from!, toDate: now, options: [])
        
        if calcDiff.second <= 0{
            cell.timestamp.text = "Just Now"
        }
        if calcDiff.second >= 0 && calcDiff.minute == 0{
            cell.timestamp.text = "\(calcDiff.second)s"
        }
        if calcDiff.minute > 0 && calcDiff.hour == 0{
            cell.timestamp.text = "\(calcDiff.minute)m"
        }
        if calcDiff.hour > 0 && calcDiff.day == 0{
            cell.timestamp.text = "\(calcDiff.hour)h"
        }
        if calcDiff.day > 0 && calcDiff.weekOfMonth == 0{
            cell.timestamp.text = "\(calcDiff.day)d"
        }
        if calcDiff.weekOfMonth > 0{
            cell.timestamp.text = "\(calcDiff)w"
        }
        
        //user did like
        let likeQry = PFQuery(className: "likes")
        likeQry.whereKey("by", equalTo: PFUser.currentUser()!.username!)
        likeQry.whereKey("to", equalTo: cell.uuidLbl.text!)
        likeQry.countObjectsInBackgroundWithBlock { (count:Int32, error:NSError?) -> Void in
            if count == 0{
                cell.likeButton.setTitle("unlike", forState: .Normal)
                cell.likeButton.setBackgroundImage(UIImage(named: "like_selected.png"), forState: .Normal)
            }else{
                cell.likeButton.setTitle("like", forState: .Normal)
                cell.likeButton.setBackgroundImage(UIImage(named: "like_unselected.png"), forState: .Normal)
            }
        }
        
        let countLikes = PFQuery(className: "likes")
        countLikes.whereKey("to", equalTo: cell.uuidLbl.text!)
        countLikes.countObjectsInBackgroundWithBlock { (count:Int32, error:NSError?) -> Void in
            cell.likeTxt.text = "\(count)"
        }
        
        cell.username.layer.setValue(indexPath, forKey: "index")
        cell.commentButton.layer.setValue(indexPath, forKey: "index")
        
        return cell
    }

    @IBAction func commentIsClicked(sender: AnyObject) {
        
        // call index of button
        let i = sender.layer.valueForKey("index") as! NSIndexPath
        
        // call cell to call further cell data
        let cell = tableView.cellForRowAtIndexPath(i) as! PostCell
        
        // send related data to global variables
        commentuuid.append(cell.uuidLbl.text!)
        commentowner.append(cell.username.titleLabel!.text!)
        
        // go to comments. present vc
        let comment = self.storyboard?.instantiateViewControllerWithIdentifier("CommentViewController") as! CommentViewController
        self.navigationController?.pushViewController(comment, animated: true)
    }
    
    // clicked username button
    @IBAction func usernameBtn_click(sender: AnyObject) {
        
        // call index of button
        let i = sender.layer.valueForKey("index") as! NSIndexPath
        
        // call cell to call further cell data
        let cell = tableView.cellForRowAtIndexPath(i) as! PostCell
        
        // if user tapped on himself go home, else go guest
        if cell.username.titleLabel?.text == PFUser.currentUser()?.username {
            let home = self.storyboard?.instantiateViewControllerWithIdentifier("HomeViewController") as! HomeViewController
            self.navigationController?.pushViewController(home, animated: true)
        } else {
            guestName.append(cell.username.titleLabel!.text!)
            let guest = self.storyboard?.instantiateViewControllerWithIdentifier("GuestViewController") as! GuestViewController
            self.navigationController?.pushViewController(guest, animated: true)
        }
        
    }
    
    /*
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("reuseIdentifier", forIndexPath: indexPath)

        // Configure the cell...

        return cell
    }
    */

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
