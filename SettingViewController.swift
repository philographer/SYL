//
//  SettingViewController.swift
//  syl
//
//  Created by 유호균 on 2016. 4. 15..
//  Copyright © 2016년 timeros. All rights reserved.
//

import UIKit
import ImagePicker
import Toucan
import Parse

class SettingViewController: UIViewController, ImagePickerDelegate {
    
    @IBOutlet var editBtn: UIButton!
    @IBOutlet var imageSelect: UIButton!
    @IBOutlet var progressBar: UIProgressView!
    @IBOutlet var userPhoto: UIImageView!
    @IBOutlet var userEmail: UITextField!
    @IBOutlet var userPassword: UITextField!
    @IBOutlet var userNickname: UITextField!
    
    @IBOutlet weak var userLine: UIView!
    @IBOutlet weak var pwLine: UIView!
    
    
    var userSelectImages: [UIImage]?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
        self.viewUpByKeyboard()
        
        self.userNickname.borderStyle = UITextBorderStyle.None
        self.userPassword.borderStyle = UITextBorderStyle.None
        
        let nowUser = PFUser.currentUser()!
        nowUser.fetchIfNeededInBackgroundWithBlock {
            (user: PFObject?, error: NSError?) -> Void in
            if let nowPhoto = user?["userPhoto"]{
                let unwrapPhoto = nowPhoto as! PFFile
                self.userPhoto.kf_setImageWithURL(NSURL(string: unwrapPhoto.url!)!)
            }
            if let userName = user?["nickname"]{
                self.userNickname.text = userName as? String
            }
        }
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func BackButtonAction(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    @IBAction func imageSelect(sender: AnyObject) {
        let imagePickerController = ImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.imageLimit = 1
        Configuration.noImagesTitle = "Sorry! There are no images here!"
        self.presentViewController(imagePickerController, animated: true, completion: nil)
    }
    
    @IBAction func editAction(sender: AnyObject) {
        
        UIView.animateWithDuration(1.5, delay: 0, options: .CurveEaseIn, animations: {
            self.imageSelect.alpha = 0
            self.userPhoto.alpha = 0
            self.userNickname.alpha = 0
            self.userPassword.alpha = 0
            self.editBtn.alpha = 0
            self.userLine.alpha = 0
            self.pwLine.alpha = 0
            self.progressBar.alpha = 1
            }, completion: nil)
        
        let imageData = UIImagePNGRepresentation(Toucan(image: self.userPhoto.image!).resize(CGSize(width: 100, height: 100)).maskWithEllipse().image)
        //let imageData = UIImagePNGRepresentation(self.userPhoto.image!)
        let imageFile = PFFile(name:"image.png", data:imageData!)!
        //이미지 업로드
        imageFile.saveInBackgroundWithBlock({
            (succeeded: Bool, error: NSError?) -> Void in
            if succeeded == true{
                let user = PFUser.currentUser()
                user!["nickname"] = self.userNickname.text!
                user!.setObject(imageFile, forKey: "userPhoto")
                user?.saveInBackground()
            }
            else
            {
                print("이미지 업로드 실패: \(error)") // 이미지 업로드 실패
            }
            }, progressBlock: { //프로세스 블럭 체크
                (percentDone: Int32) -> Void in
                self.progressBar.setProgress(Float(percentDone) / 100, animated: true)
                print(percentDone)
                if percentDone == 100{self.dismissViewControllerAnimated(true, completion: nil)
                }
        })
        
    }
    
    func doneButtonDidPress(images: [UIImage]) {
        print("done")
        self.userSelectImages = images
        self.userPhoto.image = Toucan(image: images[0]).maskWithEllipse().image
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func cancelButtonDidPress() {
        
    }
    
    func wrapperDidPress(images: [UIImage]) {
        
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
