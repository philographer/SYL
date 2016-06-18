//
//  DetailViewController.swift
//  syl
//
//  Created by 유호균 on 2016. 4. 22..
//  Copyright © 2016년 timeros. All rights reserved.
//

import UIKit
import Parse
import Mapbox
import SwiftDate
import Toucan

class DetailViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UITextViewDelegate, MGLMapViewDelegate{
    
    @IBOutlet weak var deleteBtn: UIButton!
    @IBOutlet var nameOfArticle: UILabel!
    @IBOutlet var tableView: UITableView!
    var article:PFObject!
    var comments:[PFObject!] = []
    var category:String!
    var postId:String!
    var authorNick:String!
    var nameArticle: String?
    var name: String?
    var myName: String?
    @IBOutlet weak var actibityIndc: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        tableView.estimatedRowHeight = 590
        tableView.rowHeight = UITableViewAutomaticDimension
        print("view loaded")
        self.hideKeyboardWhenTappedAround()
        self.viewUpByKeyboard()
        tableView.tableFooterView = UIView()
        
        let nowPost = self.article
        nowPost.fetchIfNeededInBackgroundWithBlock {
            (post: PFObject?, error: NSError?) -> Void in
            self.postId = post?.objectId!
            print("\(self.postId)포스트 아이디")
        }
        
        self.nameOfArticle.text = self.nameArticle
        
        
        /* 실제 아이디
        let nowUser = PFUser.currentUser()! as PFUser
        nowUser.fetchIfNeededInBackgroundWithBlock {
            (user: PFObject?, error: NSError?) -> Void in
            print(user)
            if let nickname = user?["nickname"]{
                self.authorNick = nickname as! String
                print("\(self.authorNick)유져 아이디")
            }
        }
        */
        
        
        //여기 수정
        //let indexPath = NSIndexPath(forItem: 0, inSection: 0)
        //let firstCell = self.tableView.cellForRowAtIndexPath(indexPath) as! DetailFirstCell
        //firstCell.textView.delegate = self
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func backButtonAction(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
        self.view.endEditing(true)
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 3;
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0,1: //1,2번째
            return 1
        case 2:
            return self.comments.count
        default:
            return 1
        }
    }
    
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        
        
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 1: //2번째
            let cell = tableView.dequeueReusableCellWithIdentifier("DetailSecondCell", forIndexPath: indexPath) as! DetailSecondCell
            //print("댓글 쓰기 불려짐")
            cell.article = article
            //print(article)
            //cell.authorNick = article[""]
            //cell.authorNick = article["authorNick"] as? String
            cell.postId = self.postId
            cell.separatorInset = UIEdgeInsetsMake(0.0, 10000, 0.0, cell.bounds.size.width)
            
            //print("name is \(self.name)")
            //print("author Nick is \(self.myName)")
            cell.authorNick = self.myName!
            //cell.authorNick = self.name
            //cell.authorNick = ""
            
            
            
            /*
            let nowPost = article
            nowPost.fetchIfNeededInBackgroundWithBlock {
                (post: PFObject?, error: NSError?) -> Void in
                cell.postId = post?.objectId!
                print(cell.postId)
            }
            
            let nowUser = PFUser.currentUser()! as PFUser
            nowUser.fetchIfNeededInBackgroundWithBlock {
                (user: PFObject?, error: NSError?) -> Void in
                if let nickname = user?["nickName"]{
                    cell.authorNick = nickname as! String
                    print(cell.authorNick)
                }
            }
            */
            
            
            return cell
        case 2: //3번째
            let cell = tableView.dequeueReusableCellWithIdentifier("DetailThirdCell", forIndexPath: indexPath) as! DetailThirdCell
            
            cell.textField.text = comments[indexPath.row]["comment"] as! String
            // print("코멘트 불려짐")
            
            let nowUser = comments[indexPath.row]["user"] as! PFObject
            
            print(nowUser)
            dispatch_async(dispatch_get_main_queue(), {
                nowUser.fetchIfNeededInBackgroundWithBlock {
                    (user: PFObject?, error: NSError?) -> Void in
                    if let nowPhoto = user?["userPhoto"]{
                        let unwrapPhoto = nowPhoto as! PFFile
                        cell.userImage.kf_setImageWithURL(NSURL(string: unwrapPhoto.url!)!)
                    }
                    else{
                        cell.userImage.image = UIImage(named: "default-user2")
                    }
                    if let userName = user?["nickname"]{
                        cell.userName.text = userName as? String
                        
                    }
                }
            })
            
            
            let stringDate = (comments[indexPath.row].createdAt!).toNaturalString(NSDate(), inRegion: .None, style: FormatterStyle(style: .Abbreviated, max: 1))!
            
            cell.time.text = stringDate + "전"
            
            
            
            
            //print("코멘트 불려짐")
            return cell
        default: //1번째
            let cell = tableView.dequeueReusableCellWithIdentifier("DetailFirstCell", forIndexPath: indexPath) as! DetailFirstCell
            //날짜 파싱
            /*
            let dateFormatter = NSDateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            let writeDate = dateFormatter.stringFromDate(article.createdAt!)
            */
        
            
            let stringDate = (article.createdAt!).toNaturalString(NSDate(), inRegion: .None, style: FormatterStyle(style: .Abbreviated, max: 1))!
            cell.userName.text = self.name
            cell.textView.text = article["content"] as! String
            cell.shareCount.text = String(article["shareCount"] as! Int)
            cell.commentCount.text = String(article["commentCount"] as! Int)
            cell.userTime.text = String(stringDate + "전")
            cell.mapView.delegate = self
            if let locationString = article["locationString"]{
                cell.userAddress.text = locationString as? String
            }
            
            let pfPoint = article["location"] as! PFGeoPoint
            let center = CLLocationCoordinate2D(latitude: pfPoint.latitude, longitude: pfPoint.longitude)
            
            let pin = MGLPointAnnotation()
            pin.coordinate = center
            cell.mapView.addAnnotation(pin)
            cell.mapView.setCenterCoordinate(center, zoomLevel: 12, animated: false)
            cell.mapView.attributionButton.hidden = true
            cell.mapView.styleURL = MGLStyle.lightStyleURL()
            cell.separatorInset = UIEdgeInsetsMake(0.0, 10000, 0.0, cell.bounds.size.width)
            //cell.selectionStyle = .None
            
            
            /*
            let point = MGLPointAnnotation()
            let center = article["location"] as! PFGeoPoint
            let cllocation = CLLocationCoordinate2D(latitude: 37.4542478, longitude: 126.7132015)
            let originalCenter = CLLocationCoordinate2D(latitude: 37, longitude: 126)
            cell.mapView.setCenterCoordinate(originalCenter, zoomLevel: 12, animated: false)
            point.coordinate = cllocation
            cell.mapView.addAnnotation(point)
             */
            if let image = article["image"]{
                let unwrapPhoto = image as! PFFile
                cell.userPhoto!.kf_setImageWithURL(NSURL(string: unwrapPhoto.url!)!, placeholderImage: UIImage(named: "placeholderImage") ,completionHandler:{(image, error, cacheType, imageURL) -> () in
                    
                })
            }else{
                //cell.imageConstraint.active = false
                cell.userPhoto.hidden = true
                //print("hidden")
            }
            
            //유져정보 가져옴
            let nowUser = article["user"] as! PFObject
            nowUser.fetchIfNeededInBackgroundWithBlock {
                (user: PFObject?, error: NSError?) -> Void in
                if let nowPhoto = user?["userPhoto"]{
                    _ = nowPhoto as! PFFile
                    //print(unwrapPhoto.url)
                    //cell.userImage.kf_setImageWithURL(NSURL(string: unwrapPhoto.url!)!)
                    
                }
                else{
                    //cell.userImage.image = UIImage(named: "default-uesr")
                    //cell.userImage.image = UIImage(named: "default-user2")
                    print("글쓴이 이미자가 없어서 넣어줬음")
                }
                
                
                switch self.category {
                case "medical":
                cell.userImage.image = UIImage(named: "medical_icon")
                case "missing":
                cell.userImage.image = UIImage(named: "missing_icon")
                case "help":
                cell.userImage.image = UIImage(named: "help_icon")
                case "supply":
                cell.userImage.image = UIImage(named: "supply_icon")
                case "other":
                cell.userImage.image = UIImage(named: "other_icon")
                default:
                cell.userImage.image = UIImage(named: "other_icon")
                }
            }
            //print("메인부분 불려짐")
            cell.selectionStyle = .None
            return cell
        }
    }
    
    
    
    @IBAction func test(sender: AnyObject) {
        //let firstIndexPath = NSIndexPath(forItem: 0, inSection: 0)
        //let firstSection = self.tableView.cellForRowAtIndexPath(firstIndexPath)
        //print(firstSection)
    }
    
    func mapView(mapView: MGLMapView, imageForAnnotation annotation: MGLAnnotation) -> MGLAnnotationImage? {
        // Try to reuse the existing ‘pisa’ annotation image, if it exists
        var annotationImage = mapView.dequeueReusableAnnotationImageWithIdentifier("pin")
        
        //let thisCategory = self.category
        
        //print(thisCategory)
        
        if annotationImage == nil {
            // Leaning Tower of Pisa by Stefan Spieler from the Noun Project
            var image:UIImage!
            
            
            
            switch self.category {
            case "missing":
                print("missing marker")
                image = Toucan(image: UIImage(named: "missing_marker")!).resize(CGSize(width: 30, height: 30)).image
            case "supply":
                print("supply marker")
                image = Toucan(image: UIImage(named: "supply_marker")!).resize(CGSize(width: 30, height: 30)).image
            case "help":
                print("help marker")
                image = Toucan(image: UIImage(named: "help_marker")!).resize(CGSize(width: 30, height: 30)).image
            case "medical":
                print("medical marker")
                image = Toucan(image: UIImage(named: "medical_marker")!).resize(CGSize(width: 30, height: 30)).image
            case "other":
                print("other marker")
                image = Toucan(image: UIImage(named: "other_marker")!).resize(CGSize(width: 30, height: 30)).image
            default:
                print("default marker")
                image = Toucan(image: UIImage(named: "other_marker")!).resize(CGSize(width: 30, height: 30)).image
            }
            // The anchor point of an annotation is currently always the center. To
            // shift the anchor point to the bottom of the annotation, the image
            // asset includes transparent bottom padding equal to the original image
            // height.
            //
            // To make this padding non-interactive, we create another image object
            // with a custom alignment rect that excludes the padding.
            image = image.imageWithAlignmentRectInsets(UIEdgeInsetsMake(0, 0, image.size.height/2, 0))
            
            // Initialize the ‘pisa’ annotation image with the UIImage we just loaded
            annotationImage = MGLAnnotationImage(image: image, reuseIdentifier: "pin")
        }
        
        return annotationImage
    }
 
    @IBAction func deleteAction(sender: AnyObject) {
        let alertView = SCLAlertView()
        alertView.addButton("삭제하기", action: {
            let query = PFQuery(className:"article")
            query.getObjectInBackgroundWithId(self.article.objectId!) {
                (thisArticle: PFObject?, error: NSError?) -> Void in
                if error != nil {
                    print(error)
                } else if let thisArticle = thisArticle {
                    thisArticle.deleteInBackground()
                    self.dismissViewControllerAnimated(true, completion: {});
                }
            }
        })
        alertView.addButton("취소") {
            print("취소")
        }
        alertView.showCloseButton = false
        alertView.showError("삭제하기", subTitle: "삭제하시겠습니까?")
    }
    

    
    
    
}
