//
//  ViewController.swift
//  SensorStats
//
//  Created by Kevin Sullivan on 3/1/15.
//  Copyright (c) 2015 SideApps. All rights reserved.
//

import UIKit
import CoreLocation
import CoreMotion

protocol StatContentDelegate {
    func changedLocationAccuracy(index: Int)
}

class StatPageViewController: UIPageViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    
    var parent: StatViewController!
    
    let storyboardIDs = ["gpsPage"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.dataSource = self
        self.delegate = self
        
        let initialVC = storyboard?.instantiateViewControllerWithIdentifier("gpsPage") as! StatGPSContentViewController
        initialVC.delegate = parent
        
        self.setViewControllers([initialVC], direction: UIPageViewControllerNavigationDirection.Forward, animated: false, completion: nil)
    }
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {
        
        var index = (viewController as! StatGPSContentViewController).index
        index++
        
        if index >= storyboardIDs.count { return nil }
        
        return viewControllerAtIndex(index)
    }
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {
        
        var index = (viewController as! StatGPSContentViewController).index
        index--
        
        if index < 0 { return nil }
        
        return viewControllerAtIndex(index)
    }
    
    func viewControllerAtIndex(index : Int) -> UIViewController? {
        if index == 0 {
            if let contentVC = storyboard?.instantiateViewControllerWithIdentifier("gpsPage") as? StatGPSContentViewController {
                contentVC.delegate = parent
                
                return contentVC
            }
        }
        
        return nil
    }
    
    func presentationCountForPageViewController(pageViewController: UIPageViewController) -> Int {
        return storyboardIDs.count
    }
    
    func presentationIndexForPageViewController(pageViewController: UIPageViewController) -> Int {
        return 0
    }
}

class StatGPSContentViewController: UIViewController {
    
    @IBOutlet weak var segAccuracy: UISegmentedControl!
    
    var delegate: StatContentDelegate?
    
    var gpsAccuracyIndex = 1
    var index = 0
    
    @IBAction func segToggled(sender: AnyObject) {
        if let seg = sender as? UISegmentedControl {
            delegate?.changedLocationAccuracy(seg.selectedSegmentIndex)
        }
    }
}

class StatTableViewController: UITableViewController, CLLocationManagerDelegate {
    
    var locationManager = CLLocationManager()
    var motionManager = CMMotionManager()
    var lastLocation = CLLocation()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Configure the location manager
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()
        
        // Configure the motion manager
        // TODO: Hardware check
        motionManager.gyroUpdateInterval = 0.1
        motionManager.accelerometerUpdateInterval = 0.1
        
        // Configure update queues
        let gyroQueue = NSOperationQueue.mainQueue()
        let accQueue = NSOperationQueue.mainQueue()
        
        motionManager.startGyroUpdatesToQueue(gyroQueue) {
            (data: CMGyroData!, error: NSError!) in
            
            if (error != nil) { println("Error: \(error)") }
            
            println(data)
        }
        
        motionManager.startAccelerometerUpdatesToQueue(accQueue) {
            (data: CMAccelerometerData!, error: NSError!) in
            
            if (error != nil) { println("Error: \(error)") }
            
            println(data)
        }
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 8
        }
        
        return 0
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "GPS"
        }
        
        return "ERROR"
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            var cell = tableView.dequeueReusableCellWithIdentifier("statCell") as! UITableViewCell
            
            if indexPath.row == 0 {
                cell.textLabel?.text = "Latitude"
                cell.detailTextLabel?.text = "\(lastLocation.coordinate.latitude) degrees"
            }
            else if indexPath.row == 1 {
                cell.textLabel?.text = "Longitude"
                cell.detailTextLabel?.text = "\(lastLocation.coordinate.longitude) degrees"
            }
            else if indexPath.row == 2 {
                cell.textLabel?.text = "Altitude"
                cell.detailTextLabel?.text = "\(lastLocation.altitude) meters"
            }
            else if indexPath.row == 3 {
                cell.textLabel?.text = "Floor"
                cell.detailTextLabel?.text = "\(lastLocation.altitude)"
            }
            else if indexPath.row == 4 {
                cell.textLabel?.text = "Horizontal Accuracy"
                cell.detailTextLabel?.text = "within \(lastLocation.horizontalAccuracy) meters"
            }
            else if indexPath.row == 5 {
                cell.textLabel?.text = "Vertical Accuracy"
                cell.detailTextLabel?.text = "within \(lastLocation.verticalAccuracy) meters"
            }
            else if indexPath.row == 6 {
                cell.textLabel?.text = "Speed"
                cell.detailTextLabel?.text = "\(lastLocation.speed) m/s?"
            }
            else if indexPath.row == 7 {
                cell.textLabel?.text = "Course"
                cell.detailTextLabel?.text = "\(lastLocation.course) degrees"
            }
            
            return cell
        }
        
        return UITableViewCell()
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        if let loc = locations.last as? CLLocation {
            lastLocation = loc
            tableView.reloadData()
        }
    }
    
    func changedLocationAccuracy(index: Int) {
        if index == 0 {
            locationManager.desiredAccuracy = kCLLocationAccuracyThreeKilometers
        }
        else if index == 1 {
            locationManager.desiredAccuracy = kCLLocationAccuracyKilometer
        }
        else if index == 2 {
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        }
        else if index == 3 {
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
        }
        else if index == 4 {
            locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        }
    }
}

class StatViewController: UIViewController, StatContentDelegate {
    
    var statTable: StatTableViewController!
    var statDetail: StatPageViewController!
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "embedStats" {
            if let vc = segue.destinationViewController as? StatTableViewController {
                statTable = vc
            }
        }
        else if segue.identifier == "embedDetail" {
            if let vc = segue.destinationViewController as? StatPageViewController {
                statDetail = vc
                statDetail.parent = self
            }
        }
    }
    
    func changedLocationAccuracy(index: Int) {
        statTable.changedLocationAccuracy(index)
    }
}

