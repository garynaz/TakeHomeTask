//
//  FeedModel.swift
//  TakeHomeTask
//
//  Created by Gary Naz on 12/25/21.
//

import Foundation
import CoreLocation

struct Payload: Codable{
    var payload: Items
}

struct Items: Codable{
    var items: [FeedElements]
}

struct FeedElements: Codable{
    var title: String
    var ctype: String
    var data: MetaData
    var location: Location
}

struct Location: Codable{
    var lat: Double
    var lng: Double
}

struct MetaData: Codable{
    var origin: PolyOrigin?
    var destination: PolyDesination?
}

struct PolyOrigin: Codable{
    var lat: Double
    var lng: Double
}

struct PolyDesination: Codable{
    var lat: Double
    var lng: Double
}

struct Poi: Identifiable{
    let id = UUID()
    let name: String
    let coordinate: CLLocationCoordinate2D
}
