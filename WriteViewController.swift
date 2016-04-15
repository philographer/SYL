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

class WriteViewController: UIViewController {

    @IBOutlet var MapView: UIView!
    @IBOutlet var writeButton: UIButton!
    @IBOutlet var textView: UITextView!
    
    var map:MGLMapView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
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
        let latitude:Double = Double((self.map?.userLocation?.coordinate.latitude)!)
        let longitude:Double = Double((self.map?.userLocation?.coordinate.longitude)!)
        
        let point = PFGeoPoint(latitude: latitude, longitude: longitude)
        let articleObject = PFObject(className: "article")
        articleObject["content"] = self.textView.text
        articleObject["user"] = PFUser.currentUser()
        articleObject["location"] = point
        
        articleObject.saveInBackgroundWithBlock{
            (success: Bool, error: NSError?) -> Void in
            if(success){
                self.dismissViewControllerAnimated(true, completion: nil)
            }
            else{
                print(error)
            }
        }
        
        
        print(self.map!.userLocation?.coordinate)
    }
    
    @IBAction func BackAction(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
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
