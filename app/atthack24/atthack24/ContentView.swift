//
//  ContentView.swift
//  atthack24
//
//  Created by Tom on 28.11.2024.
//

import SwiftUI
import CoreData
struct ContentView: View {
    @ObservedObject var app: AppData = AppData()

    init() {
        app.load()
    }

    @Environment(\.scenePhase) private var scenePhase

    var body: some View {
        ZStack {
            if app.activeSlide == 0 {
                SearchView()
                    .environmentObject(app)
                    .transition(.move(edge: .top))
            } else {
                RouteActiveView()
                    .environmentObject(app)
                    .transition(.move(edge: .bottom))
            }
        }
        .animation(.easeInOut(duration: 0.3), value: app.activeSlide == 0)
        .onChange(of: scenePhase) { newPhase in
            if newPhase == .background {
                print("Scene entered background. Saving data...") 
                app.save()
            }
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
