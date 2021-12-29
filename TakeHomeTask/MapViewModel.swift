//
//  MapViewModel.swift
//  TakeHomeTask
//
//  Created by Gary Naz on 12/21/21.
//

import Polyline
import Combine
import SwiftUI
import MapKit


enum MapDetails {
    static let defaultSpan = MKCoordinateSpan(latitudeDelta: 5, longitudeDelta: 5)
    static let defaultLocation = CLLocationCoordinate2D(latitude: 43.653225, longitude: -79.383186)
    static let altLocation = CLLocationCoordinate2D(latitude: 40.6338031, longitude: 14.6002813)
}

class MapViewModel: NSObject, ObservableObject, CLLocationManagerDelegate {
    
    @Published var alert = false
    @Published var error = ""
    @Published var region = MKCoordinateRegion(center: MapDetails.defaultLocation,
                                               span: MapDetails.defaultSpan)
    @Published var feedElements: [FeedElements] = []
    @Published var lineCoordinates: [[CLLocationCoordinate2D]] = []
    @Published var locations: [Poi] = []
    @Published var locationToggle: Bool = false
    @Published var showPoiTitle: Bool = false
    
    var cancellables = Set<AnyCancellable>()
    var locationManager: CLLocationManager?
    
    
    
    func checkIfLocationServicesIsEnabled() {
        if CLLocationManager.locationServicesEnabled() {
            locationManager = CLLocationManager()
            locationManager!.delegate = self
        } else {
            self.error = "Please turn on your location services."
            self.alert.toggle()
        }
    }
    
    func checkLocationAuthorization() {
        guard let locationManager = locationManager else { return }
        
        switch locationManager.authorizationStatus {
            
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization ()
            locationManager.requestLocation()
        case .restricted:
            self.error = "Your location is restricted likely due to parental controls."
            self.alert.toggle()
        case .denied:
            self.error = "You have denied this app location permission. Go into settings to change it."
            self.alert.toggle()
        case .authorizedAlways, .authorizedWhenInUse:
            locationManager.requestLocation()
        @unknown default:
            break
        }
    }
    
    func requestAllowOnceLocationPermission() {
        locationManager?.requestLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {

        guard let latestLocation = locations.first else {
            self.error = "Unable to retrieve your location..."
            self.alert.toggle()
            return
        }

        if locationToggle == true {
            print("Toggle is True")
            self.region = MKCoordinateRegion(center: MapDetails.altLocation, span: MKCoordinateSpan(latitudeDelta: 5, longitudeDelta: 5))
        } else {
            print("Toggle is False")
            self.region = MKCoordinateRegion(center: latestLocation.coordinate, span: MKCoordinateSpan(latitudeDelta: 5, longitudeDelta: 5))
            getPosts()
        }

    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error.localizedDescription)
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        checkLocationAuthorization()
    }
    
    func getPosts() {
        guard let url = URL(string: "https://tatooine.eatsleepride.com/api/v5/feed/nearby?lat=\(region.center.latitude)&lng=\(region.center.longitude)") else { return }
        
        URLSession.shared.dataTaskPublisher(for: url)
            .receive(on: DispatchQueue.main)
            .tryMap(handleOutput)
            .decode(type: Payload.self, decoder: JSONDecoder())
            .sink { (completion) in
                switch completion {
                case .failure(let error):
                    print("Failed to fetch Data")
                    self.error = "Error: \(error.localizedDescription)"
                    self.alert.toggle()
                case .finished:
                    print("Finished Loading Data")
                }
            } receiveValue: { data in
                self.feedElements = data.payload.items
                    
                self.locations.removeAll()
                self.lineCoordinates.removeAll()
                
                for i in self.feedElements {
                    if i.ctype == "POI" {
                        self.locations.append(Poi(name: i.title, coordinate: CLLocationCoordinate2D(latitude: i.location.lat, longitude: i.location.lng)))
                    } else {
                        self.lineCoordinates.append(decodePolyline(i.data.polyline!)!)
                    }
                }
            }
            .store(in: &cancellables)
    }
    
    func handleOutput(output: URLSession.DataTaskPublisher.Output) throws -> Data {
        guard
            let response = output.response as? HTTPURLResponse,
            response.statusCode >= 200 && response.statusCode < 300 else{
                throw URLError(.badServerResponse)
            }
        return output.data
    }
    
}




