//
//  ErrorView.swift
//  TakeHomeTask
//
//  Created by Gary Naz on 12/27/21.
//

import Foundation
import SwiftUI

struct ErrorView: View {
    @EnvironmentObject var viewModel: MapViewModel
    
    @State var color = Color.black.opacity(0.7)
    var alert: Bool?
    var error: String?
    
    var body : some View {
        VStack {
            HStack {
                Text("Error")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(self.color)
                
                Spacer()
            }
            .padding(.horizontal, 25)
            
            Text(self.error!)
                .foregroundColor(self.color)
                .padding(.top)
                .padding(.horizontal, 25)
            
            Button {
                viewModel.alert.toggle()
            } label: {
                Text("Cancel")
                    .foregroundColor(color)
                    .padding(.vertical)
                    .frame(width: UIScreen.main.bounds.width - 120)
            }
            .background(Color.white)
            .cornerRadius(10)
            .padding(.top, 25)
            
        }
        .padding(.vertical, 25)
        .frame(width: UIScreen.main.bounds.width - 70)
        .background(.ultraThinMaterial)
        .cornerRadius(15)
    }
    
}
