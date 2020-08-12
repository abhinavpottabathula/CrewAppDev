//
//  ResetPassViewController.swift
//  Pic
//
//  Created by Shreyas Patankar on 2/3/16.
//  Copyright © 2016 Shreyas Patankar. All rights reserved.
//

import UIKit
import Parse

class ResetPassViewController: UIViewController {
    //email text entry
    @IBOutlet weak var emailText: UITextField!
    
    //buttons
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var resetButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func resetIsClicked(sender: AnyObject) {
        //hide keyboard
        self.view.endEditing(true)
        
        if emailText.text!.isEmpty {
            //show error
            let error = UIAlertController(title: "Oh no!", message: "Please enter something in the email box.", preferredStyle: UIAlertControllerStyle.Alert)
            let dismiss = UIAlertAction(title: "dismiss", style: UIAlertActionStyle.Cancel, handler: nil)
            error.addAction(dismiss)
            self.presentViewController(error, animated: true, completion: nil)
        }
        
        PFUser.requestPasswordResetForEmailInBackground(emailText.text!){ (success:Bool, error:NSError?) -> Void in
            if success {
                let emailSent = UIAlertController(title: "Email Sent!", message: "Password reset success.", preferredStyle: UIAlertControllerStyle.Alert)
                let dismiss = UIAlertAction(title: "dismiss", style: UIAlertActionStyle.Cancel, handler: nil)
                emailSent.addAction(dismiss)
                self.presentViewController(emailSent, animated: true, completion: nil)
            }
        }
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
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
