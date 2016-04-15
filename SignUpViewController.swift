//
//  SignUpViewController.swift
//  syl
//
//  Created by 유호균 on 2016. 4. 15..
//  Copyright © 2016년 timeros. All rights reserved.
//

import UIKit
import Parse
import ImagePicker

class SignUpViewController: UIViewController {

    @IBOutlet var SignUpButton: UIButton!
    @IBOutlet var userNameField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        PFUser.logInWithUsernameInBackground("myname", password: "mypass"){
            (user: PFUser?, error: NSError?) -> Void in
            if user != nil{
                self.performSegueWithIdentifier("FromSignToMain", sender: self)
            }else{
                self.SignUpButton.hidden = false
                self.userNameField.hidden = false
            }
        }
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func SignUpAction(sender: AnyObject) {
        
        let user = PFUser()
        user.username = UIDevice.currentDevice().identifierForVendor?.UUIDString
        user.password = UIDevice.currentDevice().identifierForVendor?.UUIDString
        user["name"] = self.userNameField.text
        
        user.signUpInBackgroundWithBlock{(succeeded: Bool, error: NSError?) -> Void in
            if let error = error{
                let errorString = error.userInfo["error"] as? NSString
                print(errorString)
            }
            else{
                self.performSegueWithIdentifier("FromSignToMain", sender: self)
            }
        }
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
