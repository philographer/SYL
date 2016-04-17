//
//  WriteViewController.swift
//  syl
//
//  Created by 유호균 on 2016. 4. 15..
//  Copyright © 2016년 timeros. All rights reserved.
//

import UIKit
import Mapbox
import Parse
import ImagePicker

class WriteViewController: UIViewController, ImagePickerDelegate {

    @IBOutlet var MapView: UIView!
    @IBOutlet var writeButton: UIButton!
    @IBOutlet var textView: UITextView!
    @IBOutlet var progressBar: UIProgressView!
    
    var map:MGLMapView?
    var category:String!
    var userSelectImages: [UIImage]?
    @IBOutlet var userSelectImage: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
        self.viewUpByKeyboard()
        //mapbox
        map = MGLMapView(frame: self.MapView.bounds,
                                 styleURL: MGLStyle.lightStyleURL())
        let center = CLLocationCoordinate2D(latitude: 37.3815495, longitude: 126.6515717)
        
        map!.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        //set the map's center coordinate
        map!.setCenterCoordinate(center,zoomLevel: 12, animated: false)
        map!.userTrackingMode = MGLUserTrackingMode.FollowWithHeading
        self.MapView.addSubview(map!)
        map!.attributionButton.hidden = true
        self.writeButton.layer.zPosition = 99
        // Do any additional setup after loading the view.
        
        
        //키보드 닫기
        let gesture = UITapGestureRecognizer(target: self, action: #selector(self.endEditting(_:)))
        self.map!.addGestureRecognizer(gesture)
        
        //버튼 셰도우
        self.writeButton.layer.shadowColor = UIColor.blackColor().CGColor
        self.writeButton.layer.shadowOffset = CGSize(width: 5, height: 10)
        self.writeButton.layer.shadowRadius = 5
        self.writeButton.layer.shadowOpacity = 1.0
        
        
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBAction func WriteAction(sender: AnyObject) {
        UIView.animateWithDuration(1, animations: {self.progressBar.alpha = 1}, completion: nil)
        let latitude:Double = Double((self.map?.userLocation?.coordinate.latitude)!)
        let longitude:Double = Double((self.map?.userLocation?.coordinate.longitude)!)
        let point = PFGeoPoint(latitude: latitude, longitude: longitude)
        let articleObject = PFObject(className: "article")
        articleObject["content"] = self.textView.text
        articleObject["user"] = PFUser.currentUser()
        articleObject["location"] = point
        articleObject["category"] = self.category
        articleObject["voteCount"] = 0
        articleObject["commentCount"] = 0
        //이미지 세팅
        
        if let userImage = self.userSelectImage.image{
            let imageData = UIImageJPEGRepresentation(userImage, 0.1)
            if let imageFile = PFFile(name:"image.jpg", data:imageData!){
                //이미지 업로드
                imageFile.saveInBackgroundWithBlock({
                    (succeeded: Bool, error: NSError?) -> Void in
                    if succeeded == true{
                        articleObject["image"] = imageFile
                        articleObject.saveInBackgroundWithBlock{
                            (success: Bool, error: NSError?) -> Void in
                            if(success){
                                self.dismissViewControllerAnimated(true, completion: nil)
                            }
                            else{
                                print(error)
                            }
                        }
                        
                    }
                    else
                    {
                        print("이미지 업로드 실패: \(error)") // 이미지 업로드 실패
                    }
                    }, progressBlock: { //프로세스 블럭 체크
                        (percentDone: Int32) -> Void in
                        self.progressBar.setProgress(Float(percentDone) / 100, animated: true)
                        print(percentDone)
                })
            }
        }
        else{
            articleObject.saveInBackgroundWithBlock{
                (success: Bool, error: NSError?) -> Void in
                if(success){
                    self.dismissViewControllerAnimated(true, completion: nil)
                }
                else{
                    print(error)
                }
            }
        }
        print(self.map!.userLocation?.coordinate)
    }
    
    @IBAction func BackAction(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func wrapperDidPress(images: [UIImage]) {
        
    }
    
    func doneButtonDidPress(images: [UIImage]) {
        print("done")
        self.userSelectImages = images
        self.userSelectImage.image = images[0]
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
    
    func endEditting(sender:UITapGestureRecognizer){
        print("endEditting")
        self.view.endEditing(true)
        // do other task
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
