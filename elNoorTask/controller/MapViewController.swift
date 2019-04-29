//
//  ViewController.swift
//  elNoorTask
//
//  Created by Eslam  on 4/23/19.
//  Copyright © 2019 Eslam. All rights reserved.
//

import UIKit
import GoogleMaps
import GooglePlaces
import UserNotifications

class MapViewController: UIViewController {

    @IBOutlet weak var mapView: GMSMapView!
    @IBOutlet private weak var mapCenterPinImage: UIImageView!
    @IBOutlet private weak var pinImageVerticalConstraint: NSLayoutConstraint!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var refreshButton: UIBarButtonItem!
    @IBOutlet weak var drawPolyButton: UIBarButtonItem!

    var placesCount = 0
    let rect = GMSMutablePath()
    private let dataProvider = GoogleDataProvider()
    let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.delegate = self
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
    }
    
    @IBAction func back(_ sender: Any) {
        Places.savedPlaces.removeAll()
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func refreshPlaces(_ sender: Any) {
        Places.savedPlaces.removeAll()
        rect.removeAllCoordinates()
        fetchNearbyPlaces(coordinate: mapView.camera.target)
        drawPolyButton.isEnabled = true
    }
    
    @IBAction func drawPoly(_ sender: Any) {
        polygon()
        drawPolyButton.isEnabled = false
    }
    
    // Create the polygon, and assign it to the map.
    func polygon(){
        let placesToDraw = Places.savedPlaces
        for place in placesToDraw{
           rect.add(place.coordinate)
        }
        let polyline = GMSPolyline(path: rect)
        polyline.strokeColor = .black
        polyline.strokeWidth = 2
        polyline.map = self.mapView
    }
    
    // Use dataProvider to query Google for nearby places within the searchRadius, filtered to the user’s selected types. but clear the map from any markers first.
    private func fetchNearbyPlaces(coordinate: CLLocationCoordinate2D) {
        mapView.clear()
        dataProvider.fetchPlacesNearCoordinate(coordinate, radius:SearchingCriteria.searchingRadius, types: SearchingCriteria.searchingType, completion: handleResponse(places:error:))
    }
    //handling the response of completion handler of the request to show alert view of the result
    func handleResponse(places: [GooglePlace], error: Error?) {
        if error != nil{
            raiseAlertView(withTitle: "Error occured!!", withMessage: "\(error! .localizedDescription) please try again ." )
            print(error!)
        } else {
            places.forEach {
                let marker = PlaceMarker(place: $0)
                marker.map = self.mapView
            }
            raiseAlertView(withTitle: "Searching Completed", withMessage: "you have \(places.count) \(SearchingCriteria.searchingType)s near to you")
            self.sendNotification()
        }
    }
    // get the distance between user location and each place location found and if ane place is about notification radius (1 km) to my location send a notification
    func sendNotification (){
        let myPlaces = Places.savedPlaces
        let endLocation2d = SearchingCriteria.myCurrentLocation
        let endLocation = CLLocation(latitude: endLocation2d.latitude, longitude: endLocation2d.longitude)
        var distance: CLLocationDistance
        var startLocation : CLLocation
        
        for place in myPlaces{
            startLocation = CLLocation(latitude: place.coordinate.latitude, longitude: place.coordinate.longitude)
            distance = startLocation.distance(from: endLocation)
            if distance < SearchingCriteria.notificationRadius {
                let distanceApprox = Double(round(distance)/1000)
                let content = UNMutableNotificationContent()
                content.title = place.name
                content.body = "(\(distanceApprox))KM from you"
                content.sound = UNNotificationSound.default
                let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 2, repeats: false)
                let request = UNNotificationRequest(identifier: place.name, content: content, trigger: trigger)
                UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
            }
        }
    }
    // to get the print the user location in the bottom label 
    private func reverseGeocodeCoordinate(_ coordinate: CLLocationCoordinate2D) {
        // Creates a GMSGeocoder object to turn a latitude and longitude coordinate into a street address.
        let geocoder = GMSGeocoder()
        // Asks the geocoder to reverse geocode the coordinate passed to the method. It then verifies there is an address in the response of type GMSAddress. This is a model class for addresses returned by the GMSGeocoder.
        geocoder.reverseGeocodeCoordinate(coordinate) { response, error in
            guard let address = response?.firstResult(), let lines = address.lines else {
                return
            }
            self.addressLabel.unlock()
            // Sets the text of the addressLabel to the address returned by the geocoder.
            self.addressLabel.text = lines.joined(separator: "\n")
            // Once the address is set, animate the changes in the label’s intrinsic content size.
            // to avoid the hiding of the google word and the button
            let labelHeight = self.addressLabel.intrinsicContentSize.height
            self.mapView.padding = UIEdgeInsets(top: self.view.safeAreaInsets.top, left: 0,
                                                bottom: labelHeight, right: 0)
            //to get the pin in the correct place in the view
            UIView.animate(withDuration: 0.25) {
                self.pinImageVerticalConstraint.constant = ((labelHeight - self.view.safeAreaInsets.top) * 0.5)
                self.view.layoutIfNeeded()
            }
        }
    }
}
//****************************************************************************************
//**************************************Extension For Location Delegate********************
//****************************************************************************************
extension MapViewController: CLLocationManagerDelegate {
    // is called when the user grants or revokes location permissions.
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        // Here you verify the user has granted you permission while the app is in use.
        guard status == .authorizedWhenInUse else {
            return
        }
        // Once permissions have been established, ask the location manager for updates on the user’s location.
        locationManager.startUpdatingLocation()
        // GMSMapView has two features concerning the user’s location: myLocationEnabled draws a light blue dot where the user is located, while myLocationButton, when set to true, adds a button to the map that, when tapped, centers the map on the user’s location.
        mapView.isMyLocationEnabled = true
        mapView.settings.myLocationButton = true
    }
    // executes when the location manager receives new location data.
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else {
            return
        }
        //the user can reasonably expect to see places nearby when the app launches.
        fetchNearbyPlaces(coordinate: location.coordinate)
        SearchingCriteria.myCurrentLocation = location.coordinate
        // This updates the map’s camera to center around the user’s current location. The GMSCameraPosition class aggregates all camera position parameters and passes them to the map for display.
        let currentLocation = GMSCameraPosition(target: location.coordinate, zoom: 14, bearing: 0, viewingAngle: 0)
        mapView.animate(to: currentLocation)
        // Tell locationManager you’re no longer interested in updates; you don’t want to follow a user around as their initial location is enough for you to work with.
        locationManager.stopUpdatingLocation()
    }
}
//****************************************************************************************
//**************************************Extension For Map Delegate*************************
//****************************************************************************************
extension MapViewController: GMSMapViewDelegate {
    //This method is called each time the map stops moving and settles in a new position, where you then make a call to reverse geocode the new position and update the addressLabel‘s text.
    func mapView(_ mapView: GMSMapView, idleAt position: GMSCameraPosition) {
        reverseGeocodeCoordinate(position.target)
    }
    //This method is called every time the map starts to move. It receives a Bool that tells you if the movement originated from a user gesture, such as scrolling the map, or if the movement originated from code. You call the lock() on the addressLabel to give it a loading animation.
    func mapView(_ mapView: GMSMapView, willMove gesture: Bool) {
        addressLabel.lock()
        if (gesture) {
            mapCenterPinImage.fadeIn(0.25)
            mapView.selectedMarker = nil
        }
    }
    func mapView(_ mapView: GMSMapView, markerInfoContents marker: GMSMarker) -> UIView? {

        guard let placeMarker = marker as? PlaceMarker else {
            return nil
        }
        placeMarker.title = placeMarker.place.name
        return placeMarker.iconView
    }
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        mapCenterPinImage.fadeOut(0.25)
        return false
    }
    func didTapMyLocationButton(for mapView: GMSMapView) -> Bool {
        mapCenterPinImage.fadeIn(0.25)
        mapView.selectedMarker = nil
        return false
    }
}
