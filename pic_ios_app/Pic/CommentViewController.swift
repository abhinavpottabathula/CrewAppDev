//
//  CommentViewController.swift
//  Pic
//
//  Created by Shreyas Patankar on 2/9/16.
//  Copyright © 2016 Shreyas Patankar. All rights reserved.
//

import UIKit
import Parse

var commentuuid = [String]()
var commentowner = [String]()

class CommentViewController: UIViewController, UITableViewDelegate, UITextViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var commentTxt: UITextView!
    @IBOutlet weak var sendButton: UIButton!
    
    var refresher = UIRefreshControl()
    
    var tableViewHeight : CGFloat = 0
    var commentY : CGFloat = 0
    var commentHeight : CGFloat = 0
    
    var keyboard = CGRect()
    
    // arrays to hold server data
    var usernames = [String]()
    var profilePics = [PFFile]()
    var comments = [String]()
    var timestamp = [NSDate?]()
    
    var page : Int32 = 15
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        self.navigationItem.title = "COMMENTS"
        
        
        // catch notification if the keyboard is shown or hidden
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)
        
        sendButton.enabled = false
        
        alignment()
        loadComments()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return comments.count
    }
    
    // cell height
    func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    //get comments
    func loadComments() {
        
        // STEP 1. Count total comments in order to skip all except (page size = 15)
        let countQuery = PFQuery(className: "comments")
        countQuery.whereKey("to", equalTo: commentuuid.last!)
        countQuery.countObjectsInBackgroundWithBlock ({ (count:Int32, error:NSError?) -> Void in
            
            // if comments on the server for current post are more than (page size 15), implement pull to refresh func
            if self.page < count {
                self.refresher.addTarget(self, action: "loadMore", forControlEvents: UIControlEvents.ValueChanged)
                self.tableView.addSubview(self.refresher)
            }
            
            // STEP 2. Request last (page size 15) comments
            let query = PFQuery(className: "comments")
            query.whereKey("to", equalTo: commentuuid.last!)
            query.skip = count - self.page
            query.addAscendingOrder("createdAt")
            query.findObjectsInBackgroundWithBlock({ (objects:[PFObject]?, erro:NSError?) -> Void in
                if error == nil {
                    
                    // clean up
                    self.usernames.removeAll(keepCapacity: false)
                    self.profilePics.removeAll(keepCapacity: false)
                    self.comments.removeAll(keepCapacity: false)
                    self.timestamp.removeAll(keepCapacity: false)
                    
                    // find related objects
                    for object in objects! {
                        self.usernames.append(object.objectForKey("username") as! String)
                        self.profilePics.append(object.objectForKey("profilePic") as! PFFile)
                        self.comments.append(object.objectForKey("comment") as! String)
                        self.timestamp.append(object.createdAt)
                        self.tableView.reloadData()
                        
                        // scroll to bottom
                        self.tableView.scrollToRowAtIndexPath(NSIndexPath(forRow: self.comments.count - 1, inSection: 0), atScrollPosition: UITableViewScrollPosition.Bottom, animated: false)
                    }
                } else {
                    print(error?.localizedDescription)
                }
            })
        })
        
    }

    // pagination
    func loadMore() {
        
        // STEP 1. Count total comments in order to skip all except (page size = 15)
        let countQuery = PFQuery(className: "comments")
        countQuery.whereKey("to", equalTo: commentuuid.last!)
        countQuery.countObjectsInBackgroundWithBlock ({ (count:Int32, error:NSError?) -> Void in
            
            // self refresher
            self.refresher.endRefreshing()
            
            // remove refresher if loaded all comments
            if self.page >= count {
                self.refresher.removeFromSuperview()
            }
            
            // STEP 2. Load more comments
            if self.page < count {
                
                // increase page to load 30 as first paging
                self.page = self.page + 15
                
                // request existing comments from the server
                let query = PFQuery(className: "comments")
                query.whereKey("to", equalTo: commentuuid.last!)
                query.skip = count - self.page
                query.addAscendingOrder("createdAt")
                query.findObjectsInBackgroundWithBlock({ (objects:[PFObject]?, error:NSError?) -> Void in
                    if error == nil {
                        
                        // clean up
                        self.usernames.removeAll(keepCapacity: false)
                        self.profilePics.removeAll(keepCapacity: false)
                        self.comments.removeAll(keepCapacity: false)
                        self.timestamp.removeAll(keepCapacity: false)
                        
                        // find related objects
                        for object in objects! {
                            self.usernames.append(object.objectForKey("username") as! String)
                            self.profilePics.append(object.objectForKey("profilePic") as! PFFile)
                            self.comments.append(object.objectForKey("comment") as! String)
                            self.timestamp.append(object.createdAt)
                            self.tableView.reloadData()
                        }
                    } else {
                        print(error?.localizedDescription)
                    }
                })
            }
            
        })
        
    }
    
    // cell config
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        // declare cell
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell") as! CommentCell
        
        cell.usernameBtn.setTitle(usernames[indexPath.row], forState: .Normal)
        cell.usernameBtn.sizeToFit()
        cell.commentTxt.text = comments[indexPath.row]
        profilePics[indexPath.row].getDataInBackgroundWithBlock { (data:NSData?, error:NSError?) -> Void in
            cell.profilePic.image = UIImage(data: data!)
        }
        
        // calculate date
        let from = timestamp[indexPath.row]
        let now = NSDate()
        let components : NSCalendarUnit = [.Second, .Minute, .Hour, .Day, .WeekOfMonth]
        let difference = NSCalendar.currentCalendar().components(components, fromDate: from!, toDate: now, options: [])
        
        if difference.second <= 0 {
            cell.timestamp.text = "now"
        }
        if difference.second > 0 && difference.minute == 0 {
            cell.timestamp.text = "\(difference.second)s"
        }
        if difference.minute > 0 && difference.hour == 0 {
            cell.timestamp.text = "\(difference.minute)m"
        }
        if difference.hour > 0 && difference.day == 0 {
            cell.timestamp.text = "\(difference.hour)h"
        }
        if difference.day > 0 && difference.weekOfMonth == 0 {
            cell.timestamp.text = "\(difference.day)d"
        }
        if difference.weekOfMonth > 0 {
            cell.timestamp.text = "\(difference.weekOfMonth)w."
        }
        
        // assign indexes of buttons
        cell.usernameBtn.layer.setValue(indexPath, forKey: "index")
        
        return cell
    }
    
    // alignment function
    func alignment() {
        
        // alignnment
        let width = self.view.frame.size.width
        let height = self.view.frame.size.height
        
        tableView.frame = CGRectMake(0, 0, width, height / 1.096 - self.navigationController!.navigationBar.frame.size.height - 20)
        tableView.estimatedRowHeight = width / 5.333
        tableView.rowHeight = UITableViewAutomaticDimension
    
        commentTxt.frame = CGRectMake(10, tableView.frame.size.height + height / 56.8, width / 1.306, 33)
        commentTxt.layer.cornerRadius = commentTxt.frame.size.width / 50
        
        sendButton.frame = CGRectMake(commentTxt.frame.origin.x + commentTxt.frame.size.width + width / 32, commentTxt.frame.origin.y, width - (commentTxt.frame.origin.x + commentTxt.frame.size.width) - (width / 32) * 2, commentTxt.frame.size.height)
        
        commentTxt.delegate = self
        tableView.delegate = self
        tableView.dataSource = self
        
        // assign reseting values
        tableViewHeight = tableView.frame.size.height
        commentHeight = commentTxt.frame.size.height
        commentY = commentTxt.frame.origin.y
    }

    func textViewDidChange(textView: UITextView) {
        
        // disable button if entered no text
        let spacing = NSCharacterSet.whitespaceAndNewlineCharacterSet()
        if !commentTxt.text.stringByTrimmingCharactersInSet(spacing).isEmpty {
            sendButton.enabled = true
        } else {
            sendButton.enabled = false
        }
        
        // + paragraph
        if textView.contentSize.height > textView.frame.size.height && textView.frame.height < 130 {
            
            // find difference to add
            let difference = textView.contentSize.height - textView.frame.size.height
            
            // redefine frame of commentTxt
            textView.frame.origin.y = textView.frame.origin.y - difference
            textView.frame.size.height = textView.contentSize.height
            
            // move up tableView
            if textView.contentSize.height + keyboard.height + commentY >= tableView.frame.size.height {
                tableView.frame.size.height = tableView.frame.size.height - difference
            }
        }
            
            // - paragraph
        else if textView.contentSize.height < textView.frame.size.height {
            
            // find difference to deduct
            let difference = textView.frame.size.height - textView.contentSize.height
            
            // redefine frame of commentTxt
            textView.frame.origin.y = textView.frame.origin.y + difference
            textView.frame.size.height = textView.contentSize.height
            
            // move donw tableViwe
            if textView.contentSize.height + keyboard.height + commentY > tableView.frame.size.height {
                tableView.frame.size.height = tableView.frame.size.height + difference
            }
        }
    }
    
    // preload func
    override func viewWillAppear(animated: Bool) {
        
        // hide bottom bar
        self.tabBarController?.tabBar.hidden = true
        
        // call keyboard
        commentTxt.becomeFirstResponder()
    }
    
    func keyboardWillShow(notification : NSNotification) {
        
        // defnine keyboard frame size
        keyboard = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey]!.CGRectValue)!
        
        // move UI up
        UIView.animateWithDuration(0.4) { () -> Void in
            self.tableView.frame.size.height = self.tableViewHeight - self.keyboard.height - self.commentTxt.frame.size.height - (self.commentHeight)
            self.commentTxt.frame.origin.y = self.commentY - self.keyboard.height - self.commentTxt.frame.size.height + (self.commentHeight * 2.5)
            self.sendButton.frame.origin.y = self.commentTxt.frame.origin.y
        }
    }
    
    
    // func loading when keyboard is hidden
    func keyboardWillHide(notification : NSNotification) {
        
        // move UI down
        UIView.animateWithDuration(0.4) { () -> Void in
            self.tableView.frame.size.height = self.tableViewHeight
            self.commentTxt.frame.origin.y = self.commentY
            self.sendButton.frame.origin.y = self.commentY
        }
    }

    
    // postload func
    override func viewWillDisappear(animated: Bool) {
        self.tabBarController?.tabBar.hidden = false
    }
    
    @IBAction func sendIsPressed(sender: AnyObject) {
        // STEP 1. Add row in tableView
        usernames.append(PFUser.currentUser()!.username!)
        profilePics.append(PFUser.currentUser()?.objectForKey("profilePicture") as! PFFile)
        timestamp.append(NSDate())
        comments.append(commentTxt.text.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet()))
        tableView.reloadData()
        
        // STEP 2. Send comment to server
        let commentObj = PFObject(className: "comments")
        commentObj["to"] = commentuuid.last
        commentObj["username"] = PFUser.currentUser()?.username
        commentObj["profilePic"] = PFUser.currentUser()?.valueForKey("profilePicture")
        commentObj["comment"] = commentTxt.text.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
        commentObj.saveEventually()
        
        // scroll to bottom
        self.tableView.scrollToRowAtIndexPath(NSIndexPath(forItem: comments.count - 1, inSection: 0), atScrollPosition: UITableViewScrollPosition.Bottom, animated: false)
        
        //reset
        sendButton.enabled = false
        commentTxt.text = ""
        commentTxt.frame.size.height = commentHeight
        commentTxt.frame.origin.y = sendButton.frame.origin.y
        tableView.frame.size.height = self.tableViewHeight - self.keyboard.height - self.commentTxt.frame.size.height + self.commentHeight
    }

    // cell editabily
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    // swipe cell for actions
    func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
        
        // call cell for calling further cell data
        let cell = tableView.cellForRowAtIndexPath(indexPath) as! CommentCell
        
        // ACTION 1. Delete
        let delete = UITableViewRowAction(style: .Normal, title: "Delete") { (action:UITableViewRowAction, indexPath:NSIndexPath) -> Void in
            
            // STEP 1. Delete comment from server
            let commentQuery = PFQuery(className: "comments")
            commentQuery.whereKey("to", equalTo: commentuuid.last!)
            commentQuery.whereKey("comment", equalTo: cell.commentTxt.text!)
            commentQuery.findObjectsInBackgroundWithBlock ({ (objects:[PFObject]?, error:NSError?) -> Void in
                if error == nil {
                    // find related objects
                    for object in objects! {
                        object.deleteEventually()
                    }
                } else {
                    print(error!.localizedDescription)
                }
            })
            
            tableView.setEditing(false, animated: true)
            
            // STEP 2. Delete comment row from tableView
            self.comments.removeAtIndex(indexPath.row)
            self.timestamp.removeAtIndex(indexPath.row)
            self.usernames.removeAtIndex(indexPath.row)
            self.profilePics.removeAtIndex(indexPath.row)
            
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        }
        
        delete.backgroundColor = UIColor(red: 231.0/255.0, green: 76.0/255.0, blue: 60.0/255, alpha: 1)
        
        return [delete]
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
