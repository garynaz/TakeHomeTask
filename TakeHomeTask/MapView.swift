//
//  MapViewTest.swift
//  TakeHomeTask
//
//  Created by Gary Naz on 12/28/21.
//

import SwiftUI
import MapKit
import CoreLocationUI

struct MapView: UIViewRepresentable {
    
    @EnvironmentObject var viewModel: MapViewModel
    
    @Binding var region: MKCoordinateRegion
    @Binding var lineCoordinates: [[CLLocationCoordinate2D]]
    
    func makeUIView(context: Context) -> MKMapView {
        
        let mapView = MKMapView()
        mapView.delegate = context.coordinator
        mapView.region = region
        mapView.showsUserLocation = true
        
        return mapView
    }
    
    func updateUIView(_ view: MKMapView, context: Context) {
        
        if viewModel.locationToggle == true {
            view.setRegion(MKCoordinateRegion(center: MapDetails.altLocation, span: MKCoordinateSpan(latitudeDelta: 5, longitudeDelta: 5)), animated: false)
        } else {
            view.setRegion(region, animated: false)
        }
        
        
        for i in viewModel.locations {
            let pin = MKPointAnnotation()
            pin.coordinate = i.coordinate
            pin.title = i.name
            
            view.addAnnotation(pin)
        }
        
        for i in lineCoordinates {
            let polyline = MKPolyline(coordinates: i, count: i.count)
            view.addOverlay(polyline)
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    
}

class Coordinator: NSObject, MKMapViewDelegate {
    
    var parent: MapView
    
    init(_ parent: MapView) {
        self.parent = parent
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let identifier = "Placemark"
        
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
        
        if annotationView == nil {
            annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            annotationView?.canShowCallout = true
        } else {
            annotationView?.annotation = annotation
        }
        
        return annotationView
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if let routePolyline = overlay as? MKPolyline {
            let renderer = MKPolylineRenderer(polyline: routePolyline)
            renderer.strokeColor = UIColor.systemBlue
            renderer.lineWidth = 10
            return renderer
        }
        return MKOverlayRenderer()
    }
}



struct ContentView: View {
    
    @EnvironmentObject var viewModel: MapViewModel
    
    var body: some View {
        ZStack(alignment: .bottom) {
            ZStack {
                MapView(region: $viewModel.region, lineCoordinates: $viewModel.lineCoordinates)
                    .environmentObject(viewModel)
                    .onAppear{
                        viewModel.checkIfLocationServicesIsEnabled()
                    }
                    .edgesIgnoringSafeArea(.all)
            }
            
            Button {
                viewModel.locationToggle.toggle()
            } label: {
                Text("Toggle Location")
            }
            .padding()
            .background(Color(uiColor: .systemBlue))
            .foregroundColor(.white)
            .cornerRadius(8)
            
            if viewModel.alert {
                ErrorView(alert: viewModel.alert, error: viewModel.error)
            }
        }
        
        
        
    }
}
