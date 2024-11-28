//
//  ContentView.swift
//  atthack24
//
//  Created by Tom on 28.11.2024.
//

import SwiftUI
import CoreData

struct ContentView: View {
    @StateObject var app = AppData()
    
    var body: some View {
        
        if app.activeSlide == 0{
            SearchView()
            .environmentObject(app)
            .onAppear {
                //app.test = 1
            }
        }else{
            RouteActiveView()
                .environmentObject(app)
        }
        
    }
}

#Preview {
    ContentView()
}

extension Color {
    static let primaryColor = Color.orange
    static let primaryTextColor = Color.white
    static let secondaryColor = Color.orange
    static let thirdColor = Color.blue
}
