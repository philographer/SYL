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
import Alamofire
import SwiftyJSON

class WriteViewController: UIViewController, ImagePickerDelegate {

    @IBOutlet var MapView: UIView!
    @IBOutlet var writeButton: UIButton!
    @IBOutlet var textView: UITextView!
    @IBOutlet var progressBar: UIProgressView!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var nowLocationLabel: UILabel!
    @IBOutlet var categoryImg: UIImageView!
    @IBOutlet var userSelectImage: UIImageView!
    @IBOutlet var pickPhotoConstraint: NSLayoutConstraint!
    
    var map:MGLMapView?
    var category:String!
    var userSelectImages: [UIImage]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
        //self.viewUpByKeyboard()
        
        
        
        //mapbox
        map = MGLMapView(frame: self.MapView.bounds,styleURL: MGLStyle.lightStyleURL())
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
        
        //카테고리에 따라 타이틀 라벨 변함
        
        switch category {
        case "medical":
            self.titleLabel.text = "의료"
            //self.categoryImg.image = UIImage(named: "medical_icon")
        case "missing":
            self.titleLabel.text = "실종"
            //self.categoryImg.image = UIImage(named: "missing_icon")
        case "help":
            self.titleLabel.text = "도움"
            //self.categoryImg.image = UIImage(named: "help_icon")
        case "supply":
            self.titleLabel.text = "물자"
            //self.categoryImg.image = UIImage(named: "supply_icon")
        case "other":
            self.titleLabel.text = "기타"
            //self.categoryImg.image = UIImage(named: "other_icon")
        default:
            self.titleLabel.text = "기타"
            //self.categoryImg.image = UIImage(named: "other_icon")
        }
        
        //현재 위치 요청
        if let Location = self.map!.userLocation{
            if let myLocation:CLLocationCoordinate2D = Location.coordinate{
                let alertView = SCLAlertView()
                alertView.showCloseButton = false
                alertView.addButton("확인", action: {
                    
                })
                
                let latitude = myLocation.latitude
                let longitude = myLocation.longitude
                
                print("latitude is \(Double(latitude))")
                print("longitude is \(Double(longitude))")
                Alamofire.request(.GET, "https://apis.daum.net/local/geo/coord2addr?apikey=4114464a2e37e1b9cca0145006f8a366&longitude=\(Double(longitude))&latitude=\(Double(latitude))&inputCoordSystem=WGS84&output=json", parameters: nil, encoding: .JSON).responseJSON{
                    response in
                    print(response)
                    switch response.result {
                    case .Success:
                        if let value = response.result.value {
                            let json = JSON(value)
                            //self.nowLocationLabel.text = json["fullName"].stringValue
                        }
                    case .Failure(let error):
                        alertView.showError("주소 찾기 에러", subTitle: "현재 주소를 찾을 수 없습니다.\(error) GPS설정을 확인해 주세요")
                    }
                }
            }
        }
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(UIViewController.keyboardWillShow(_:)), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(UIViewController.keyboardWillHide(_:)), name: UIKeyboardWillHideNotification, object: nil)
        
        print("category \(category)")
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBAction func WriteAction(sender: AnyObject) {
        let alertView = SCLAlertView()
        alertView.showCloseButton = false
        alertView.addButton("확인", action: {
            
        })
        
        
        if let userLocation = self.map?.userLocation{
            if let userRealLocation = userLocation.location{
                UIView.animateWithDuration(1, animations: {self.progressBar.alpha = 1}, completion: nil)
                
                let latitude:Double = userRealLocation.coordinate.latitude
                let longitude:Double = userRealLocation.coordinate.longitude
                var locationString:String! = ""
                let articleObject = PFObject(className: "article")
                
                //유져 닉네임 꺼내오기
                let thisUser = PFUser.currentUser()!
                thisUser.fetchIfNeededInBackgroundWithBlock {
                    (user: PFObject?, error: NSError?) -> Void in
                    if let userName = user?["nickname"]{
                        let point = PFGeoPoint(latitude: latitude, longitude: longitude)
                        articleObject["content"] = self.textView.text
                        articleObject["user"] = PFUser.currentUser()
                        articleObject["authorId"] = PFUser.currentUser()?.objectId
                        articleObject["authorNick"] = userName as? String
                        articleObject["location"] = point
                        articleObject["category"] = self.category
                        articleObject["shareCount"] = 0
                        articleObject["commentCount"] = 0
                        articleObject["numOfPhotos"] = 0
                        Alamofire.request(.GET, "https://apis.daum.net/local/geo/coord2addr?apikey=4114464a2e37e1b9cca0145006f8a366&longitude=\(longitude)&latitude=\(latitude)&inputCoordSystem=WGS84&output=json", parameters: nil, encoding: .JSON).responseJSON{
                            response in
                            print(response)
                            switch response.result {
                            case .Success:
                                if let value = response.result.value {
                                    let json = JSON(value)
                                    print("JSON: \(json)")
                                    locationString = json["fullName"].stringValue
                                    articleObject["locationString"] = locationString
                                    if let userImage = self.userSelectImage.image{
                                        let imageData = UIImageJPEGRepresentation(userImage, 0.1)
                                        if let imageFile = PFFile(name:"image.jpg", data:imageData!){
                                            //이미지 업로드
                                            imageFile.saveInBackgroundWithBlock({
                                                (succeeded: Bool, error: NSError?) -> Void in
                                                if succeeded == true{
                                                    articleObject["image"] = imageFile
                                                    articleObject["numOfPhotos"] = 1
                                                    articleObject.saveInBackgroundWithBlock{
                                                        (success: Bool, error: NSError?) -> Void in
                                                        if(success){
                                                            self.dismissViewControllerAnimated(true, completion: nil)
                                                        }
                                                        else{
                                                            alertView.showError("게시글 업로드 에러", subTitle: "\(error!)")
                                                        }
                                                    }
                                                    
                                                }
                                                else
                                                {
                                                    alertView.showError("이미지 업로드 에러", subTitle: "\(error!)")
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
                                                alertView.showError("게시글 업로드 에러", subTitle: "\(error!)")
                                            }
                                        }
                                    }
                                }
                            case .Failure(let error):
                                alertView.showError("주소 찾기 에러", subTitle: "현재 주소를 찾을 수 없습니다.\(error) GPS설정을 확인해 주세요")
                            }
                        }
                    }
                }
                //이미지 세팅
                
                
            }
        }//user location 찾음 true
        else{
            alertView.showError("GPS 에러", subTitle: "현재 위치를 찾을 수 없습니다.\n GPS설정을 확인해 주세요")
        }
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

    @IBAction func myLocation(sender: AnyObject) {
        if let Location = self.map!.userLocation{
            if let myLocation:CLLocationCoordinate2D = Location.coordinate{
                self.map!.setCenterCoordinate(myLocation, zoomLevel: 15, animated: true)
                
                print(myLocation.latitude)
                print(myLocation.longitude)
            }
        }
    }
    
    override func keyboardWillShow(notification: NSNotification) {
        if self.view.tag == 0{
            if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.CGRectValue() {
                print("키보드 올라가기전 y\(self.view.frame.origin.y)")
                
                UIView.animateWithDuration(0.5, animations: {
                self.pickPhotoConstraint.constant += keyboardSize.height
                })
                
                self.view.tag = 1
            }
        }
        
    }
    
    override func keyboardWillHide(notification: NSNotification) {
        if self.view.tag == 1{
            UIView.animateWithDuration(0.5, animations: {
                self.pickPhotoConstraint.constant = 20
            })
            self.view.tag = 0
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
