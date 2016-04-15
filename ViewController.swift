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


class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, KCFloatingActionButtonDelegate {
    
    //LayOut Outlet
    @IBOutlet weak var MapView: UIView!
    @IBOutlet weak var collapsibleConstraint: NSLayoutConstraint!
    @IBOutlet weak var ArticleView: UIView!
    @IBOutlet var tableView: UITableView!
    @IBOutlet weak var floatBtn: KCFloatingActionButton!
    @IBOutlet weak var collapseBtn: UIButton!
    @IBOutlet weak var daumLogo: UIImageView!
    @IBOutlet weak var collapseBtnConstraint: NSLayoutConstraint!
    @IBOutlet var floatBtnConstraint: NSLayoutConstraint!
    @IBOutlet var floatBtnConstraintBottom: NSLayoutConstraint!
    
    //KFloat Button
    let kCloseCellHeight: CGFloat = 179
    let kOpenCellHeight: CGFloat = 488
    let kRowsCount = 1
    var cellHeights = [CGFloat]()
    var map:MGLMapView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //mapbox
        map = MGLMapView(frame: self.MapView.bounds,
                             styleURL: MGLStyle.lightStyleURL())
        map!.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        //set the map's center coordinate
        /*map!.setCenterCoordinate(CLLocationCoordinate2D(latitude: 40.7326808,
            longitude: -73.9843407),zoomLevel: 12, animated: false)
        */
        map!.attributionButton.hidden = true
        self.MapView.addSubview(map!)
        //Collapsible Table
        createCellHeightsArray()
        self.tableView.backgroundColor = UIColor(patternImage: UIImage(named: "background")!)
        tableView.dataSource = self
        tableView.delegate = self
        
        //KFloat Button Add Item
        self.floatBtn.openAnimationType = KCFABOpenAnimationType.SlideDown
        self.floatBtn.addItem("기타", icon: UIImage(named: "icMap")!, handler: {item in
            self.performSegueWithIdentifier("writeViewController", sender: self)
            print("기타")})
        self.floatBtn.addItem("범죄", icon: UIImage(named: "icShare")!, handler: {item in
            self.performSegueWithIdentifier("writeViewController", sender: self)
            print("범죄")})
        self.floatBtn.addItem("사고", icon: UIImage(named: "icMap")!, handler: {item in
            self.performSegueWithIdentifier("writeViewController", sender: self)
            print("사고")})
        self.floatBtn.addItem("물자", icon: UIImage(named: "icMap")!, handler: {item in
            self.performSegueWithIdentifier("writeViewController", sender: self)
            print("물자")})
        self.floatBtn.addItem("의료", icon: UIImage(named: "icMap")!, handler: {item in
            self.performSegueWithIdentifier("writeViewController", sender: self)
            print("의료")})
        
        //print(PFUser.currentUser()!["name"])
    }
    
    
    
    override func viewWillAppear(animated: Bool) {
        print(PFUser.currentUser())
        //회원가입 안 했으면 메인으로
        if(PFUser.currentUser() == nil){
            self.performSegueWithIdentifier("FromMainToSign", sender: self)
            print("노아이디")
        }
        else{
            map!.userTrackingMode = MGLUserTrackingMode.FollowWithHeading
            print(map!.userLocation?.coordinate)
            //let camera = MGLMapCamera(lookingAtCenterCoordinate: (map!.userLocation?.coordinate)!, fromDistance: 9000, pitch: 45, heading: 0)
            //map!.setCamera(camera, withDuration: 3, animationTimingFunction: CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut))
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        print(map!.userLocation?.coordinate)
    }
    
    
    
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: configure
    func createCellHeightsArray() {
        for _ in 0...kRowsCount {
            cellHeights.append(kCloseCellHeight)
        }
    }
    
    // MARK: - Table view data source
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        
        if cell is FoldingCell {
            let foldingCell = cell as! FoldingCell
            foldingCell.backgroundColor = UIColor.clearColor()
            
            if cellHeights[indexPath.row] == kCloseCellHeight {
                foldingCell.selectedAnimation(false, animated: false, completion:nil)
            } else {
                foldingCell.selectedAnimation(true, animated: false, completion: nil)
            }
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("FoldingCell", forIndexPath: indexPath)
        
        return cell
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return cellHeights[indexPath.row]
    }
    
    // MARK: Table vie delegate
    
     func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        let cell = tableView.cellForRowAtIndexPath(indexPath) as! FoldingCell
        
        if cell.isAnimating() {
            return
        }
        
        var duration = 0.0
        if cellHeights[indexPath.row] == kCloseCellHeight { // open cell
            cellHeights[indexPath.row] = kOpenCellHeight
            cell.selectedAnimation(true, animated: true, completion: nil)
            duration = 0.5
        } else {// close cell
            cellHeights[indexPath.row] = kCloseCellHeight
            cell.selectedAnimation(false, animated: true, completion: nil)
            duration = 0.8
        }
        
        UIView.animateWithDuration(duration, delay: 0, options: .CurveEaseOut, animations: { () -> Void in
            tableView.beginUpdates()
            tableView.endUpdates()
            }, completion: nil)
        
        
    }
    
    
    @IBAction func collapseAction(sender: AnyObject) {
        if(collapsibleConstraint.constant == 197)
        {
            
            UIView.animateWithDuration(0.3, delay: 0, options: .CurveEaseIn, animations: {
                self.floatBtnConstraint.active = false
                self.MapView.alpha = 0
                self.collapsibleConstraint.constant = 0
                self.collapseBtnConstraint.constant = 100
                self.view.layoutIfNeeded()}, completion: {
                    finished in print("지도 접기")
                    self.floatBtn.openAnimationType = KCFABOpenAnimationType.SlideUp
            })
        }
        else if(collapsibleConstraint.constant == 0){
            UIView.animateWithDuration(0.3, delay: 0, options: .CurveEaseIn, animations: {
                self.floatBtnConstraint.active = true
                self.MapView.alpha = 1
                self.collapsibleConstraint.constant = 197
                self.collapseBtnConstraint.constant = 245
                self.view.layoutIfNeeded()}, completion: {
                    finished in print("지도 펴기")
                    self.floatBtn.openAnimationType = KCFABOpenAnimationType.SlideDown
                    
                    
                    //self.view.removeConstraint(floatBtnConstraint)
                    
            })
        }
    }
}