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

    @Binding  var groupedRoutes: [[Route]]
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
           .onAppear {
               
               if !app.routes.isEmpty {
                   print("Grouped Routes: \(groupedRoutes)") // Debugging
               }
           }
       }

}
struct GroupListView: View {
    @Binding var groupedRoutes: [[Route]]
    @Binding var isSearched: Bool
    @EnvironmentObject var app: AppData
    @State private var isLoading = true
    
    @State private var isEmpty = false

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
            
            if isEmpty{
                Text("Omlouváme se, ale Vámi zadané zastávky jsme nenašli.").foregroundStyle(Color.red)
            }
            
            if isLoading {
                ProgressView("Načítání tras...")
                    .padding()
            } else if groupedRoutes.isEmpty {
                Text("Omlouváme se, žádné trasy nebyly nalezeny.")
                    .foregroundStyle(.secondary)
                    .font(.title3)
                    .padding()
            } else {
                if !isEmpty{
                    List(Array(groupedRoutes.enumerated()), id: \.offset) { index, group in
                        NavigationLink(destination: RouteDetailView(routes: .constant(group))) {
                            RouteGroupView(routes: .constant(group))
                                .environmentObject(app)
                        }
                    }
                }
            }
            
        }
        .onAppear {
            loadRoutes()
        }
    }

    private func loadRoutes() {
        // Simulate a delay for API fetching
        DispatchQueue.global().async {
            // Add your actual route-fetching logic here if applicable
            sleep(2) // Simulating API call delay
            DispatchQueue.main.async {
                isLoading = false

                // Check if no routes were fetched
                if app.routes.isEmpty {
                    groupedRoutes = []
                    
                    isEmpty = true
                    
                    
                } else {
                    // Assuming groupedRoutes is derived from app.routes
                    groupedRoutes = [app.routes]
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
    //SearchResultsView(isSearched: .constant(true), groupedRoutes: .constant(app.routes))
      //  .environmentObject(AppData())
}



/*

 */
