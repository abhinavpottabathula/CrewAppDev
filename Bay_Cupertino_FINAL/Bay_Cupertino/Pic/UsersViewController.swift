//
//  UsersViewController.swift
//  Pic
//
//  Created by Shreyas Patankar on 2/10/16.
//  Copyright © 2016 Shreyas Patankar. All rights reserved.
//

import UIKit
import Parse

class UsersViewController: UITableViewController, UISearchBarDelegate {

    var searchBar = UISearchBar()
    
    var usernames = [String]()
    var profilePics = [PFFile]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchBar.delegate = self
        searchBar.sizeToFit()
        searchBar.tintColor = UIColor.groupTableViewBackgroundColor()
        searchBar.showsCancelButton = true
        searchBar.frame.size.width = self.view.frame.size.width - 34
        let searchItem = UIBarButtonItem(customView: searchBar)
        self.navigationItem.leftBarButtonItem = searchItem

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    func loadUsers() {
        
        let usersQuery = PFQuery(className: "_User")
        usersQuery.addDescendingOrder("createdAt")
        usersQuery.limit = 20
        usersQuery.findObjectsInBackgroundWithBlock ({ (objects:[PFObject]?, error:NSError?) -> Void in
            if error == nil {
                
                // clean up
                self.usernames.removeAll(keepCapacity: false)
                self.profilePics.removeAll(keepCapacity: false)
                
                // found related objects
                for object in objects! {
                    self.usernames.append(object.valueForKey("username") as! String)
                    self.profilePics.append(object.valueForKey("profilePicture") as! PFFile)
                }
                
                // reload
                self.tableView.reloadData()
                
            } else {
                print(error!.localizedDescription)
            }
        })
        
    }

    func searchBar(searchBar: UISearchBar, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        
        // find by username
        let usernameQuery = PFQuery(className: "_User")
        usernameQuery.whereKey("username", matchesRegex: "(?i)" + searchBar.text!)
        usernameQuery.findObjectsInBackgroundWithBlock ({ (objects:[PFObject]?, error:NSError?) -> Void in
            if error == nil {
                
                // if no objects are found according to entered text in usernaem colomn, find by fullname
                if objects!.isEmpty {
                    
                    let fullnameQuery = PFUser.query()
                    fullnameQuery?.whereKey("actualName", matchesRegex: "(?i)" + self.searchBar.text!)
                    fullnameQuery?.findObjectsInBackgroundWithBlock({ (objects:[PFObject]?, error:NSError?) -> Void in
                        if error == nil {
                            
                            // clean up
                            self.usernames.removeAll(keepCapacity: false)
                            self.profilePics.removeAll(keepCapacity: false)
                            
                            // found related objects
                            for object in objects! {
                                self.usernames.append(object.objectForKey("username") as! String)
                                self.profilePics.append(object.objectForKey("profilePicture") as! PFFile)
                            }
                            
                            // reload
                            self.tableView.reloadData()
                            
                        }
                    })
                }
                
                // clean up
                self.usernames.removeAll(keepCapacity: false)
                self.profilePics.removeAll(keepCapacity: false)
                
                // found related objects
                for object in objects! {
                    self.usernames.append(object.objectForKey("username") as! String)
                    self.profilePics.append(object.objectForKey("profilePicture") as! PFFile)
                }
                
                // reload
                self.tableView.reloadData()
                
            }
        })
        
        return true
    }
    
    // clicked cancel button
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        // dismiss keyboard
        searchBar.resignFirstResponder()
        // hide cancel button
        searchBar.showsCancelButton = false
        // reset text
        searchBar.text = ""
        // reset shown users
        loadUsers()
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
        return usernames.count
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return self.view.frame.size.width / 4
    }

    // cell config
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        // define cell
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell") as! FollowersItems
        
        // hide follow button
        cell.followButton.hidden = true
        
        // connect cell's objects with received infromation from server
        cell.username.text = usernames[indexPath.row]
        profilePics[indexPath.row].getDataInBackgroundWithBlock { (data:NSData?, error:NSError?) -> Void in
            if error == nil {
                cell.profilePicture.image = UIImage(data: data!)
            }
        }
        
        return cell
    }
    
    // selected tableView cell - selected user
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        // calling cell again to call cell data
        let cell = tableView.cellForRowAtIndexPath(indexPath) as! FollowersItems
        
        // if user tapped on his name go home, else go guest
        if cell.username.text! == PFUser.currentUser()?.username {
            let home = self.storyboard?.instantiateViewControllerWithIdentifier("HomeViewController") as! HomeViewController
            self.navigationController?.pushViewController(home, animated: true)
        } else {
            guestName.append(cell.username.text!)
            let guest = self.storyboard?.instantiateViewControllerWithIdentifier("GuestViewController") as! GuestViewController
            self.navigationController?.pushViewController(guest, animated: true)
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
