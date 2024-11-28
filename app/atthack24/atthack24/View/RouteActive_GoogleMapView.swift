//
//  RouteActive_GoogleMapView.swift
//  atthack24
//
//  Created by Tom on 28.11.2024.
//

import SwiftUI

struct RouteActive_GoogleMapView: View {
    @EnvironmentObject var app: AppData
    
    let dataFetcher = CallAPI()
    @State var urlString = ""
    
    var body: some View {
        VStack {
            if urlString != ""{
                NavigationStack {
                    WebView(url: URL(string: urlString)!)
                        .ignoresSafeArea()
                        .navigationTitle("Navigace")
                        .navigationBarTitleDisplayMode(.inline)
                }.frame(width: 400, height: 600)
            }
        }
        .onAppear{
            loadURLfromGPS()
        }
    }
    
    private func loadURLfromGPS() {
        
        
        let urlString = "https://server-gedu3pbu3q-lm.a.run.app/route/start_latitude=\(app.startLatitude)&start_longitude=\(app.startLongitude)&destination_latitude=\(app.goalLatitude)&destination_longitude=\(app.goalLongitude)"
        
        print(urlString)
        dataFetcher.fetchData(from: urlString, responseType: RouteResponse.self) { result in
            switch result {
            case .success(let response):
                self.urlString = response.route
                print("App URL creation: \(urlString)")
                
            case .failure(let error):
                print("API didn't respond well: \(error)")
            }
        }
    }
}

#Preview {
    RouteActive_GoogleMapView()
        .environmentObject(AppData())
}
