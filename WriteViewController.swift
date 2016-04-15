//
//  WriteViewController.swift
//  syl
//
//  Created by 유호균 on 2016. 4. 15..
//  Copyright © 2016년 timeros. All rights reserved.
//

import UIKit
import Mapbox

class WriteViewController: UIViewController {

    @IBOutlet var MapView: UIView!
    @IBOutlet var writeButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        //mapbox
        let mapView = MGLMapView(frame: self.MapView.bounds,
                                 styleURL: MGLStyle.lightStyleURL())
        mapView.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        //set the map's center coordinate
        mapView.setCenterCoordinate(CLLocationCoordinate2D(latitude: 40.7326808,
            longitude: -73.9843407),zoomLevel: 12, animated: false)
        self.MapView.addSubview(mapView)
        mapView.attributionButton.hidden = true
        self.writeButton.layer.zPosition = 99

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
