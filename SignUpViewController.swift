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

class SignUpViewController: UIViewController, ImagePickerDelegate {

    @IBOutlet var SignUpButton: UIButton!
    @IBOutlet var userNameField: UITextField!
    @IBOutlet var userPhoto: UIImageView!
    @IBOutlet var imageSelecBtn: UIButton!
    @IBOutlet var progressView: UIProgressView!
    
    var userSelectImages: [UIImage]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(animated: Bool) {
    
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func wrapperDidPress(images: [UIImage]) {
        
    }
    
    func doneButtonDidPress(images: [UIImage]) {
        print("done")
        self.userSelectImages = images
        self.userPhoto.image = images[0]
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func cancelButtonDidPress() {
        
    }
    @IBAction func ImageSelectAction(sender: AnyObject) {
        let imagePickerController = ImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.imageLimit = 1
        Configuration.noImagesTitle = "Sorry! There are no images here!"
        self.presentViewController(imagePickerController, animated: true, completion: nil)
    }
    
    @IBAction func SignUpAction(sender: AnyObject) {
        
        let UUID:String = (UIDevice.currentDevice().identifierForVendor?.UUIDString)!
        
        //회원가입할 유저정보 집어넣음
        let user = PFUser()
        user.username = UUID
        user.password = UUID
        user["name"] = self.userNameField.text
        
        
        
        UIView.animateWithDuration(1.5, delay: 0, options: .CurveEaseIn, animations: {
            self.imageSelecBtn.alpha = 0
            self.userNameField.alpha = 0
            self.SignUpButton.alpha = 0
            self.userPhoto.alpha = 0
            self.progressView.alpha = 1
            }, completion: nil)
        
        user.signUpInBackgroundWithBlock({(succeeded: Bool, error: NSError?) -> Void in
            if let error = error{
                let errorString = error.userInfo["error"] as? NSString
                print(errorString)
            }
            else{ //회원가입 성공하면 로그인함
                print("회원가입 성공")
                PFUser.logInWithUsernameInBackground(UUID, password:UUID) {
                    (user: PFUser?, error: NSError?) -> Void in
                    if user != nil { //로그인 성공했을때
                        //이미지 세팅
                        let imageData = UIImageJPEGRepresentation(self.userPhoto.image!, 0.5)
                        
                        //let imageData = UIImagePNGRepresentation(self.userPhoto.image!)
                        let imageFile = PFFile(name:"image.png", data:imageData!)!
                        //이미지 업로드
                        imageFile.saveInBackgroundWithBlock({
                            (succeeded: Bool, error: NSError?) -> Void in
                            if succeeded == true{
                                let user = PFUser.currentUser()
                                user!.setObject(imageFile, forKey: "userPhoto")
                                user?.saveInBackground()
                            }
                            else
                            {
                                print("이미지 업로드 실패: \(error)") // 이미지 업로드 실패
                            }
                            }, progressBlock: { //프로세스 블럭 체크
                                (percentDone: Int32) -> Void in
                                self.progressView.setProgress(Float(percentDone) / 100, animated: true)
                                print(percentDone)
                                    if percentDone == 100{self.performSegueWithIdentifier("FromSignToMain", sender: self)
                                    }
                        })
                    } else { //회원가입 실패했을때
                        print(error)
                    }
                }
            }
            })
        
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
