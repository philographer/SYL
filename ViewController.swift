//
//  ViewController.swift
//  syl
//
//  Created by 유호균 on 2016. 4. 12..
//  Copyright © 2016년 timeros. All rights reserved.
//

import UIKit
import Parse
import Mapbox
import SwiftyJSON
import Toucan
import Kingfisher
import SwiftDate
import Alamofire

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, KCFloatingActionButtonDelegate, MGLMapViewDelegate {
    
    //LayOut Outlet
    
    //map
    @IBOutlet weak var MapView: UIView!
    
    //view
    @IBOutlet weak var ArticleView: UIView!
    @IBOutlet var tableView: UITableView!
    
    //image
    @IBOutlet weak var daumLogo: UIImageView!
    
    //Button
    @IBOutlet var alarmBtn: MIBadgeButton!
    @IBOutlet var myLocationBtn: UIButton!
    @IBOutlet weak var floatBtn: KCFloatingActionButton!
    @IBOutlet weak var collapseBtn: UIButton!
    
    //Constraint
    @IBOutlet weak var collapsibleConstraint: NSLayoutConstraint!
    @IBOutlet var myLocationBtnConstraint: NSLayoutConstraint!
    @IBOutlet weak var collapseBtnConstraint: NSLayoutConstraint!
    @IBOutlet var floatBtnConstraint: NSLayoutConstraint!
    @IBOutlet var floatBtnConstraintBottom: NSLayoutConstraint!
    @IBOutlet weak var activityIndc: UIActivityIndicatorView!
    
    //KFloat Button 맵, 아티클, 뱃지, 마커
    var map:MGLMapView!
    var article:[PFObject]!
    var badgeNum:Int!
    var markers:[MGLPointAnnotation] = []
    var myName:String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //테이블 뷰 예상높이, 동적 디멘션
        tableView.estimatedRowHeight = 238
        tableView.rowHeight = UITableViewAutomaticDimension
        //테이블뷰 배경색
        self.tableView.backgroundColor = UIColor(red: 44/255, green: 43/255, blue: 43/255, alpha: 1)
        
        //mapbox
        map = MGLMapView(frame: self.MapView.bounds,
                             styleURL: MGLStyle.lightStyleURL())
        map.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        map.attributionButton.hidden = true
        self.MapView.addSubview(map)
        map.delegate = self
        //self.myName = "아트나비"
        
        //KFloat Button Add Item
        self.floatBtn.openAnimationType = KCFABOpenAnimationType.SlideDown
        self.floatBtn.addItem("기타", icon: UIImage(named: "other_btn")!, handler: {item in
            self.performSegueWithIdentifier("writeViewController", sender: 1)
            print("기타")}).buttonColor = UIColor.clearColor()
        self.floatBtn.addItem("실종", icon: UIImage(named: "missing_btn")!, handler: {item in
            self.performSegueWithIdentifier("writeViewController", sender: 2)
            print("실종")}).buttonColor = UIColor.clearColor()
        self.floatBtn.addItem("물자", icon: UIImage(named: "supply_btn")!, handler: {item in
            self.performSegueWithIdentifier("writeViewController", sender: 3)
            print("물자")}).buttonColor = UIColor.clearColor()
        self.floatBtn.addItem("구조", icon: UIImage(named: "help_btn")!, handler: {item in
            self.performSegueWithIdentifier("writeViewController", sender: 4)
            print("구조")}).buttonColor = UIColor.clearColor()
        self.floatBtn.addItem("의료", icon: UIImage(named: "medical_btn")!, handler: {item in
            self.performSegueWithIdentifier("writeViewController", sender: 5)
            print("의료")}).buttonColor = UIColor.clearColor()
        
        //글쓰기 버튼 이미지
        self.floatBtn.buttonImage = UIImage(named: "write_btn")
        
        
    }
    
    
    override func viewWillAppear(animated: Bool) {
        //알람버튼 뱃지 숨기기
        self.alarmBtn.badgeBackgroundColor = UIColor.clearColor()
        self.alarmBtn.badgeTextColor = UIColor.clearColor()
        if(PFUser.currentUser() == nil){ //회원가입 안 했으면 메인으로
            print("가입하지 않은 유져")
            dispatch_async(dispatch_get_main_queue()){
                [unowned self] in
                    self.performSegueWithIdentifier("FromMainToSign", sender: self)
            }
        }
        else{ //회원가입 했으면 유져트래킹모드
            map!.userTrackingMode = MGLUserTrackingMode.FollowWithHeading
            //테이블뷰 갱신
            self.activityIndc.hidden = false
            self.activityIndc.startAnimating()
            self.reloadData()
            let nowUser = PFUser.currentUser()! as PFUser
            nowUser.fetchIfNeededInBackgroundWithBlock {
                (user: PFObject?, error: NSError?) -> Void in
                print(user)
                if let nickname = user?["nickname"]{
                    self.myName = nickname as? String
                    print("내이름\(self.myName)")
                }else{
                    print("아이디 가져오기 에러error")
                }
            }
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        //뷰가 사라질때
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        //글쓰기 모드로 이동할때 카테고리 지정
        if segue.identifier == "writeViewController"{
            let senderInt = sender as! Int
            let destController = segue.destinationViewController as! WriteViewController
            switch senderInt {
            case 1:
                destController.category = "other"
            case 2:
                destController.category = "missing"
            case 3:
                destController.category = "supply"
            case 4:
                destController.category = "help"
            case 5:
                destController.category = "medical"
            default:
                break
            }
            print("선택한 카테고리 :\(senderInt)")
        }
        
        if segue.identifier == "FromMainToDetail"{ //메인 -> 디테일 segue
            let destController = segue.destinationViewController as! DetailViewController
            destController.article = self.article[sender!.row]
            //print(self.article[sender!.row]["authorNick"])
            
            
            destController.nameArticle = (self.article[sender!.row]["authorNick"] as? String)! + "님의 글"
            destController.name = self.article[sender!.row]["authorNick"] as? String
            
            destController.myName = self.myName
            
            
 
            

            let query = PFQuery(className: "comment")
            query.whereKey("article", equalTo: self.article[sender!.row])
            query.orderByAscending("createdAt")
            query.findObjectsInBackgroundWithBlock{
                (objects: [PFObject]?, error: NSError?) -> Void in
                if let error = error{
                    SCLAlertView().showError("Comment Error", subTitle: "코멘트 가져오기 에러 \(error)")
                }
                else{
                    destController.comments = objects!
                    let section = NSIndexSet(index: 2)
                    destController.tableView.reloadSections(section, withRowAnimation: .Automatic)
                }
            }
            destController.category = self.article[sender!.row]["category"] as! String
        }
        
        if segue.identifier == "FromMainToAlarm"{ //메인 -> 알람 segue
            let destController = segue.destinationViewController as! AlamViewController
            destController.myName = self.myName
            let query = PFQuery(className: "alarm")
            query.whereKey("toUser", equalTo: PFUser.currentUser()!)
            query.orderByDescending("createdAt")
            query.findObjectsInBackgroundWithBlock{
                (objects: [PFObject]?, error: NSError?) -> Void in
                if let error = error{
                    SCLAlertView().showError("Comment Error", subTitle: "알람 가져오기 에러 \(error)")
                }
                else{
                    //print("알람 가져왔다 \(objects)")
                    destController.alarms = objects!
                    
                    let section = NSIndexSet(index: 0)
                    destController.tableView.reloadSections(section, withRowAnimation: .Automatic)
                }
            }
            
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func mapView(mapView: MGLMapView, annotationCanShowCallout annotation: MGLAnnotation) -> Bool {
        // Always try to show a callout when an annotation is tapped.
        return true
    }
    
    // MARK: - Table view data source
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.article.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        //셀
        let cell = tableView.dequeueReusableCellWithIdentifier("ArticleCell", forIndexPath: indexPath) as! ArticleCell
        
        //간단한 날짜(ex 1분전, 12시간전, 3일전)
        let stringDate = (article[indexPath.row].createdAt!).toNaturalString(NSDate(), inRegion: .None, style: FormatterStyle(style: .Abbreviated, max: 1))!
        
        //실제 닉네임 꺼내오기
        /*
        dispatch_async(dispatch_get_main_queue(), {
            let thisUser = self.article[indexPath.row]["user"] as! PFUser
            thisUser.fetchIfNeededInBackgroundWithBlock {
                (user: PFObject?, error: NSError?) -> Void in
                if let userName = user?["nickname"]{
                    cell.foregroundName.text = userName as? String
                }
            }
            //cell.foregroundName.text = String(indexPath.row)
        })
        */
        cell.foregroundName.text = article[indexPath.row]["authorNick"] as? String
        cell.backgroundColor = UIColor(red: 44/255, green: 43/255, blue: 43/255, alpha: 1)
        cell.foregroundContent.delegate = self
        
        let style = NSMutableParagraphStyle()
        style.lineSpacing = 10
        let attributes = [NSParagraphStyleAttributeName : style]
        let contentText:String = article[indexPath.row]["content"] as! String
        cell.foregroundContent.attributedText = NSAttributedString(string: contentText, attributes:attributes)
        cell.foregroundContent.textColor = UIColor.whiteColor()
        cell.foregroundContent.font = UIFont(name: "HelveticaNeue", size: 17.0)
        
        cell.shareCount.text = String(article[indexPath.row]["shareCount"] as! Int)
        cell.commentCount.text = String(article[indexPath.row]["commentCount"] as! Int)
        
        cell.foregroundTime.text = String(stringDate+" 전")
        cell.foregroundAddress.text = String(article[indexPath.row]["locationString"] as! String)
        
        cell.commentBtn.tag = indexPath.row
        cell.shareBtn.tag = indexPath.row
        cell.commentBtn.addTarget(self, action: #selector(self.commentAction(_:)), forControlEvents: .TouchUpInside)
        cell.shareBtn.addTarget(self, action: #selector(self.shareAction(_:)), forControlEvents: .TouchUpInside)
        
        switch article[indexPath.row]["category"] as! String {
        case "medical":
            cell.foregroundImage.image = UIImage(named: "medical_icon")
        case "supply":
            cell.foregroundImage.image = UIImage(named: "supply_icon")
        case "help":
            cell.foregroundImage.image = UIImage(named: "help_icon")
        case "missing":
            cell.foregroundImage.image = UIImage(named: "missing_icon")
        case "other":
            cell.foregroundImage.image = UIImage(named: "other_icon")
        default:
            cell.foregroundImage.image = UIImage(named: "other_icon")
        }
        return cell
    }
    
    // MARK: Table vie delegate
    
     func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        performSegueWithIdentifier("FromMainToDetail", sender: indexPath)   
    }
    
    @IBAction func collapseAction(sender: AnyObject) {
        
        //열려있으면 접기
        if(collapsibleConstraint.constant == 315)
        {
            UIView.animateWithDuration(0.3, delay: 0, options: .CurveEaseIn, animations: {
                self.myLocationBtn.alpha = 0
                //self.myLocationBtnConstraint.constant = 0
                self.floatBtnConstraint.active = false
                //self.MapView.alpha = 0
                self.MapView.alpha = 1
                
                //print(self.collapseBtnConstraint.constant)
                self.collapseBtnConstraint.constant = 67 //탑과 버튼사이
                self.collapsibleConstraint.constant = 8
                self.collapseBtn.hidden = true
                //self.collapseBtn.transform = CGAffineTransformMakeRotation(CGFloat(M_PI))
                self.view.layoutIfNeeded()}, completion: {
                    finished in print("지도 접기")
                    self.floatBtn.openAnimationType = KCFABOpenAnimationType.SlideUp
                    UIView.animateWithDuration(0.1, delay: 0, options: .CurveEaseIn, animations: {
                        self.collapseBtn.hidden = false
                        self.collapseBtn.setImage(UIImage(named: "down"), forState: .Normal)
                    }, completion:  nil)
            })
            
        }
            
        //닫혀있으면 열기
        else if(collapsibleConstraint.constant == 8){
            UIView.animateWithDuration(0.3, delay: 0, options: .CurveEaseIn, animations: {
                self.floatBtnConstraint.active = true
                self.myLocationBtn.alpha = 1
                self.MapView.alpha = 1
                self.collapseBtn.hidden = true
                self.collapseBtnConstraint.constant = 357
                self.collapsibleConstraint.constant = 315
                //self.collapseBtn.transform = CGAffineTransformMakeRotation(CGFloat(M_PI*2))
                
                self.view.layoutIfNeeded()}, completion: {
                    finished in print("지도 펴기")
                    self.floatBtn.openAnimationType = KCFABOpenAnimationType.SlideDown
                    UIView.animateWithDuration(0.1, delay: 0, options: .CurveEaseIn, animations: {
                        self.collapseBtn.hidden = false
                        self.collapseBtn.setImage(UIImage(named: "up"), forState: .Normal)
                        }, completion:  nil)
                    //self.view.removeConstraint(floatBtnConstraint)
            })
        }
    }
    
    func commentAction(sender: AnyObject?){
        let indexPath = NSIndexPath(forItem: sender!.tag, inSection: 0)
        performSegueWithIdentifier("FromMainToDetail", sender: indexPath)
    }
    
    func shareAction(sender: AnyObject?){
        print("공유하기 버튼 딱 눌렀을때 태그\(sender!.tag)")
        let alertView = SCLAlertView()
        alertView.addButton("공유하기", action: {
            print("공유될 인덱스 \(sender!.tag)")
            
            let existingObject = self.article[sender!.tag]
            let newObject = PFObject(className: "article")
            
            print(existingObject)
            
            
            
            //기존
            newObject["user"] = PFUser.currentUser()
            newObject["content"] = existingObject["content"]
            newObject["authorNick"] = self.myName
            newObject["authorId"] = PFUser.currentUser()?.objectId!
            
            newObject["location"] = existingObject["location"]
            
            if let image = existingObject["image"]{
                newObject["numOfPhotos"] = 1
                newObject["image"] = image
                
                let postPhotoObject = PFObject(className: "PostPhoto")
                let nowData = NSDate().toString()!
                newObject["photoKey"] = nowData
                postPhotoObject["key"] = nowData
                postPhotoObject["photoFile"] = image
                postPhotoObject.saveInBackground()
            }else{
                newObject["numOfPhotos"] = 0
            }
            
            //newObject["shareCount"] = existingObject["shareCount"] as! Int + 1
            newObject["shareCount"] = 0
            newObject["commentCount"] = 0
            newObject["category"] = existingObject["category"]
            newObject["locationString"] = existingObject["locationString"]
            
            newObject.saveInBackgroundWithBlock({
                (succeeded: Bool, error: NSError?) -> Void in
                if succeeded == true{

                    let succesView = SCLAlertView()
                    succesView.showCloseButton = false
                    succesView.addButton("확인", action: {})
                    succesView.showSuccess("공유하기", subTitle: "공유하셨습니다.")
                    self.reloadData()
                    
                    //공유 알람 전송
                    //자기가 아니면
                    let userName = (existingObject["user"] as! PFUser).username!
                    let myName = PFUser.currentUser()!.username!
                    
                    //알람 보냄
                    if userName != myName{
                        let alarmObject = PFObject(className: "alarm")
                        alarmObject["fromUser"] = PFUser.currentUser()
                        alarmObject["toUser"] = existingObject["user"]
                        alarmObject["read"] = false
                        alarmObject["article"] = existingObject
                        alarmObject["category"] = 1
                        alarmObject.saveInBackgroundWithBlock{
                            (successed: Bool, error: NSError?) -> Void in
                            if successed == true{
                                print("알람 성공적으로 전송")
                            }else{
                                print("알람 전송 실패")
                            }
                        }
                    }
                    
                }
                else{
                    let errorView = SCLAlertView()
                    errorView.showCloseButton = false
                    errorView.addButton("확인", action: {})
                    errorView.showError("공유하기", subTitle: "공유 에러.")
                }
                
            })
            existingObject["shareCount"] = existingObject["shareCount"] as! Int + 1
            existingObject.saveInBackgroundWithBlock({
                (succeeded: Bool, error: NSError?) -> Void in
                if succeeded == true{
                    print("증가완료")
                }
                else{
                    print("공유숫자 증가 에러")
                }
            })
        })
        
        
        alertView.addButton("취소") {
            print("취소")
        }
        alertView.showCloseButton = false
        alertView.showEdit("공유하기", subTitle: "공유하시겠습니까?")
    }
    
    func mapView(mapView: MGLMapView, tapOnCalloutForAnnotation annotation: MGLAnnotation) {
        // Optionally handle taps on the callout
        print("Tapped the callout for: \(annotation)")
        
        // Hide the callout
        //self.mapView.deselectAnnotation(annotation, animated: true)
    }
    
    func mapView(mapView: MGLMapView, didSelectAnnotation annotation: MGLAnnotation) {
        self.map.deselectAnnotation(annotation, animated: false)
        
        //자주 에러남
        
        if let titleInt:Int = Int(annotation.title!!){
            let indexPath = NSIndexPath(forItem: titleInt, inSection: 0)
            performSegueWithIdentifier("FromMainToDetail", sender: indexPath)
        }
        
        
    }
    
    func reloadData(){
        
        //table 초기화
        self.article = []
        self.tableView.dataSource = self
        self.tableView.delegate = self
        //self.tableView.reloadData()
        
        var query = PFQuery(className: "article")
        query.orderByDescending("createdAt")
        query.findObjectsInBackgroundWithBlock{
            (objects: [PFObject]?, error: NSError?) -> Void in
            if let error = error{
                print("Article 가져오기 오류\(error)")
            }
            else{
                print("정보 가져옴")
                print(objects!)
                
                if self.article != objects!{
                    self.article = objects!
                    self.tableView.dataSource = self
                    self.tableView.delegate = self
                    self.tableView.reloadData()
                    self.activityIndc.hidden = true
                    self.activityIndc.stopAnimating()
                    //let firstIdx = NSIndexSet(index: 0)
                    //self.tableView.reloadSections(firstIdx, withRowAnimation: .Automatic)
                    self.tableView.tableFooterView = UIView()
                    //애닌메이션 없음
                    //self.tableView.reloadData()
                    self.markers.removeAll()
                    if self.article.count != 0{
                        for i in 0...self.article.count-1{
                            //let
                            let pfPoint = self.article[i]["location"] as! PFGeoPoint
                            let cllocation = CLLocationCoordinate2D(latitude: pfPoint.latitude, longitude: pfPoint.longitude)
                            let point = MGLPointAnnotation()
                            point.coordinate = cllocation
                            //point.performSelector(#selector(self.moveToDetail(_:)))
                            point.title = String(i)
                            point.subtitle = "Welcome to my marker"
                            
                            self.markers.append(point)
                            self.map?.addAnnotation(point)
                        }
                    }
                }
            }
        }
        
        query = PFQuery(className: "alarm")
        query.orderByDescending("createdAt")
        query.whereKey("toUser", equalTo: PFUser.currentUser()!)
        query.whereKey("read", equalTo: false)
        query.findObjectsInBackgroundWithBlock{
            (objects: [PFObject]?, error: NSError?) -> Void in
            if let error = error{
                print("Article 가져오기 오류\(error)")
            }
            else{
                print("뱃지정보 가져옴\(objects!.count)")
                self.alarmBtn.badgeString = "\(objects!.count)"
                if(objects!.count != 0){
                    self.alarmBtn.badgeEdgeInsets = nil
                    self.alarmBtn.badgeBackgroundColor = UIColor.redColor()
                    self.alarmBtn.badgeTextColor = UIColor.whiteColor()
                    print("왜 0이죠")
                }
            }
        }
    }
    func moveToDetail(sender: AnyObject?){
        print(sender)
    }
    
    @IBAction func myLocationAction(sender: AnyObject) {
        if let Location = map.userLocation{
            if let myLocation:CLLocationCoordinate2D = Location.coordinate{
                self.map.setCenterCoordinate(myLocation, zoomLevel: 15, animated: true)
            }
        }
    }
    func mapView(mapView: MGLMapView, imageForAnnotation annotation: MGLAnnotation) -> MGLAnnotationImage? {
        // Try to reuse the existing ‘pisa’ annotation image, if it exists
        var annotationImage = mapView.dequeueReusableAnnotationImageWithIdentifier("point")
        if annotationImage == nil {
            // Leaning Tower of Pisa by Stefan Spieler from the Noun Project
            var image:UIImage!
            print(annotation.title)
            image = Toucan(image: UIImage(named: "bin_marker")!).resize(CGSize(width: 20, height: 20)).image
            image = image.imageWithAlignmentRectInsets(UIEdgeInsetsMake(0, 0, image.size.height/2, 0))
            // Initialize the ‘pisa’ annotation image with the UIImage we just loaded
            annotationImage = MGLAnnotationImage(image: image, reuseIdentifier: "pin")
        }
        return annotationImage
    }
    
    /*
    func mapView(mapView: MGLMapView, imageForAnnotation annotation: MGLAnnotation) -> MGLAnnotationImage? {
        // Try to reuse the existing ‘pisa’ annotation image, if it exists
        var annotationImage = mapView.dequeueReusableAnnotationImageWithIdentifier("point")
        if annotationImage == nil {
            // Leaning Tower of Pisa by Stefan Spieler from the Noun Project
            var image:UIImage!
            
            image = Toucan(image: UIImage(named: "bin_marker")!).resize(CGSize(width: 30, height: 30)).image
            image = image.imageWithAlignmentRectInsets(UIEdgeInsetsMake(0, 0, image.size.height/2, 0))
            // Initialize the ‘pisa’ annotation image with the UIImage we just loaded
            annotationImage = MGLAnnotationImage(image: image, reuseIdentifier: "pin")
            }
        return annotationImage
    }
            */
        

    
    
    
    
 
    
    
    
}