//
//  SearchFiltersView.swift
//  atthack24
//
//  Created by Tom on 28.11.2024.
//

import SwiftUI
import Combine

struct SearchFiltersView: View {
    
    @Binding var isSearched: Bool
    
    @State private var searchRequest = SearchRequest()
    @State private var showAlert = false
    
    @EnvironmentObject var app: AppData
    
    @StateObject private var locationManager = LocationManager()
    
    private let words = ["StationABC", "StationBCD","StationABD","StationABF","StationBCA", "Brno"]
    @State private var suggestions: [String] = []
    
    let dataFetcher = CallAPI()

    
    var body: some View {
        VStack {
            VStack {
                
            }
            .onAppear {
                locationManager.startUpdatingLocation()
            }
            .onDisappear {
                locationManager.stopUpdatingLocation()
            }
            .padding()
            
            ZStack(alignment: .topLeading) {
                VStack {
                    TextField("Moje poloha", text: $searchRequest.startPlace)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                        .onChange(of: searchRequest.startPlace) { newValue in
                            //updateSuggestions(for: newValue)
                        }
                }
                
                if !suggestions.isEmpty {
                    VStack(alignment: .leading, spacing: 0) {
                        ForEach(suggestions, id: \.self) { suggestion in
                            Text(suggestion)
                                .padding()
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(Color.white)
                                .onTapGesture {
                                    searchRequest.startPlace = suggestion
                                    suggestions = []
                                }
                        }
                    }
                    .background(Color.white)
                    .cornerRadius(8)
                    .shadow(radius: 5)
                    .padding(.top, 50)
                }
            }
            .zIndex(100)
            //NEFUNGUJE?
            
            
            
            TextField("Kam", text: $searchRequest.goalPlace)
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(8)
            
            DatePicker("Čas odjezdu", selection: $searchRequest.when, displayedComponents: .hourAndMinute)
            
            
            RoundedButton(
                text: "Vyhledat",
                image: Image(systemName: "magnifyingglass"),
                setMaxWidth: true
                
            ) {
                if validateFields() {
                    app.startPlace = searchRequest.startPlace
                    app.goalPlace = searchRequest.goalPlace
                    app.dTime = searchRequest.when
                    
                    if searchRequest.startPlace.isEmpty {
                        if let location = locationManager.location {
                            app.startLatitude = location.coordinate.latitude
                            app.startLongitude = location.coordinate.longitude
                            app.startPlace = "Má poloha"
                        }
                    }
                   
                           
                    if(searchRequest.startPlace == ""){
                        // /routes/time={time}&start_latitude={lat}&start_longitude={lng}&destination={dest}
                    }
                    else{
                        // /routes/time={time}&start={start}&destination={dest}
                    }
                    
                    //fetchGPSAndClosestLocations()
                    
                    isSearched = true
                    
                } else {
                    showAlert = true
                }
                
            }.alert(isPresented: $showAlert) {
                Alert(
                    title: Text("Chyba"),
                    message: Text("Prosím, vyplňte cílovou destinaci potřebnou k vyhledání spoje"),
                    dismissButton: .default(Text("OK"))
                )
            }
        }.padding()
            .onAppear{
                if !app.startPlace.isEmpty {
                    searchRequest.startPlace = app.startPlace
                }
                if !app.goalPlace.isEmpty {
                    searchRequest.goalPlace = app.goalPlace
                }
                searchRequest.when = app.dTime
            }
    }
    private func validateFields() -> Bool {
        
        return !searchRequest.goalPlace.isEmpty
    }
    
    private func updateSuggestions(for input: String) {
        if input.isEmpty {
            suggestions = []
        } else {
            let matches = words.filter { $0.lowercased().contains(input.lowercased()) }
            suggestions = matches.count < 5 ? matches : []
            //5 moznisti a mene, zobrazi se, jinak ne.
        }
    }
    
    
//    API CALL
  

        
        
    
    //TODO dodealt az bude zprovoznene
    private func loadClosest(latitude: Double, longitude: Double, completion: @escaping (Result<ClosestResponse, Error>) -> Void) {
        let urlString = "https://server-gedu3pbu3q-lm.a.run.app/closest/latitude=\(latitude)&longitude=\(longitude)"
        
        print("Request URL: \(urlString)")
        dataFetcher.fetchData(from: urlString, responseType: ClosestResponse.self) { result in
            switch result {
            case .success(let response):
                completion(.success(response)) // Pass the response to the completion handler
            case .failure(let error):
                completion(.failure(error)) // Pass the error to the completion handler
            }
        }
    }

    
    
}

#Preview {
    SearchFiltersView(isSearched: .constant(false))
        .environmentObject(AppData())
}
