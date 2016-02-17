//
//  UploadViewController.swift
//  Pic
//
//  Created by Shreyas Patankar on 2/6/16.
//  Copyright © 2016 Shreyas Patankar. All rights reserved.
//

import UIKit
import Parse

class UploadViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    
    @IBOutlet weak var uploadPic: UIImageView!
    @IBOutlet weak var caption: UITextView!
    @IBOutlet weak var shareButton: UIButton!
    @IBOutlet weak var deletePostButton: UIBarButtonItem!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        dispatch_async(dispatch_get_main_queue(), {
            self.caption.selectedRange = NSMakeRange(0, 0);
        })
        
        //set properties of view
        uploadPic.image = UIImage(named: "upload_default.png")
        caption.text = ""
        self.navigationItem.title = "CAMERA"
        
        //disable share button until image is selected
        shareButton.enabled = false
        shareButton.backgroundColor = .lightGrayColor()
        
        //disable delete button until image is uploaded
        self.navigationItem.rightBarButtonItem!.enabled = false;
        
        //hide keyboard
        let hideKey = UITapGestureRecognizer(target: self, action: "hideKeyboardTap")
        hideKey.numberOfTapsRequired = 1
        self.view.userInteractionEnabled = true
        self.view.addGestureRecognizer(hideKey)
        
        //upload photo
        let photoClick = UITapGestureRecognizer(target: self, action: "imageTapped")
        photoClick.numberOfTapsRequired = 1
        uploadPic.userInteractionEnabled = true
        uploadPic.addGestureRecognizer(photoClick)
        
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        uploadPic.image = info[UIImagePickerControllerEditedImage] as? UIImage
        self.dismissViewControllerAnimated(true, completion: nil)
        
        //enable share button
        shareButton.enabled = true
        shareButton.backgroundColor = UIColor(red: 52.0/255.0, green: 152.0/255.0, blue: 219.0/255.0, alpha: 1)
        
        //enable remove
        self.navigationItem.rightBarButtonItem!.enabled = true;
    }
    
    //get image chooser
    func imageTapped(){
        let imgChooser = UIImagePickerController()
        imgChooser.delegate = self
        
        if(UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType(rawValue: 2)!)){
            imgChooser.sourceType = .Camera
        }else{
            imgChooser.sourceType = .PhotoLibrary
        }
        imgChooser.allowsEditing = true
        presentViewController(imgChooser, animated: true, completion: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func hideKeyboardTap(){
        self.view.endEditing(true)
    }
    
    @IBAction func shareIsClicked(sender: AnyObject) {
        //dismiss any remaining editing components
        self.view.endEditing(true)
        
        let object = PFObject(className: "Posts")
        object["username"] = PFUser.currentUser()!.username
        object["profilePicture"] = PFUser.currentUser()!.valueForKey("profilePicture") as! PFFile
        object["uuid"] = "\(PFUser.currentUser()!.username) \(NSUUID().UUIDString)"
        
        if caption.text.isEmpty{
            object["caption"] = ""
        }else{
            object["caption"] = caption.text.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
        }
        
        let myPicture = UIImageJPEGRepresentation(uploadPic.image!, 0.5)
        let myPicFile = PFFile(name: "postImage.jpg", data: myPicture!)
        object["image"] = myPicFile

        object.saveInBackgroundWithBlock { (success:Bool, error:NSError?) -> Void in
            if error == nil{
                NSNotificationCenter.defaultCenter().postNotificationName("uploaded", object: nil)
                self.tabBarController!.selectedIndex = 0
            }
            
            //reset view
            self.viewDidLoad()
        }
    }
    
    @IBAction func deleteIsPressed(sender: AnyObject) {
        self.viewDidLoad()
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
