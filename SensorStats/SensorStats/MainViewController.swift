//
//  ViewController.swift
//  SensorStats
//
//  Created by Kevin Sullivan on 3/1/15.
//  Copyright (c) 2015 SideApps. All rights reserved.
//

import UIKit
import CoreLocation

class StatTableViewController: UITableViewController, UITableViewDelegate, UITableViewDataSource {
    
    var locationManager: CLLocationManager!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
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
            if indexPath.row == 0 {
                var cell = tableView.dequeueReusableCellWithIdentifier("statCell") as! UITableViewCell
                
                cell.textLabel?.text = "Stat"
                cell.detailTextLabel?.text = "Num"
                
                return cell
            }
        }
        
        return UITableViewCell()
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
}

class StatPageViewController: UIPageViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    let titles = ["GPS", "Accelerometer", "Gyroscope"];
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.dataSource = self
        self.delegate = self
        
        self.setViewControllers([StatContentViewController()], direction: UIPageViewControllerNavigationDirection.Forward, animated: false, completion: nil)
    }
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {
        
        var index = (viewController as! StatContentViewController).index
        index++
        
        if index >= titles.count { return nil }
        
        return viewControllerAtIndex(index)
    }
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {
        
        var index = (viewController as! StatContentViewController).index
        index--
        
        if index < 0 { return nil }
        
        return viewControllerAtIndex(index)
    }
    
    func viewControllerAtIndex(index : Int) -> UIViewController? {
        if (titles.count == 0) || (index >= titles.count) {
            return nil
        }
        
        let contentVC = storyboard?.instantiateViewControllerWithIdentifier("statContent") as! StatContentViewController
        contentVC.loadView()
        
        contentVC.lblTitle.text = self.titles[index]
        contentVC.index = index
        
        return contentVC
    }
    
    func presentationCountForPageViewController(pageViewController: UIPageViewController) -> Int {
        return titles.count
    }
    
    func presentationIndexForPageViewController(pageViewController: UIPageViewController) -> Int {
        return 0
    }
}

class StatContentViewController: UIViewController {
    
    @IBOutlet weak var lblTitle: UILabel!
    
    
    var index = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}

class MainViewController: UIViewController, CLLocationManagerDelegate {
    
    var statTableView: StatTableViewController!
    
    let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Initialize the location manager
        
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true;
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "embedStats" {
            statTableView = segue.destinationViewController as! StatTableViewController
            
            statTableView.locationManager = locationManager
        }
    }
}

