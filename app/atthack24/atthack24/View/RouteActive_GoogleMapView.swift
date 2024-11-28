//
//  RouteActive_GoogleMapView.swift
//  atthack24
//
//  Created by Tom on 28.11.2024.
//

import SwiftUI

struct RouteActive_GoogleMapView: View {
    @EnvironmentObject var app: AppData
    private let dataFetcher = CallAPI()
    
    @State private var urlString: String = ""
    @State private var isLoading: Bool = true
    @State private var showError: Bool = false
    @State private var errorMessage: String = ""
    
    var body: some View {
        VStack {
            if isLoading {
                ProgressView("Načítání trasy...")
                    .padding()
            } else if showError {
                ErrorView(errorMessage: errorMessage) {
                    loadRouteURL() // Retry action
                }
            } else if let url = URL(string: urlString) {
                NavigationStack {
                    WebView(url: url)
                        .ignoresSafeArea()
                        .navigationTitle("Navigace")
                        .navigationBarTitleDisplayMode(.inline)
                }
                .frame(width: 400, height: 600)
            }
        }
        .onAppear(perform: loadRouteURL)
    }
    
    /// Load the route URL from the API
    private func loadRouteURL() {
        guard app.startLatitude != 0, app.startLongitude != 0, app.goalLatitude != 0, app.goalLongitude != 0 else {
            showErrorState(message: "Souřadnice nejsou dostupné.")
            return
        }
        
        let urlString = """
        https://server-gedu3pbu3q-lm.a.run.app/route/start_latitude=\(app.startLatitude)&start_longitude=\(app.startLongitude)&destination_latitude=\(app.goalLatitude)&destination_longitude=\(app.goalLongitude)
        """
        
        isLoading = true
        showError = false
        
        dataFetcher.fetchData(from: urlString, responseType: RouteResponse.self) { result in
            DispatchQueue.main.async {
                isLoading = false
                switch result {
                case .success(let response):
                    self.urlString = response.route
                case .failure(let error):
                    showErrorState(message: "Nepodařilo se načíst trasu. Zkuste to prosím znovu.")
                    print("API error: \(error.localizedDescription)")
                }
            }
        }
    }
    
    /// Update the UI to show an error state
    private func showErrorState(message: String) {
        isLoading = false
        showError = true
        errorMessage = message
    }
}

struct ErrorView: View {
    let errorMessage: String
    let retryAction: () -> Void
    
    var body: some View {
        VStack {
            Text(errorMessage)
                .multilineTextAlignment(.center)
                .foregroundColor(.red)
                .padding()
            
            Button(action: retryAction) {
                Text("Zkusit znovu")
                    .bold()
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
        }
        .padding()
    }
}

#Preview {
    RouteActive_GoogleMapView()
        .environmentObject(AppData())
}
