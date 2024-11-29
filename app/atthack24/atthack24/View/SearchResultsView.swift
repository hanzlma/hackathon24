//
//  SearchResultsView.swift
//  atthack24
//
//  Created by Tom on 28.11.2024.
//


import SwiftUI

struct SearchResultsView: View {
    @EnvironmentObject var app: AppData
    @Binding var isSearched: Bool
    
    @State private var groupedRoutes: [[Route]] = [
        [
            Route(delay: 0, routeName: "Tram 1", time1: "10:00", time2: "10:10", station1: "Vozovna Komín", station2: "Brno - Náměstí"),
            Route(delay: 5, routeName: "Tram 2", time1: "10:12", time2: "10:20", station1: "Brno - Náměstí", station2: "Brno - Centrum")
        ],
        [
            Route(delay: 3, routeName: "Tram 9", time1: "10:04", time2: "10:09", station1: "Vozovna Komín", station2: "Brno - Hlavní nádraží")
        ],
        [
            Route(delay: 0, routeName: "Tram 9", time1: "10:09", time2: "10:13", station1: "Vozovna Komín", station2: "Brno - Hlavní nádraží")
        ],
        [
            Route(delay: 0, routeName: "Bus 900", time1: "10:00", time2: "10:10", station1: "Vozovna Komín", station2: "Varšava"),
            Route(delay: 5, routeName: "Tram 2", time1: "10:12", time2: "10:20", station1: "Varšava", station2: "Brno - Hlavní nádraží"),
            Route(delay: 0, routeName: "Tram 1", time1: "10:12", time2: "10:20", station1: "Varšava", station2: "Brno - Hlavní nádraží")
        ],
    ]
    
    @State private var selectedRouteGroup: [Route]?
    
    var body: some View {
        NavigationSplitView {
            GroupListView(groupedRoutes: $groupedRoutes, isSearched: $isSearched)
                .environmentObject(app)
        } detail: {
            if let selectedGroup = selectedRouteGroup {
                RouteDetailView(routes: .constant(selectedGroup))
            } else {
                EmptyDetailView()
            }
        }
    }
}

struct GroupListView: View {
    @Binding var groupedRoutes: [[Route]]
    @Binding var isSearched: Bool
    @EnvironmentObject var app: AppData
    
    var body: some View {
        VStack {
            RoundedButton(
                text: "Zpět na vyhledávání",
                image: Image(systemName: "arrowtriangle.left.circle.fill"),
                setMaxWidth: true
            ) {
                isSearched = false
            }
            .padding()
            
            List(Array(groupedRoutes.enumerated()), id: \.offset) { index, group in
                NavigationLink(destination: RouteDetailView(routes: .constant(group))) {
                    RouteGroupView(routes: .constant(group))
                        .environmentObject(app)
                }
            }
        }
    }
}

struct EmptyDetailView: View {
    var body: some View {
        Text("Vyberte skupinu tras")
            .foregroundStyle(.secondary)
            .font(.title3)
            .padding()
    }
}

#Preview {
    SearchResultsView(isSearched: .constant(true))
        .environmentObject(AppData())
}



/*
 Text("\(app.goalPlace)").font(.subheadline)
 Text("\(app.goalLatitude)")
 Text("\(app.goalLongitude)")
 Divider()
 Text("\(app.startPlace)").font(.subheadline)
 Text("\(app.startLatitude)")
 Text("\(app.startLongitude)")
 
 Divider()
 
 Text("Closest Name: \(app.goalClosestName)").font(.subheadline)
 Text("Closest ID: \(app.goalClosestID)")
 Text("Latitude: \(app.goalClosestLatitude)")
 Text("Longitude: \(app.goalClosestLongitude)")
 
 Divider()
 
 Text("Closest Name: \(app.startClosestName)").font(.subheadline)
 Text("Closest ID: \(app.startClosestID)")
 Text("Latitude: \(app.startClosestLatitude)")
 Text("Longitude: \(app.startClosestLongitude)")
 */
