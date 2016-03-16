//
//  RunDetailViewController.swift
//  Lilac12k
//

import UIKit
import MapKit
import HealthKit
import CoreLocation
import CoreData

class IBRunDetailViewController: UIViewController {
    
    var run: Run!
    
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var paceLabel: UILabel!
    
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ///self.saveRun(Float(run.distance!), duration: Int(run.duration!), timestamp: run.timestamp!)
        // Do any additional setup after loading the view.
        configureView()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func saveRun(distance: Float, duration: Int, timestamp: NSDate) {
        let appDelegate =
        UIApplication.sharedApplication().delegate as! AppDelegate
        
        let managedContext = appDelegate.managedObjectContext
        
        let entity =  NSEntityDescription.entityForName("Run",
            inManagedObjectContext:managedContext)
        
        let run = NSManagedObject(entity: entity!,
            insertIntoManagedObjectContext: managedContext)
        
        run.setValue(distance, forKey: "distance")
        run.setValue(duration, forKey: "duration")
        run.setValue(timestamp, forKey: "timestamp")
        do {
            try managedContext.save()
            //runs.append(run)
        } catch let error as NSError  {
            print("Could not save \(error), \(error.userInfo)")
        }
    }
    
    func configureView()
    {
        //        mapView.delegate = self
        let milesFromMeters = (run.distance?.doubleValue)! * 0.000621371
        let distanceQuantity = HKQuantity(unit: HKUnit.mileUnit(), doubleValue: floor(milesFromMeters * 100)/100)
        
        //let distanceQuantity = HKQuantity(unit: HKUnit.meterUnit(), doubleValue: (run.distance?.doubleValue)!)
        distanceLabel.text = distanceQuantity.description
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateStyle = .MediumStyle
        dateLabel.text = dateFormatter.stringFromDate(run.timestamp!)
        
        let secondQuantity = HKQuantity(unit: HKUnit.secondUnit(), doubleValue:(run.duration?.doubleValue)!)
        timeLabel.text = secondQuantity.description
        
        let paceUnit = HKUnit.minuteUnit().unitDividedByUnit(HKUnit.mileUnit())
        let paceQuantity = HKQuantity(unit: paceUnit, doubleValue: floor((((run.duration?.doubleValue)!/60.0)/((run.distance?.doubleValue)! * 0.000621371))*100)/100)
        
        //let paceUnit = HKUnit.secondUnit().unitDividedByUnit(HKUnit.meterUnit())
        //let paceQuantity = HKQuantity(unit: paceUnit, doubleValue: (run.duration?.doubleValue)!/(run.duration?.doubleValue)!)
        paceLabel.text = paceQuantity.description
        
        loadMap()
        
    }
    
    func loadMap() {
        if run.locations?.count>0 {
            mapView.hidden = false
            
            //Set the map bounds
            mapView.region = mapRegion()
            
            //Make the lines on the map
            //            mapView.addOverlay(polyline())
            let colorSegments = IBMulticolorPolylineSegment.colorSegments(forLocations: run.locations?.array as! [Location])
            mapView.addOverlays(colorSegments)
            
        }else
        {
            //No location were found
            mapView.hidden = true
            
        }
    }
    
    func mapRegion() -> MKCoordinateRegion {
        let initialLoc = run.locations?.firstObject as! Location
        
        var minLat = initialLoc.latitude!.doubleValue
        var minLng = initialLoc.longitude!.doubleValue
        var maxLat = minLat
        var maxLng = minLng
        
        let locations = run.locations?.array as! [Location]
        
        for location in locations {
            minLat = min(minLat, location.latitude!.doubleValue)
            minLng = min(minLng, location.longitude!.doubleValue)
            maxLat = max(maxLat, location.latitude!.doubleValue)
            maxLng = max(maxLng, location.longitude!.doubleValue)
        }
        
        return MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: (minLat + maxLat)/2,
                longitude: (minLng + maxLng)/2),
            span: MKCoordinateSpan(latitudeDelta: (maxLat - minLat)*1.1,
                longitudeDelta: (maxLng - minLng)*1.1)
            
        )
        
    }
    
    func polyline()->MKPolyline {
        var coords = [CLLocationCoordinate2D]()
        
        let locations = run.locations?.array as! [Location]
        for location in locations {
            coords.append(CLLocationCoordinate2D(latitude: (location.latitude?.doubleValue)!, longitude: (location.longitude?.doubleValue)!))
        }
        
        return MKPolyline(coordinates: &coords, count: run.locations!.count)
    }
    
    func mapView(mapView: MKMapView, rendererForOverlay overlay: MKOverlay) -> MKOverlayRenderer {
        if !overlay.isKindOfClass(IBMulticolorPolylineSegment) {
            //            return nil
            print("not IBMulticolorPolylineSegment")
        }
        
        let polyline = overlay as! IBMulticolorPolylineSegment
        let renderer = MKPolylineRenderer(polyline: polyline)
        
        renderer.strokeColor = polyline.color
        renderer.lineWidth = 3
        return renderer
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

extension IBRunDetailViewController : MKMapViewDelegate
{
    
}
