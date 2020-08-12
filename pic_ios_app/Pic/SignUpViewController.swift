//
//  SignUpViewController.swift
//  Pic
//
//  Created by Shreyas Patankar on 2/3/16.
//  Copyright © 2016 Shreyas Patankar. All rights reserved.
//

import UIKit
import Parse

class SignUpViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    //scroll View height & keyboard inintialization
    var scrollViewHt : CGFloat = 0
    var keyboard = CGRect()
    
    
    //scroll view
    @IBOutlet weak var scroll: UIScrollView!

    
    //profile image
    @IBOutlet weak var profileImage: UIImageView!
    
    //username, password text fields
    @IBOutlet weak var usernameText: UITextField!
    @IBOutlet weak var passwordText: UITextField!
    @IBOutlet weak var repeatPassText: UITextField!
    
    
    //name of user, basic information (bio), email
    @IBOutlet weak var actualName: UITextField!
    @IBOutlet weak var bio: UITextField!
    @IBOutlet weak var emailText: UITextField!
    
    //sign up and cancel buttons
    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //Initialize scroll view frame size.
        scroll.frame = CGRectMake(0, 0, self.view.frame.width, self.view.frame.height)
        scroll.contentSize.height = self.view.frame.height
        scrollViewHt = scroll.frame.size.height
        
        //check notifs if keyboard is shown or not...
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "showKeyboard:", name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "hideKeyboard:", name: UIKeyboardWillHideNotification, object: nil)
        
        //initialize hide keyboard things
        let hideTap = UITapGestureRecognizer(target: self, action: "hideKeyboardTap:")
        hideTap.numberOfTapsRequired = 1
        self.view.userInteractionEnabled = true
        self.view.addGestureRecognizer(hideTap)
        
        //round edges of profile
        profileImage.layer.cornerRadius = profileImage.frame.size.width / 2
        profileImage.clipsToBounds = true
        
        //set a new profile image
        let profileSelect = UITapGestureRecognizer(target: self, action: "loadNewProfileImage:")
        profileSelect.numberOfTapsRequired = 1;
        profileImage.userInteractionEnabled = true
        profileImage.addGestureRecognizer(profileSelect)
    }
    
    //select a new profile image
    func loadNewProfileImage(recognizer:UITapGestureRecognizer)
    {
        let imageChooser = UIImagePickerController()
        imageChooser.delegate = self
        imageChooser.sourceType = .PhotoLibrary
        imageChooser.allowsEditing = true
        presentViewController(imageChooser, animated: true, completion: nil)
        
    }
    
    //use selected image in image view
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        profileImage.image = info[UIImagePickerControllerEditedImage] as? UIImage
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    //hide keyboard
    func hideKeyboardTap(recognizer:UITapGestureRecognizer)
    {
        self.view.endEditing(true)
    }

    //show keyboard
    func showKeyboard(notification:NSNotification)
    {
        //initialize keyboard size
        keyboard = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey]!.CGRectValue)!
        
        //moves UI up
        UIView.animateWithDuration(0.3) { () -> Void in
            self.scroll.frame.size.height = self.scrollViewHt - self.keyboard.height
            
        }
    }
    
    
    //hide keyboard
    func hideKeyboard(notification:NSNotification)
    {
        //move UI down
        UIView.animateWithDuration(0.3) { () -> Void in
            self.scroll.frame.size.height = self.view.frame.height
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //sign up is pressed
    @IBAction func signUpIsClicked(sender: AnyObject) {
        //dismiss keyboard
        self.view.endEditing(true)
        
        //throw error if all fields are not filled out correctly
        if (usernameText.text!.isEmpty || passwordText.text!.isEmpty || emailText.text!.isEmpty || repeatPassText.text!.isEmpty || actualName.text!.isEmpty){
            
            let error = UIAlertController(title: "Oh no!", message: "Please make sure you fill out everything!", preferredStyle: UIAlertControllerStyle.Alert)
            let dismiss = UIAlertAction(title: "dismiss", style: UIAlertActionStyle.Cancel, handler: nil)
            error.addAction(dismiss)
            self.presentViewController(error, animated: true, completion: nil)
        }
        
        //check if password and repeat password match
        if passwordText.text != repeatPassText.text {
            let error = UIAlertController(title: "Oh no!", message: "Your passwords don't seem to match", preferredStyle: UIAlertControllerStyle.Alert)
            let dismiss = UIAlertAction(title: "dismiss", style: UIAlertActionStyle.Cancel, handler: nil)
            error.addAction(dismiss)
            self.presentViewController(error, animated: true, completion: nil)

        }else{
        
            //Add data to Parse
            let profPic = UIImageJPEGRepresentation(profileImage.image!, 0.5)
            let profFile = PFFile(name: "profile.jpg", data: profPic!)
        
            let myUser = PFUser()
            myUser.username = usernameText.text?.lowercaseString
            myUser.email = emailText.text?.lowercaseString
            myUser.password = passwordText.text?.lowercaseString
            myUser["actualName"] = actualName.text
            myUser["bio"] = bio.text
            myUser["profilePicture"] = profFile
            myUser["phone"] = ""
            myUser["gender"] = ""
        
            myUser.signUpInBackgroundWithBlock { (success:Bool, error:NSError?) -> Void in
                if success {
                    //Yay! The user is signed up! Now remember the user...
                    NSUserDefaults.standardUserDefaults().setObject(myUser.username, forKey: "username")
                    NSUserDefaults.standardUserDefaults().synchronize()
                
                    //call login from appDelegate
                    let appDelegate : AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
                    appDelegate.login()
                    print("success")
                    self.dismissViewControllerAnimated(true, completion: nil)
                }else{
                    print(error?.localizedDescription)
                    let error = UIAlertController(title: "Oh no!", message: "Someone has already used that email or username! Try changing them.", preferredStyle: UIAlertControllerStyle.Alert)
                    let dismiss = UIAlertAction(title: "dismiss", style: UIAlertActionStyle.Cancel, handler: nil)
                    error.addAction(dismiss)
                    self.presentViewController(error, animated: true, completion: nil)
                }
            }
        }
    }

    //cancel is pressed
    @IBAction func cancelIsClicked(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
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
