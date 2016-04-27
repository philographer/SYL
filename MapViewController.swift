import UIKit
import Mapbox

class MapViewController: UIViewController {
    
    var mapView: MGLMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView = MGLMapView(frame: view.bounds)
        mapView.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        
        let center = CLLocationCoordinate2D(latitude: 50.999, longitude: 3.3253)
        
        // Optionally set a starting point, rotated 180°.
        mapView.setCenterCoordinate(center, zoomLevel: 5, direction: 180, animated: false)
        
        view.addSubview(mapView)
    }
    
    override func viewDidAppear(animated: Bool) {
        // Wait a bit before setting a new camera.
        
        // Create a camera that rotates around the same center point, back to 0°.
        // `fromDistance:` is meters above mean sea level that an eye would have to be in order to see what the map view is showing.
        let camera = MGLMapCamera(lookingAtCenterCoordinate: mapView.centerCoordinate, fromDistance: 9000, pitch: 45, heading: 0)
        
        // Animate the camera movement over 5 seconds.
        mapView.setCamera(camera, withDuration: 5, animationTimingFunction: CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut))
    }
    
}