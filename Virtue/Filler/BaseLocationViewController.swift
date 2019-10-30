//
//  BaseLocationTableViewController.swift
//  MapKitExample
//
//  Created by Ruohan Ding on 7/25/17.
//  Copyright © 2017 Ding. All rights reserved.
//

import UIKit
import MapKit

class BaseLocationTableViewController: UITableViewController {
    
    var matchingMapItems: [MKMapItem] = []
    var resultSearchController = UISearchController(searchResultsController: nil)
    var searchRequest = MKLocalSearchRequest()
    var locationSearchBar: UISearchBar!
    var eventType = ""
    let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // setting a search controller's controlle to nil uses the current controller. These are just some setting tweks
        resultSearchController.searchResultsUpdater = self
        resultSearchController.hidesNavigationBarDuringPresentation = false
        resultSearchController.dimsBackgroundDuringPresentation = false
        definesPresentationContext = true
        
        // adds a search bar
        locationSearchBar = resultSearchController.searchBar
        locationSearchBar.sizeToFit()
        locationSearchBar.placeholder = "Search for a place or address"
        navigationItem.titleView = resultSearchController.searchBar
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension BaseLocationTableViewController: UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        
        // creates a search with the input
        let searchBarText = searchController.searchBar.text
        
        searchRequest.naturalLanguageQuery = searchBarText
        
        let search = MKLocalSearch(request: searchRequest)
        
        search.start { (response, _) in
            guard let response = response else {
                return
            }
            
            self.matchingMapItems = response.mapItems
            self.tableView.reloadData()
        }
    }
}

extension BaseLocationTableViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        // asks if we can use current location
        if status == .authorizedWhenInUse {
            locationManager.requestLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        // sets a region that around the current location
        if let location = locations.first {
            
            let span = MKCoordinateSpanMake(0.05, 0.05)
            let region = MKCoordinateRegion(center: location.coordinate, span: span)
            
            searchRequest.region = region
        }
        
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        
        // required method
        print("error: \(error)")
    }
}


extension BaseLocationTableViewController{
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return matchingMapItems.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // sets all the necessary values of the table veiw cells
        let locationCell = tableView.dequeueReusableCell(withIdentifier: "locationCell")!
        let selectedItem = matchingMapItems[indexPath.row].placemark
        
        locationCell.textLabel?.text = selectedItem.name
        locationCell.detailTextLabel?.text = selectedItem.title
        
        return locationCell
        
    }
    
}

extension BaseLocationTableViewController{
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        // sets the location label back at third
        let locationCell = tableView.cellForRow(at: indexPath)
        
        // sets the location label of the create view controller
        if eventType == "complex"{
            let previousController = self.navigationController?.viewControllers[(self.navigationController?.viewControllers.count)! - 2] as! ThirdTableViewController
            
            previousController.locationLabel.text = locationCell?.textLabel?.text
            previousController.eventLocation = (locationCell?.detailTextLabel?.text)!
        } else {
            
            let previousController = self.navigationController?.viewControllers[(self.navigationController?.viewControllers.count)! - 2] as! SimpleTableViewController
            
            previousController.locationLabel.text = locationCell?.textLabel?.text
            previousController.eventLocation = (locationCell?.detailTextLabel?.text)!
        }
        
        navigationController?.popViewController(animated: true)
        
    }
    
}

