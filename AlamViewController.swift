//
//  AlamViewController.swift
//  syl
//
//  Created by 유호균 on 2016. 4. 15..
//  Copyright © 2016년 timeros. All rights reserved.
//

import UIKit
import Parse
import SwiftDate

class AlamViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var alarms:[PFObject]! = []
    var myName:String?
    

    @IBOutlet var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        //self.tableView.reloadData()
        print(alarms)
        
        
        
        //읽으면 알람 줄어듬
        
        let query = PFQuery(className: "alarm")
        query.whereKey("read", equalTo: false)
        query.findObjectsInBackgroundWithBlock{
            (objects: [PFObject]?, error: NSError?) -> Void in
            if let error = error{
                SCLAlertView().showError("Comment Error", subTitle: "코멘트 가져오기 에러 \(error)")
            }
            else{
                for i in 0...Int((objects?.count)!){
                    let thisObect = objects![i] as PFObject
                    thisObect["read"] = true
                    thisObect.saveInBackground()
                }
            }
        }
        
        tableView.tableFooterView = UIView()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(animated: Bool) {
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func backButtonAction(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return alarms.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("AlarmCell") as! AlarmCell
        
        let nowUser = alarms[indexPath.row]["fromUser"] as! PFObject
        nowUser.fetchIfNeededInBackgroundWithBlock {
            (user: PFObject?, error: NSError?) -> Void in
            if let nowPhoto = user?["userPhoto"]{
                let unwrapPhoto = nowPhoto as! PFFile
                cell.userPhoto.kf_setImageWithURL(NSURL(string: unwrapPhoto.url!)!)
            }else{
                cell.userPhoto.image = UIImage(named: "default-user2")
            }
            if let userName = user?["nickname"]{
                let fromName = userName as! String
                cell.user.sizeToFit()
                //0이면 댓글 1이면 공유
                if self.alarms[indexPath.row]["category"] as! Int ==  0{
                    cell.user.text = fromName
                    cell.userMsg.text = "님이 회원님의 게시글에 댓글을 남겼습니다."
                    
                }
                else{
                    cell.user.text = fromName
                    cell.userMsg.text = "님이 회원님의 게시글을 공유했습니다."
                }
                //날짜 파싱
                /*
                let dateFormatter = NSDateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd"
                let writeDate = dateFormatter.stringFromDate(self.alarms[indexPath.row].createdAt!)
                */
                
                let stringDate = (self.alarms[indexPath.row].createdAt!).toNaturalString(NSDate(), inRegion: .None, style: FormatterStyle(style: .Abbreviated, max: 1))!
                
                cell.time.text = stringDate + " 전"
                
                //alarms[indexPath.row]["createdAt"] as! NSDate

                //cell.time.text =
            }
        }
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        //self.performSegueWithIdentifier("FromAlarmToDetail", sender: indexPath)
        
        alarms[indexPath.row]["article"].fetchInBackgroundWithBlock{
            (object: PFObject?, error: NSError?) -> Void in
            self.performSegueWithIdentifier("FromAlarmToDetail", sender: object!)
            
        }
        print()
        //destController.article = alarms[indexPath.row]["article"] as! PFObject
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "FromAlarmToDetail"{
            let destController = segue.destinationViewController as! DetailViewController
            
            destController.article = sender as! PFObject
            destController.category = String(destController.article["category"])
            destController.myName = self.myName
            
            destController.name = String(destController.article["authorNick"])
            destController.nameArticle = String(destController.article["authorNick"]) + "님의 글"
            
            let query = PFQuery(className: "comment")
            query.whereKey("article", equalTo: destController.article)
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
            
            
            //임시
            //destController.category = "other"
            
            //새로 받아야
            //print(self.alarms[sender!.row])
            
            /*
            destController.article = self.alarms[sender!.row]
            let query = PFQuery(className: "comment")
            query.whereKey("article", equalTo: self.alarms[sender!.row])
            query.orderByDescending("createdAt")
            query.findObjectsInBackgroundWithBlock{
                (objects: [PFObject]?, error: NSError?) -> Void in
                if let error = error{
                    SCLAlertView().showError("Comment Error", subTitle: "코멘트 가져오기 에러")
                }
                else{
                    //print("코멘트 가져왔다 \(objects)")
                    destController.comments = objects!
                    let section = NSIndexSet(index: 2)
                    destController.tableView.reloadSections(section, withRowAnimation: .Automatic)
                }
            }
            */
            
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
