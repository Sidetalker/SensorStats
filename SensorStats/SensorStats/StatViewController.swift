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
    func changedGyroRefresh(rate: NSTimeInterval)
    func changeAccRefresh(rate: NSTimeInterval)
}

protocol PagerDelegate {
    func changedPage(index: Int)
}

class StatPageViewController: UIPageViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    
    var parent: StatViewController!
    var swipeDelegate: PagerDelegate?
    
    var vcA: StatGPSContentViewController!
    var vcB: StatMotionContentViewController!
    var vcC: StatMotionContentViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        swipeDelegate = parent
        
        self.dataSource = self
        self.delegate = self
        
        vcA = storyboard?.instantiateViewControllerWithIdentifier("gpsPage") as! StatGPSContentViewController
        vcA.delegate = parent
        vcA.index = 0
        
        vcB = storyboard?.instantiateViewControllerWithIdentifier("motionPage") as! StatMotionContentViewController
        vcB.delegate = parent
        vcB.index = 1
        vcB.displayType = 0
        vcB.loadView()
        vcB.initialize()
        
        vcC = storyboard?.instantiateViewControllerWithIdentifier("motionPage") as! StatMotionContentViewController
        vcC.delegate = parent
        vcC.index = 2
        vcC.displayType = 1
        vcC.loadView()
        vcC.initialize()
        
        self.setViewControllers([vcA], direction: UIPageViewControllerNavigationDirection.Forward, animated: false, completion: nil)
    }
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {
        if viewController.isEqual(vcA) { return vcB }
        if viewController.isEqual(vcB) { return vcC }
        
        return nil
    }
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {
        if viewController.isEqual(vcB) { return vcA }
        if viewController.isEqual(vcC) { return vcB }
        
        return nil
    }
    
    func pageViewController(pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [AnyObject], transitionCompleted completed: Bool) {
        if completed {
            var index = -1
            
            if let vc = self.viewControllers[0] as? StatGPSContentViewController {
                index = vc.index
            }
            else if let vc = self.viewControllers[0] as? StatMotionContentViewController {
                index = vc.index
            }
            
            swipeDelegate?.changedPage(index)
        }
    }
    
    func viewControllerAtIndex(index : Int) -> UIViewController? {
        if index == 0 {
            return vcA
        }
        else if index == 1 || index == 2 {
            return index == 1 ? vcB : vcA
        }
        
        return nil
    }
    
    func presentationCountForPageViewController(pageViewController: UIPageViewController) -> Int {
        return 3
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

class StatMotionContentViewController: UIViewController {
    
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblInfo: UILabel!
    
    var delegate: StatContentDelegate?
    
    var gyroUpdateInterval: NSTimeInterval = 0.1
    var accUpdateInterval: NSTimeInterval = 0.1
    var displayType = 0
    var index = 0
    
    func initialize() {
        lblTitle.text = displayType == 0 ? "Accelerometer" : "Gyroscope"
    }
    
    @IBAction func stepperChanged(sender: AnyObject) {
        if let stepper = sender as? UIStepper {
            lblInfo.text = "Capture Rate: \(stepper.value)/sec"
            
            displayType == 0 ? delegate?.changeAccRefresh(stepper.value) : delegate?.changedGyroRefresh(stepper.value)
        }
    }
}

class StatTableViewController: UITableViewController, CLLocationManagerDelegate, PagerDelegate {
    
    var locationManager = CLLocationManager()
    var motionManager = CMMotionManager()
    
    var lastLocation: CLLocation?
    var lastGyro: CMGyroData?
    var lastAcc: CMAccelerometerData?
    
    var displayMode = 0
    
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
            
            self.lastGyro = data
            self.tableView.reloadData()
        }
        
        motionManager.startAccelerometerUpdatesToQueue(accQueue) {
            (data: CMAccelerometerData!, error: NSError!) in
            
            if (error != nil) { println("Error: \(error)") }
            
            self.lastAcc = data
            self.tableView.reloadData()
        }
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if displayMode == 0 { return 8 }
        else                { return 3 }
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if displayMode == 0 { return "GPS" }
        if displayMode == 1 { return "Accelerometer" }
        if displayMode == 2 { return "Gyroscope" }
        
        return "ERROR"
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier("statCell") as! UITableViewCell
        
        if displayMode == 0 {
            if let loc = lastLocation {
                if indexPath.row == 0 {
                    cell.textLabel?.text = "Latitude"
                    cell.detailTextLabel?.text = "\(loc.coordinate.latitude) degrees"
                }
                else if indexPath.row == 1 {
                    cell.textLabel?.text = "Longitude"
                    cell.detailTextLabel?.text = "\(loc.coordinate.longitude) degrees"
                }
                else if indexPath.row == 2 {
                    cell.textLabel?.text = "Altitude"
                    cell.detailTextLabel?.text = "\(loc.altitude) meters"
                }
                else if indexPath.row == 3 {
                    cell.textLabel?.text = "Floor"
                    cell.detailTextLabel?.text = "\(loc.floor.level)"
                }
                else if indexPath.row == 4 {
                    cell.textLabel?.text = "Horizontal Accuracy"
                    cell.detailTextLabel?.text = "within \(loc.horizontalAccuracy) meters"
                }
                else if indexPath.row == 5 {
                    cell.textLabel?.text = "Vertical Accuracy"
                    cell.detailTextLabel?.text = "within \(loc.verticalAccuracy) meters"
                }
                else if indexPath.row == 6 {
                    cell.textLabel?.text = "Speed"
                    cell.detailTextLabel?.text = "\(loc.speed) m/s?"
                }
                else if indexPath.row == 7 {
                    cell.textLabel?.text = "Course"
                    cell.detailTextLabel?.text = "\(loc.course) degrees"
                }
            }
            else {
                cell.textLabel?.text = "Error"
                cell.detailTextLabel?.text = "No Location Data"
            }
        }
        else if displayMode == 1 {
            if let acc = lastAcc?.acceleration {
                if indexPath.row == 0 {
                    cell.textLabel?.text = "X Acceleration"
                    cell.detailTextLabel?.text = "\(acc.x)"
                }
                else if indexPath.row == 1 {
                    cell.textLabel?.text = "Y Acceleration"
                    cell.detailTextLabel?.text = "\(acc.y)"
                }
                else if indexPath.row == 2 {
                    cell.textLabel?.text = "Z Acceleration"
                    cell.detailTextLabel?.text = "\(acc.z)"
                }
            }
            else {
                cell.textLabel?.text = "Error"
                cell.detailTextLabel?.text = "No Acceleration Data"
            }
        }
        else if displayMode == 2 {
            if let gyro = lastGyro?.rotationRate {
                if indexPath.row == 0 {
                    cell.textLabel?.text = "X Rotation Rate"
                    cell.detailTextLabel?.text = "\(gyro.x)"
                }
                else if indexPath.row == 1 {
                    cell.textLabel?.text = "Y Rotation Rate"
                    cell.detailTextLabel?.text = "\(gyro.y)"
                }
                else if indexPath.row == 2 {
                    cell.textLabel?.text = "Z Rotation Rate"
                    cell.detailTextLabel?.text = "\(gyro.z)"
                }
            }
            else {
                cell.textLabel?.text = "Error"
                cell.detailTextLabel?.text = "No Gyroscope Data"
            }
        }
        
        return cell
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
    
    func changedPage(index: Int) {
        let animationA = index > displayMode ? UITableViewRowAnimation.Left : UITableViewRowAnimation.Right
        let animationB = index < displayMode ? UITableViewRowAnimation.Left : UITableViewRowAnimation.Right
        
        tableView.beginUpdates()
        
        displayMode = index
        
        tableView.deleteSections(NSIndexSet(index: 0), withRowAnimation: animationA)
        tableView.insertSections(NSIndexSet(index: 0), withRowAnimation: animationB)
        
        var inserts = [NSIndexPath(forRow: 0, inSection: 0)]
        var count = displayMode == 0 ? 7 : 2
        
        for i in 1...count {
            inserts.append(NSIndexPath(forRow: i, inSection: 0))
        }
        
        tableView.insertRowsAtIndexPaths(inserts, withRowAnimation: animationB)
        
        tableView.endUpdates()
    }
}

class StatViewController: UIViewController, StatContentDelegate, PagerDelegate {
    
    @IBOutlet weak var btnRecordSave: UIButton!
    
    var statTable: StatTableViewController!
    var statDetail: StatPageViewController!
    
    var recording = false
    var timer: NSTimer?
    var data = Array<DataEntry>()
    
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
    
    @IBAction func fireRecordSave(sender: AnyObject) {
        let curFrame = btnRecordSave.frame
        let curLoc = curFrame.origin
        let curSize = curFrame.size
        
        let newLoc = CGPoint(x: curLoc.x, y: curLoc.y + curSize.height)
        
        // Start or stop recording as needed
        if !recording {
           timer = NSTimer.scheduledTimerWithTimeInterval(0.333, target: self, selector: Selector("saveLatest"), userInfo: nil, repeats: true)
        }
        else {
            timer?.invalidate()
        }
        
        // Animate the button transition
        UIView.animateWithDuration(0.3, delay: 0.0, options: nil, animations: {
            self.btnRecordSave.frame = CGRect(origin: newLoc, size: curSize)
            }, completion: { (value: Bool) in
                self.btnRecordSave.backgroundColor = self.recording ? UIColor.greenColor() : UIColor.redColor()
                self.btnRecordSave.setTitle(self.recording ? "Save" : "Record", forState: UIControlState.Normal)
                self.btnRecordSave.setTitle(self.recording ? "Save" : "Record", forState: UIControlState.Highlighted)
        })
        
        UIView.animateWithDuration(0.5, delay: 0.32, usingSpringWithDamping: 0.52, initialSpringVelocity: 0.0, options: nil, animations: {
            self.btnRecordSave.frame = curFrame
            }, completion: nil)
        
        // Flip the recording toggle
        recording = !recording
    }
    
    func saveLatest() {
        var dataEntry = DataEntry()
        
        let curLoc = statTable.lastLocation
        let curAcc = statTable.lastAcc
        let curGyro = statTable.lastGyro
        
        if let acc = curAcc?.acceleration {
            dataEntry.accX = acc.x
            dataEntry.accY = acc.y
            dataEntry.accZ = acc.z
        }
        
        if let gyro = curGyro?.rotationRate {
            dataEntry.gyroX = gyro.x
            dataEntry.gyroY = gyro.y
            dataEntry.gyroZ = gyro.z
        }
        
        if let loc = curLoc {
            dataEntry.altitude = loc.altitude
            dataEntry.course = loc.course
            dataEntry.lat = loc.coordinate.latitude
            dataEntry.long = loc.coordinate.longitude
            dataEntry.horizAcc = loc.horizontalAccuracy
            dataEntry.verAcc = loc.altitude
            dataEntry.altitude = loc.altitude
            dataEntry.altitude = loc.altitude
            dataEntry.altitude = loc.altitude
        }
    }
    
    func changedLocationAccuracy(index: Int) {
        statTable.changedLocationAccuracy(index)
    }
    
    func changeAccRefresh(rate: NSTimeInterval) {
        statTable.motionManager.accelerometerUpdateInterval = 1 / rate
    }
    
    func changedGyroRefresh(rate: NSTimeInterval) {
        statTable.motionManager.gyroUpdateInterval = 1 / rate
    }
    
    func changedPage(index: Int) {
        statTable.changedPage(index)
    }
}

