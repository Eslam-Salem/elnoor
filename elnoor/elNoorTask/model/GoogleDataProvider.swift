//
//  googleDataProvider.swift
//  elNoorTask
//
//  Created by Eslam  on 4/25/19.
//  Copyright © 2019 Eslam. All rights reserved.
///Users/user/Desktop/work/elnoor/README.md

import Foundation

import UIKit
import Foundation
import CoreLocation
import SwiftyJSON


class GoogleDataProvider {
    private var placesTask: URLSessionDataTask?
    private var session: URLSession {
        return URLSession.shared
    }
    
    func fetchPlacesNearCoordinate(_ coordinate: CLLocationCoordinate2D, radius: Double, types: String, completion: @escaping ([GooglePlace],Error?) -> Void ){
        var urlString = "https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=\(coordinate.latitude),\(coordinate.longitude)&radius=\(radius)"
        urlString += "&types=\(types)"
        urlString += "&key=\(googleApiKey)"
        urlString = urlString.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed) ?? urlString
        
        guard let url = URL(string: urlString) else {
            print ("completion([])")
            return
        }
        
        if let task = placesTask, task.taskIdentifier > 0 && task.state == .running {
            print ("task.cancel()")
            task.cancel()
        }
        
        DispatchQueue.main.async {
            UIApplication.shared.isNetworkActivityIndicatorVisible = true
        }
        
        placesTask = session.dataTask(with: url) { data, response, error in
            var placesArray: [GooglePlace] = []
           
            func sendError(_ error: String) {
                let userInfo = [NSLocalizedDescriptionKey : error]
                completion([], NSError(domain: "getPlacesRequest", code: 1, userInfo: userInfo))
            }
            
            guard error == nil else {
                if error?.localizedDescription == "cancelled"{
                    return
                }
                DispatchQueue.main.async {
                    completion([],error)}
                return
            }
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode else {
                sendError("Request did not return a valid response.")
                return
            }
            switch (statusCode) {
            case 200 ..< 299:
                break
            default:
                sendError("Please try again later")
            }
            guard let data = data else {
                DispatchQueue.main.async {
                sendError("No Data returned with your Request. Try again!!")
                    completion([], error)}
                return
            }
            do{
            let json = try JSON(data: data, options: .mutableContainers)
            let results = json["results"].arrayObject as? [[String: Any]]
            results!.forEach {
                let place = GooglePlace(dictionary: $0, acceptedTypes: [types])
                placesArray.append(place)
                //Places.savedPlaces.append(place)
            }
            DispatchQueue.main.async {
                completion(placesArray,nil)
                }
            } catch {
                completion([],error)
            }
        }
        placesTask?.resume()
    }
}
