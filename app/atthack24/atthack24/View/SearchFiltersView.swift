//
//  SearchFiltersView.swift
//  atthack24
//
//  Created by Tom on 28.11.2024.
//

import SwiftUI
import Combine

import SwiftUI
import Combine

struct SearchFiltersView: View {
    @Binding var isSearched: Bool
    @State private var searchRequest = SearchRequest()
    @State private var showAlert = false
    @EnvironmentObject var app: AppData
    @StateObject private var locationManager = LocationManager()

  
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
            }
            .alert(isPresented: $showAlert) {
                Alert(
                    title: Text("Chyba"),
                    message: Text("Prosím, vyplňte cílovou destinaci potřebnou k vyhledání spoje"),
                    dismissButton: .default(Text("OK"))
                )
            }
        }
        .padding()
        .onAppear { populateFieldsFromAppData() }
    }
    
    private func HeaderView() -> some View {
        VStack {
            Image("tram").resizable().frame(width: 200, height: 200)
            Text("Press & Go")
                .foregroundColor(Color.primaryColor)
                .bold()
                .font(.largeTitle)
                .padding(.top, -40)
        }
    }
    
    private func InputFieldsView() -> some View {
        VStack {
            HStack {
                Image(systemName: "location.fill") // Add magnifying glass icon
                    .foregroundColor(.gray) // Optional: Set icon color
                TextField("Moje poloha", text: $searchRequest.startPlace)
                    .padding(.vertical, 8) // Adjust vertical padding
            }
            .padding(.horizontal)
            .background(Color(.systemGray6))
            .cornerRadius(8)
            .padding(.bottom, 6)

            
            
            HStack {
                Image(systemName: "magnifyingglass") // Add magnifying glass icon
                    .foregroundColor(.gray) // Optional: Set icon color
                TextField("Kam", text: $searchRequest.goalPlace)
                    .padding(.vertical, 8)
            }
            .padding(.horizontal)
            .background(Color(.systemGray6))
            .cornerRadius(8)
        }
    }
    
    private func searchButtonTapped() {
        if validateFields() {
            app.startPlace = searchRequest.startPlace
            app.goalPlace = searchRequest.goalPlace
            app.dTime = searchRequest.when
            
            var url = "https://server-gedu3pbu3q-lm.a.run.app/routes/time=\(searchRequest.when)&start=\(searchRequest.startPlace)&destination=\(searchRequest.goalPlace)"
            
            if searchRequest.startPlace.isEmpty, let location = locationManager.location {
                app.startLatitude = location.coordinate.latitude
                app.startLongitude = location.coordinate.longitude
                app.startPlace = "Má poloha"
                
                url = "https://server-gedu3pbu3q-lm.a.run.app/routes/time=\(searchRequest.when)&start_latitude=\(location.coordinate.latitude)&start_longitude=\(location.coordinate.longitude)&destination=\(searchRequest.goalPlace)"
                
            }
            
            
            
            isSearched = true
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


#Preview {
    SearchFiltersView(isSearched: .constant(false))
        .environmentObject(AppData())
}
