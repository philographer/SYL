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
import Toucan

class SignUpViewController: UIViewController, ImagePickerDelegate {

    @IBOutlet var SignUpButton: UIButton!
    
    @IBOutlet var userPhoto: UIImageView!
    @IBOutlet var imageSelecBtn: UIButton!
    @IBOutlet var progressView: UIProgressView!
    
    @IBOutlet var userNicknameField: UITextField!
    @IBOutlet var userEmailField: UITextField!
    @IBOutlet var userPasswordField: UITextField!
    
    @IBOutlet var userBottom: UIView!
    @IBOutlet var nameBottom: UIView!
    @IBOutlet var passwordBottom: UIView!
    
    
    var userSelectImages: [UIImage]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
        self.viewUpByKeyboard()
        
        self.userNicknameField.borderStyle = UITextBorderStyle.None
        self.userEmailField.borderStyle = UITextBorderStyle.None
        self.userPasswordField.borderStyle = UITextBorderStyle.None
        
        
        /*
        var bottomLine = CALayer()
        bottomLine.frame = CGRectMake(0.0, userNicknameField.frame.height - 1, userNicknameField.frame.width, 1.0)
        bottomLine.backgroundColor = UIColor.whiteColor().CGColor
        userNicknameField.borderStyle = UITextBorderStyle.None
        userNicknameField.layer.addSublayer(bottomLine)
        
        bottomLine.frame = CGRectMake(0.0, userEmailField.frame.height - 1, userEmailField.frame.width, 1.0)
        bottomLine.backgroundColor = UIColor.whiteColor().CGColor
        userEmailField.borderStyle = UITextBorderStyle.None
        userEmailField.layer.addSublayer(bottomLine)
        
        bottomLine.frame = CGRectMake(0.0, userPasswordField.frame.height - 1, userPasswordField.frame.width, 1.0)
        bottomLine.backgroundColor = UIColor.whiteColor().CGColor
        userPasswordField.borderStyle = UITextBorderStyle.None
        userPasswordField.layer.addSublayer(bottomLine)
        */
        
        
        /*
        */
        
        // Do any additional setup after loading the view.
        
        
    }
    
    override func viewWillAppear(animated: Bool) {
        if (PFUser.currentUser() != nil){
            print("아이디 없음.")
            //self.performSegueWithIdentifier("FromSignToMain", sender: self)
            dispatch_async(dispatch_get_main_queue()){
                [unowned self] in
                self.performSegueWithIdentifier("FromSignToMain", sender: self)
            }
        }else{
            print("아이디 있음.")
        }
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
        self.userPhoto.image = Toucan(image: images[0]).maskWithEllipse().image
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
        self.view.endEditing(true)
        //회원가입할 유저정보 집어넣음
        let user = PFUser()
        user.username = self.userEmailField.text
        user.password = self.userPasswordField.text
        user["nickname"] = self.userNicknameField.text
        
        UIView.animateWithDuration(1.5, delay: 0, options: .CurveEaseIn, animations: {
            self.imageSelecBtn.alpha = 0
            self.userNicknameField.alpha = 0
            self.userPasswordField.alpha = 0
            self.userEmailField.alpha = 0
            self.SignUpButton.alpha = 0
            self.userPhoto.alpha = 0
            self.progressView.alpha = 1
            self.userBottom.alpha = 0
            self.nameBottom.alpha = 0
            self.passwordBottom.alpha = 0
            }, completion: nil)
        
        user.signUpInBackgroundWithBlock({(succeeded: Bool, error: NSError?) -> Void in
            let alertView = SCLAlertView()
            alertView.showCloseButton = false
            alertView.addButton("확인", action: {
                print("확인버튼")
                self.loadView()
            })
            
            if let error = error{
                let errorString = error.userInfo["error"] as? NSString
                alertView.showError("가입 에러", subTitle: String(errorString!))
            }
            else{ //회원가입 성공하면 로그인함
                print("회원가입 성공")
                PFUser.logInWithUsernameInBackground(self.userEmailField.text!, password:self.userPasswordField.text!) {
                    (user: PFUser?, error: NSError?) -> Void in
                    if user != nil { //로그인 성공했을때
                        //이미지 세팅
                        let imageData = UIImagePNGRepresentation(Toucan(image: self.userPhoto.image!).resize(CGSize(width: 200, height: 200)).maskWithEllipse().image)
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
                                alertView.showError("이미지 업로드 에러", subTitle: String("이미지 업로드 실패: \(error!)"))
                            }
                            }, progressBlock: { //프로세스 블럭 체크
                                (percentDone: Int32) -> Void in
                                self.progressView.setProgress(Float(percentDone) / 100, animated: true)
                                print(percentDone)
                                    if percentDone == 100{self.performSegueWithIdentifier("FromSignToMain", sender: self)
                                    }
                        })
                    } else { //회원가입 실패했을때
                        alertView.showError("회원가입 에러 에러", subTitle: String("회원가입 에러 에러: \(error!)"))
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
