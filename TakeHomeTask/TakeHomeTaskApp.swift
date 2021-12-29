//
//  TakeHomeTaskApp.swift
//  TakeHomeTask
//
//  Created by Gary Naz on 12/21/21.
//

import SwiftUI

@main
struct TakeHomeTaskApp: App {
    
    @StateObject private var viewModel = MapViewModel()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(viewModel)
        }
    }
}
