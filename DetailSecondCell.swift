//
//  DetailSecondCell.swift
//  syl
//
//  Created by 유호균 on 2016. 4. 22..
//  Copyright © 2016년 timeros. All rights reserved.
//

import UIKit
import Parse

class DetailSecondCell: UITableViewCell {
    
    @IBOutlet var commentField: UITextField!
    @IBOutlet var commentBtn: UIButton!
    var article:PFObject!
    var postId:String!
    var authorNick:String!
    
    @IBAction func commentAction(sender: AnyObject) {
        let commentObject = PFObject(className: "comment")
        commentObject["comment"] = self.commentField.text
        commentObject["user"] = PFUser.currentUser()
        commentObject["authorId"] = PFUser.currentUser()?.objectId!
        commentObject["authorNick"] = self.authorNick
        commentObject["postId"] = self.postId
        
        commentObject["article"] = self.article
        commentObject.saveInBackgroundWithBlock{
            (success: Bool, error: NSError?) -> Void in
            if(success){
                print("성공")
                //부모테이블
                let superTableView = self.superview?.superview as! UITableView
                //부모 컨트롤러
                let viewController = superTableView.delegate as! DetailViewController
                
                //첫번째 섹션의 로우
                let indexPath = NSIndexPath(forItem: 0, inSection: 0)
                //첫번째 섹션
                let firstSection = superTableView.cellForRowAtIndexPath(indexPath) as! DetailFirstCell
                
                //코멘트 개수 + 1
                var query = PFQuery(className: "article")
                query.getObjectInBackgroundWithId(self.article.objectId!){
                    (object:PFObject? , error: NSError?) -> Void in
                    if error != nil{
                        SCLAlertView().showError("Error", subTitle: "코멘트 개수 증가 오류")
                    }
                    else if let result = object{
                        result["commentCount"] = result["commentCount"] as! Int + 1
                        firstSection.commentCount.text = String(Int(firstSection.commentCount.text!)! + 1)
                        result.saveInBackgroundWithBlock{
                            (successed: Bool, error: NSError?) -> Void in
                            //코멘트 등록
                            query = PFQuery(className: "comment")
                            query.whereKey("article", equalTo: self.article)
                            query.orderByAscending("createdAt")
                            query.findObjectsInBackgroundWithBlock{
                                (objects: [PFObject]?, error: NSError?) -> Void in
                                viewController.comments = objects!
                                let section = NSIndexSet(index: 2)
                                superTableView.reloadSections(section, withRowAnimation: .Automatic)
                                self.tableViewScrollToBottom(true)
                            }
                            
                            
                            //자기가 아니면
                            let userName = (self.article["user"] as! PFUser).username!
                            let myName = PFUser.currentUser()!.username!
                            
                            //알람 보냄
                            if userName != myName{
                                let alarmObject = PFObject(className: "alarm")
                                alarmObject["fromUser"] = PFUser.currentUser()
                                alarmObject["toUser"] = self.article["user"]
                                alarmObject["read"] = false
                                alarmObject["article"] = self.article
                                
                                
                                //알람마다 카테고리
                                
                                alarmObject["category"] = 0
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
                    }
                }
            }
            else{
                SCLAlertView().showError("Comment Error", subTitle: "코멘트 에러발생")
            }
            
            self.commentField.text = ""
            self.commentField.resignFirstResponder()
        }

    }
    
    func tableViewScrollToBottom(animated: Bool) {
        
        let delay = 0.1 * Double(NSEC_PER_SEC)
        let time = dispatch_time(DISPATCH_TIME_NOW, Int64(delay))
        
        dispatch_after(time, dispatch_get_main_queue(), {
            
            //부모테이블
            let superTableView = self.superview?.superview as! UITableView
            
            let numberOfSections = superTableView.numberOfSections
            let numberOfRows = superTableView.numberOfRowsInSection(numberOfSections-1)
            
            if numberOfRows > 0 {
                let indexPath = NSIndexPath(forRow: (numberOfRows-1), inSection: (numberOfSections-1))
                superTableView.scrollToRowAtIndexPath(indexPath, atScrollPosition: UITableViewScrollPosition.Bottom, animated: animated)
            }
            
        })
    }
    
}
