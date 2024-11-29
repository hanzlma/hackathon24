//
//  SearchFiltersView.swift
//  atthack24
//
//  Created by Tom on 28.11.2024.
//

import SwiftUI
import Combine

import Foundation

struct SearchFiltersView: View {
    @Binding var isSearched: Bool
    @State private var searchRequest = SearchRequest()
    @State private var showAlert = false
    @State private var showAlert2 = false
    @EnvironmentObject var app: AppData
    @StateObject private var locationManager = LocationManager()
    
    
    @State private var disableBtn = false
    
    
    private let dataFetcher = CallAPI()
    
    var body: some View {
        VStack {
            
            HeaderView()
                .padding(.bottom, 15)
            
            InputFieldsView()
                .zIndex(1)
            
            DatePicker("Čas odjezdu", selection: $searchRequest.when, displayedComponents: .hourAndMinute)
                .datePickerStyle(.automatic)
            
                .onAppear {
                    locationManager.startUpdatingLocation()
                }
                .onDisappear {
                    locationManager.stopUpdatingLocation()
                }
            
            
            RoundedButton(
                text: "Vyhledat",
                image: Image(systemName: "magnifyingglass"),
                setMaxWidth: true
            ) {
                searchButtonTapped()
                
            }.disabled(disableBtn)
            
            .alert(isPresented: $showAlert) {
                Alert(
                    title: Text("Chyba"),
                    message: Text("Prosím, vyplňte cílovou destinaci potřebnou k vyhledání spoje"),
                    dismissButton: .default(Text("OK"))
                )
            }
            .alert(isPresented: $showAlert2) {
                Alert(
                    title: Text("Chyba"),
                    message: Text("Omlouváme se, ale ve vyhledávání spoje se vyskytla chyba. Prosíme, zkuste buď jiná místa, či později znovu."),
                    dismissButton: .default(Text("OK"))
                )
            }
            
        }
        .padding()
        .onAppear {
            populateFieldsFromAppData()
            
        }
    }
    
    private func HeaderView() -> some View {
        VStack {
            /*Image("tram").resizable().frame(width: 200, height: 200)
             Text("Press & Go")
             .foregroundColor(Color.primaryColor)
             .bold()
             .font(.largeTitle)
             .padding(.top, -40)
             */
            
            Image(systemName: "bus.fill").resizable().frame(width: 125, height: 135)
            Text("Press & Go")
                .foregroundColor(Color.primaryColor)
                .bold()
                .font(.largeTitle)
            //.padding(.top, -40)
        }
    }
    
    private func InputFieldsView() -> some View {
        VStack {
            HStack {
                Image(systemName: "location.fill")
                    .foregroundColor(.gray)
                TextField("Moje poloha", text: $searchRequest.startPlace)
                    .padding(.vertical, 8)
            }
            .padding(.horizontal)
            .background(Color(.systemGray6))
            .cornerRadius(8)
            .padding(.bottom, 6)
            
            
            
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.gray)
                TextField("Kam", text: $searchRequest.goalPlace)
                    .padding(.vertical, 8)
            }
            .padding(.horizontal)
            .background(Color(.systemGray6))
            .cornerRadius(8)
            .padding(.bottom, 0.2)
        }
    }
    
    private func searchButtonTapped() {
        if validateFields() {
            disableBtn = true
            
            app.startPlace = searchRequest.startPlace
            app.goalPlace = searchRequest.goalPlace
            app.dTime = searchRequest.when
            
            var url = "https://server-gedu3pbu3q-lm.a.run.app/routes/time=\(app.apiTime)&start=\(searchRequest.startPlace)&destination=\(searchRequest.goalPlace)"
            
            if searchRequest.startPlace.isEmpty, let location = locationManager.location {
                app.startLatitude = location.coordinate.latitude
                app.startLongitude = location.coordinate.longitude
                app.startPlace = "Má poloha"
                
                url = "https://server-gedu3pbu3q-lm.a.run.app/routes/time=\(app.apiTime)&start_latitude=\(location.coordinate.latitude)&start_longitude=\(location.coordinate.longitude)&destination=\(searchRequest.goalPlace)"
                
            }
            print(url)
            
            fetchRoutes(api: dataFetcher, app: app, urlString: url) { routes, success in
                if success {
                    print("Fetched Routes: \(routes ?? [])")
                    app.routes = routes ?? []
                    isSearched = true
                    disableBtn = false
                    
                } else {
                    showAlert2 = true // Show error alert
                    disableBtn = false
                    
                }
            }
            
           
            
            //todo get coords
            //isSearched = true ///conditional?
            //showAlert2 = true //pokud spatny vyhledavani
            
            print(app.apiTime)
            
            //todo get routes
        } else {
            showAlert = true
        }
    }
    
    private func validateFields() -> Bool {
        !searchRequest.goalPlace.isEmpty
    }
    
    private func populateFieldsFromAppData() {
        if !app.startPlace.isEmpty {
            searchRequest.startPlace = app.startPlace == "Má poloha" ? "" : app.startPlace
        }
        if !app.goalPlace.isEmpty {
            searchRequest.goalPlace = app.goalPlace
        }
        searchRequest.when = app.dTime
    }
}



struct FetchedRouteData: Codable {
    struct LocationData: Codable {
        let lat: Double
        let lng: Double
    }
    
    struct PlaceData: Codable {
        let location: LocationData
        let name: String
    }
    
    struct TimeData: Codable {
        let text: String
        let time_zone: String
        let value: Int
    }
    
    let start: PlaceData
    let end: PlaceData
    let start_t: TimeData
    let end_t: TimeData
    let short_name: String
}


struct FetchedRouteResponse: Codable {
    let data: [FetchedRouteData]
}

func fetchRoutes(api: CallAPI, app: AppData, urlString: String, completion: @escaping ([Route]?, Bool) -> Void) {
    api.fetchData(from: urlString, responseType: FetchedRouteResponse.self) { result in
        switch result {
        case .success(let routeResponse):
            DispatchQueue.main.async {
                
                
                let routes: [Route] = routeResponse.data.map { fetchedData in
                    // Convert start_t.value and end_t.value (timestamps) to readable time strings
                    let startTime = convertTimestampToTimeString(fetchedData.start_t.value)
                    let endTime = convertTimestampToTimeString(fetchedData.end_t.value)
                    
                    // Calculate delay in minutes
                    let delay = (fetchedData.end_t.value - fetchedData.start_t.value) / 60 // Delay in minutes
                    
                    // Map to Route struct
                    return Route(
                       delay: delay,
                       routeName: fetchedData.short_name,
                       time1: startTime,
                       time2: endTime,
                       station1: fetchedData.start.name,
                       station2: fetchedData.end.name,
                       startLatitude: fetchedData.start.location.lat,
                       startLongitude: fetchedData.start.location.lng,
                       endLatitude: fetchedData.end.location.lat,
                       endLongitude: fetchedData.end.location.lng
                    )
                    
                }
                completion(routes, true) // Pass the mapped routes to the completion handler
            }
        case .failure(let error):
            DispatchQueue.main.async {
                print("Failed to fetch routes: \(error.localizedDescription)")
                
                completion(nil, false) // Pass nil and failure status
            }
        }
    }
}
private func convertTimestampToTimeString(_ timestamp: Int) -> String {
    let date = Date(timeIntervalSince1970: TimeInterval(timestamp))
    let formatter = DateFormatter()
    formatter.dateFormat = "HH:mm" // Use 24-hour format
    formatter.timeZone = TimeZone.current
    return formatter.string(from: date)
}







#Preview {
    SearchFiltersView(isSearched: .constant(false))
        .environmentObject(AppData())
}
