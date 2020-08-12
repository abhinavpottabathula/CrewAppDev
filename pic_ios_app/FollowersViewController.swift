//
//  FollowersViewController.swift
//  Pic
//
//  Created by Shreyas Patankar on 2/5/16.
//  Copyright © 2016 Shreyas Patankar. All rights reserved.
//


/*


FIX REFRESHER


*/

import UIKit
import Parse

var show = String()
var user = String()

class FollowersViewController: UITableViewController {

    var refresher : UIRefreshControl!
    
    var usernames = [String]()
    var profilePics = [PFFile]()
    var followArr = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //title the new view controllers
        self.navigationItem.title = show
        view.removeFromSuperview()
        
        //get relevant followings/followers
        if(show == "Followers"){
            getFollowers()
        }
        if(show == "Followings"){
            getFollowings()
        }
    }
    
    func refresh(){
        tableView?.reloadData()
        self.refresher.endRefreshing()
    }
    
    //get people that follow the user
    func getFollowers(){
        let myQuery = PFQuery(className: "follow")
        myQuery.whereKey("following", equalTo: user)
        myQuery.findObjectsInBackgroundWithBlock { (objects:[PFObject]?, error:NSError?) -> Void in
            if error == nil{
                
                //clean
                self.followArr.removeAll(keepCapacity: false)
                
                //find objects based on qry presets
                for object in objects!{
                    self.followArr.append(object.valueForKey("follower") as! String)
                }
                
                //find users following user
                let userQry = PFUser.query()
                userQry?.whereKey("username", containedIn: self.followArr)
                userQry?.addDescendingOrder("createdAt")
                userQry?.findObjectsInBackgroundWithBlock({ (objects:[PFObject]?, error:NSError?) -> Void in
                    if error == nil{
                        
                        //clean up
                        self.usernames.removeAll(keepCapacity: false)
                        self.profilePics.removeAll(keepCapacity: false)
                        
                        //find relevant objects in Parse
                        for object in objects!{
                            self.usernames.append(object.objectForKey("username") as! String)
                            self.profilePics.append(object.objectForKey("profilePicture") as! PFFile)
                            self.tableView.reloadData()
                        }
                    }else{
                        print(error!.localizedDescription)
                    }
                })
            }else{
                print(error!.localizedDescription)
            }
        }
    }
    
    //get people that the user follows
    func getFollowings(){
        let myQuery = PFQuery(className: "follow")
        myQuery.whereKey("follower", equalTo: user)
        myQuery.findObjectsInBackgroundWithBlock { (objects:[PFObject]?, error:NSError?) -> Void in
            if error == nil{
                
                //clean
                self.followArr.removeAll(keepCapacity: false)
                
                //find objects based on qry presets
                for object in objects!{
                    self.followArr.append(object.valueForKey("following") as! String)
                }
                
                //find users following user
                let userQry = PFUser.query()
                userQry?.whereKey("username", containedIn: self.followArr)
                userQry?.addDescendingOrder("createdAt")
                userQry?.findObjectsInBackgroundWithBlock({ (objects:[PFObject]?, error:NSError?) -> Void in
                    if error == nil{
                        
                        //clean
                        self.usernames.removeAll(keepCapacity: false)
                        self.profilePics.removeAll(keepCapacity: false)
                        
                        //find relevant objects in Parse
                        for object in objects!{
                            self.usernames.append(object.objectForKey("username") as! String)
                            self.profilePics.append(object.objectForKey("profilePicture") as! PFFile)
                            self.tableView.reloadData()
                        }
                    }
                })
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    //num cells
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return usernames.count
    }

    //cell layout
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell") as! FollowersItems
        
        //add data to ui
        cell.username.text = usernames[indexPath.row]
        profilePics[indexPath.row].getDataInBackgroundWithBlock { (data:NSData?, error:NSError?) -> Void in
            if error == nil{
                cell.profilePicture.image = UIImage(data: data!)
            }
        }
        
        //indicate who you are following in the list
        let myQuery = PFQuery(className: "follow")
        myQuery.whereKey("follower", equalTo: PFUser.currentUser()!.username!)
        myQuery.whereKey("following", equalTo: cell.username.text!)
        myQuery.countObjectsInBackgroundWithBlock { (count:Int32, error:NSError?) -> Void in
            if(error == nil){
                if(count == 0){
                    cell.followButton.setTitle("Follow", forState: UIControlState.Normal)
                    cell.followButton.backgroundColor = .lightGrayColor()
                }else{
                    cell.followButton.setTitle("Following", forState: UIControlState.Normal)
                    cell.followButton.backgroundColor = UIColor(red: 46.0/255.0, green: 204.0/255.0, blue: 113.0/255, alpha: 1)
                }
            }
        }
        
        //hide your own follow button
        if cell.username.text == PFUser.currentUser()?.username{
            cell.followButton.hidden = true
        }

        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let cell = tableView.cellForRowAtIndexPath(indexPath) as! FollowersItems
        
        if cell.username.text! == PFUser.currentUser()!.username!{
            let homeController = self.storyboard?.instantiateViewControllerWithIdentifier("HomeViewController") as! HomeViewController
            self.navigationController?.pushViewController(homeController, animated: true)
        }else{
            guestName.append(cell.username.text!)
            let guestController = self.storyboard?.instantiateViewControllerWithIdentifier("GuestViewController") as! GuestViewController
            self.navigationController?.pushViewController(guestController, animated: true)
        }
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
