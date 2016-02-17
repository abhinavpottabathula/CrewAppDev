//
//  SignInViewController.swift
//  Pic
//
//  Created by Shreyas Patankar on 2/3/16.
//  Copyright © 2016 Shreyas Patankar. All rights reserved.
//

import UIKit
import Parse

class SignInViewController: UIViewController {

    //scroll View height & keyboard inintialization
    var scrollViewHt : CGFloat = 0
    var keyboard = CGRect()
    
    @IBOutlet weak var scroll: UIScrollView!
    //Title Label
    @IBOutlet weak var titleLabel: UILabel!
    
    //Username & Password text entry fields
    @IBOutlet weak var usernameText: UITextField!

    @IBOutlet weak var passText: UITextField!
    
    
    //Sign-In, Sign-Up, & forgot password actions
    @IBOutlet weak var forgotPass: UIButton!
    @IBOutlet weak var signIn: UIButton!
    @IBOutlet weak var signUp: UIButton!

    @IBOutlet weak var signInIsClicked: UIButton!
    
    override func viewDidLoad() {
        print("Sign in loaded")
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        //Initialize scroll view frame size.
        scroll.frame = CGRectMake(0, 0, self.view.frame.width, self.view.frame.height)
        scroll.contentSize.height = self.view.frame.height
        scrollViewHt = scroll.frame.size.height
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "showKeyboard:", name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "hideKeyboard:", name: UIKeyboardWillHideNotification, object: nil)
        
        //initialize hide keyboard things
        let hideTap = UITapGestureRecognizer(target: self, action: "hideKeyboardTap:")
        hideTap.numberOfTapsRequired = 1
        self.view.userInteractionEnabled = true
        self.view.addGestureRecognizer(hideTap)
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
    
    //hide keyboard
    func hideKeyboardTap(recognizer:UITapGestureRecognizer)
    {
        self.view.endEditing(true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //Sign in button is pressed
    @IBAction func signInIsClicked(sender: AnyObject) {
        //put keyboard away
        self.view.endEditing(true)
        
        //check if fields are empty
        if usernameText.text!.isEmpty || passText.text!.isEmpty{
            let error = UIAlertController(title: "Oh no!", message: "Please make sure you fill out everything!", preferredStyle: UIAlertControllerStyle.Alert)
            let dismiss = UIAlertAction(title: "dismiss", style: UIAlertActionStyle.Cancel, handler: nil)
            error.addAction(dismiss)
            self.presentViewController(error, animated: true, completion: nil)
        }else{
            //login functions
            PFUser.logInWithUsernameInBackground(usernameText.text!, password: passText.text!) { (user:PFUser?, error:NSError?) -> Void in
                if error == nil {
                    print("success1")
                    NSUserDefaults.standardUserDefaults().setObject(user!.username, forKey: "username")
                    NSUserDefaults.standardUserDefaults().synchronize()
                    
                    let appDelegate : AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
                    appDelegate.login()
                    print("success2")
                }else{
                    print("fail")
                    let error = UIAlertController(title: "Oh no!", message: "Wrong username or password.", preferredStyle: UIAlertControllerStyle.Alert)
                    let dismiss = UIAlertAction(title: "dismiss", style: UIAlertActionStyle.Cancel, handler: nil)
                    error.addAction(dismiss)
                    self.presentViewController(error, animated: true, completion: nil)
                }
            }
        }

    }
    
    
    //Sign up button is pressed
    @IBAction func signUpIsClicked(sender: AnyObject) {
        
    }
    
    @IBAction func forgotPassIsClicked(sender: AnyObject) {
        
    }
    
}
