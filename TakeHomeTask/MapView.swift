//
//  ContentView.swift
//  TakeHomeTask
//
//  Created by Gary Naz on 12/21/21.
//

import SwiftUI
import MapKit
import CoreLocationUI

struct MapView: View{
    
    @EnvironmentObject var viewModel: MapViewModel
    
    var body: some View{
        ZStack{
            ZStack(alignment: .bottom){
                Map(coordinateRegion: $viewModel.region, showsUserLocation: true, annotationItems: viewModel.locations){ location in
                    
                    MapAnnotation(coordinate: location.coordinate){
                        VStack(spacing: 0){
                            Text(location.name)
                                .font(.callout)
                                .padding(5)
                                .background(Color(.white))
                                .foregroundColor(Color(.black))
                                .cornerRadius(10)
                                .opacity(viewModel.showPoiTitle ? 1 : 0)
                            
                            Image(systemName: "mappin.circle.fill")
                                .font(.title)
                                .foregroundColor(.red)
                            
                            Image(systemName: "arrowtriangle.down.fill")
                                .font(.caption)
                                .foregroundColor(.red)
                                .offset(x: 0, y: -5)
                        }
                        .onTapGesture{
                            withAnimation(.easeInOut){
                                viewModel.showPoiTitle.toggle()
                            }
                        }
                        
                    }
                    
                }
                .ignoresSafeArea()
                .accentColor(Color(.systemPink))
                .onAppear{
                    viewModel.checkIfLocationServicesIsEnabled()
                }
                
                LocationButton(.currentLocation){
                    viewModel.requestAllowOnceLocationPermission()
                }
                .foregroundColor(.white)
                .cornerRadius(8)
                .labelStyle(.titleAndIcon)
                .padding(.bottom, 50)
                
            }
            
            if viewModel.alert{
                ErrorView(alert: viewModel.alert, error: viewModel.error)
            }
        }
        
        
    }
}

struct ContentView_Previews: PreviewProvider{
    static var previews: some View{
        MapView()
    }
}
