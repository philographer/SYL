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

class DetailViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UITextViewDelegate {
    
    @IBOutlet var nameOfArticle: UILabel!
    @IBOutlet var tableView: UITableView!
    var article:PFObject!
    var comments:[PFObject!] = []
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        tableView.estimatedRowHeight = 590
        tableView.rowHeight = UITableViewAutomaticDimension
        print("view loaded")
        self.hideKeyboardWhenTappedAround()
        self.viewUpByKeyboard()
        tableView.tableFooterView = UIView()
        
        
        let indexPath = NSIndexPath(forItem: 0, inSection: 0)
        let firstCell = self.tableView.cellForRowAtIndexPath(indexPath) as! DetailFirstCell
        firstCell.textView.delegate = self
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
            return cell
        case 2: //3번째
            let cell = tableView.dequeueReusableCellWithIdentifier("DetailThirdCell", forIndexPath: indexPath) as! DetailThirdCell
            
            cell.textField.text = comments[indexPath.row]["comment"] as! String
            // print("코멘트 불려짐")
            
            let nowUser = comments[indexPath.row]["user"] as! PFObject
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
            cell.textView.text = article["content"] as! String
            cell.shareCount.text = String(article["shareCount"] as! Int)
            cell.commentCount.text = String(article["commentCount"] as! Int)
            cell.userTime.text = String(stringDate + "전")
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
                cell.userPhoto!.kf_setImageWithURL(NSURL(string: unwrapPhoto.url!)!, completionHandler:{(image, error, cacheType, imageURL) -> () in
                    //print(unwrapPhoto.url)
                    //print("이미지셋")
                })
            }else{
                cell.imageConstraint.active = false
                cell.userPhoto.hidden = true
                //print("hidden")
            }
            
            //유져정보 가져옴
            let nowUser = article["user"] as! PFObject
            nowUser.fetchIfNeededInBackgroundWithBlock {
                (user: PFObject?, error: NSError?) -> Void in
                if let nowPhoto = user?["userPhoto"]{
                    let unwrapPhoto = nowPhoto as! PFFile
                    print(unwrapPhoto.url)
                    cell.userImage.kf_setImageWithURL(NSURL(string: unwrapPhoto.url!)!)
                    
                }
                else{
                    //cell.userImage.image = UIImage(named: "default-uesr")
                    cell.userImage.image = UIImage(named: "default-user2")
                    print("글쓴이 이미자가 없어서 넣어줬음")
                }
                if let userName = user?["nickname"]{
                    cell.userName.text = userName as? String
                    self.nameOfArticle.text = userName as! String + " 님의 글"
                }
            }
            //print("메인부분 불려짐")
            cell.selectionStyle = .None
            return cell
        }
    }
    
    
    
    @IBAction func test(sender: AnyObject) {
        let firstIndexPath = NSIndexPath(forItem: 0, inSection: 0)
        let firstSection = self.tableView.cellForRowAtIndexPath(firstIndexPath)
        print(firstSection)
    }
    
}
