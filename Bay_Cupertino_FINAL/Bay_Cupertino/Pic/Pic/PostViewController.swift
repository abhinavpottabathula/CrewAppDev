//
//  PostViewController.swift
//  Pic
//
//  Created by Shreyas Patankar on 2/7/16.
//  Copyright © 2016 Shreyas Patankar. All rights reserved.
//

import UIKit
import Parse

var postuuid = [String]()

class PostViewController: UITableViewController {

    var usernames = [String]()
    var pfPics = [PFFile]()
    var dates = [NSDate?]()
    var pics = [PFFile]()
    var uuids = [String]()
    var captions = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        self.navigationItem.title = "PHOTO"
        
        
        //-----------------------
        //-----------------------
        //custom back button???? [see other view controllers]
        //-----------------------
        //-----------------------
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "refresh", name: "liked", object: nil)
        
        //dynamic cell height
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 450
        
        let pQry = PFQuery(className: "Posts")
        pQry.whereKey("uuid", equalTo: postuuid.last!)
        pQry.findObjectsInBackgroundWithBlock { (objects:[PFObject]?, error:NSError?) -> Void in
            if error == nil{
                
                //clean up
                self.usernames.removeAll(keepCapacity: false)
                self.pfPics.removeAll(keepCapacity: false)
                self.dates.removeAll(keepCapacity: false)
                self.pics.removeAll(keepCapacity: false)
                self.uuids.removeAll(keepCapacity: false)
                self.captions.removeAll(keepCapacity: false)
                
                //find relevant objects
                for object in objects!{
                    self.usernames.append(object.valueForKey("username") as! String)
                    self.pfPics.append(object.valueForKey("profilePicture") as! PFFile)
                    self.dates.append(object.createdAt)
                    self.pics.append(object.valueForKey("image") as! PFFile)
                    self.uuids.append(object.valueForKey("uuid") as! String)
                    self.captions.append(object.valueForKey("caption") as! String)
                }
            }
            self.tableView.reloadData()
        }
    }
    
    func refresh() {
        self.tableView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    //cell count
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return usernames.count
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! PostCell
        // Configure the cell...
        cell.username.setTitle(usernames[indexPath.row], forState: UIControlState.Normal)
        cell.username.sizeToFit()
        cell.uuidLbl.text = uuids[indexPath.row]
        cell.captionTxt.text = captions[indexPath.row]
        cell.username.sizeToFit()
        
        pfPics[indexPath.row].getDataInBackgroundWithBlock { (data:NSData?, error:NSError?) -> Void in
            cell.profilePicture.image = UIImage(data: data!)
        }
        
        pics[indexPath.row].getDataInBackgroundWithBlock { (data:NSData?, error:NSError?) -> Void in
            cell.picture.image = UIImage(data: data!)
        }
        
        //get date
        let from = dates[indexPath.row]
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
