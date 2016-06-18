//
//  DetailFirstCell.swift
//  syl
//
//  Created by 유호균 on 2016. 4. 22..
//  Copyright © 2016년 timeros. All rights reserved.
//

import UIKit
import Mapbox

class DetailFirstCell: UITableViewCell {
    @IBOutlet var userImage: UIImageView!
    @IBOutlet var userName: UILabel!
    @IBOutlet var userAddress: UILabel!
    @IBOutlet var userTime: UILabel!
    @IBOutlet var userPhoto: UIImageView!
    @IBOutlet var textView: UITextView!
    @IBOutlet var mapView: MGLMapView!
    @IBOutlet var shareCount: UILabel!
    @IBOutlet var commentCount: UILabel!
    @IBOutlet var imageConstraint: NSLayoutConstraint!
    @IBOutlet var collapseBtnConstraint: NSLayoutConstraint!
    @IBOutlet var imageTopConstraint: NSLayoutConstraint!
    @IBOutlet var mapHeightConstraint: NSLayoutConstraint!
    @IBOutlet var collapseBtn: UIButton!
    
    
    @IBAction func collapseAction(sender: AnyObject) {
        print("버튼 클릭")
        
        if self.collapseBtnConstraint.constant == 339{
            UIView.animateWithDuration(0.3, delay: 0, options: .CurveEaseIn, animations: {
                self.mapView.alpha = 0
                //self.mapHeightConstraint.active = false
                self.collapseBtnConstraint.constant = 72
                self.mapHeightConstraint.constant = 0
                //부모테이블
                /*
                */
                let superTableView = self.superview?.superview as! UITableView
                //섹션
                var section = NSIndexSet(index: 2)
                //superTableView.reloadSections(section, withRowAnimation: .Automatic)
                section = NSIndexSet(index: 1)
                superTableView.reloadSections(section, withRowAnimation: .None)               
                self.layoutIfNeeded()
                }, completion: {
                    finished in print("지도 접기")
                    self.collapseBtn.setImage(UIImage(named: "down"), forState: .Normal)
            })
        }
        else{
            UIView.animateWithDuration(0.3, delay: 0, options: .CurveEaseIn, animations: {
                self.mapView.alpha = 1
                self.collapseBtnConstraint.constant = 339
                self.mapHeightConstraint.constant = 290
                //self.imageTopConstraint.constant = 196
                
                //부모테이블
                let superTableView = self.superview?.superview as! UITableView
                var section = NSIndexSet(index: 2)
                //superTableView.reloadSections(section, withRowAnimation: .Automatic)
                section = NSIndexSet(index: 1)
                superTableView.reloadSections(section, withRowAnimation: .None)
                
                self.layoutIfNeeded()
                }, completion: {
                    finished in print("지도 접기")
                    self.collapseBtn.setImage(UIImage(named: "up"), forState: .Normal)
            })
        }
    }
    
    
}
