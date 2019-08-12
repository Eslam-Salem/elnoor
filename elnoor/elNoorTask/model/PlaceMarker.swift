//
//  PlaceMarker.swift
//  elNoorTask
//
//  Created by Eslam  on 4/25/19.
//  Copyright © 2019 Eslam. All rights reserved.
//
import UIKit
import GoogleMaps
import UserNotifications
class PlaceMarker: GMSMarker {
    
    let place: GooglePlace
    
    init(place: GooglePlace) {
        self.place = place
        super.init()
        position = place.coordinate
        icon = UIImage(named: place.placeType+"_pin")
        groundAnchor = CGPoint(x: 0.5, y: 1)
        appearAnimation = .pop
        Places.savedPlaces.append(place)
    }
    
}
