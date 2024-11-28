//
//  RouteActiveView.swift
//  atthack24
//
//  Created by Tom on 28.11.2024.
//

import SwiftUI
import UserNotifications

struct RouteActiveView: View {
    
    @EnvironmentObject var app: AppData
    
    
    
    
    var body: some View {
        
        NavigationStack {
            ScrollView {
                
                LazyVStack(alignment: .leading, spacing: 20) {
                    Text("\(app.startPlace) - \(app.goalPlace)")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundStyle(.secondary)
                        .padding()
                    
                    ForEach(app.routes.indices, id: \.self) { index in
                        let route = app.routes[index]
                        VStack(alignment: .leading, spacing: 10) {
                            Text(route.routeName)
                                .font(.headline)
                                .fontWeight(.bold)
                                .foregroundStyle(Color.primaryColor)
                            
                            VStack(alignment: .leading, spacing: 10) {
                                if index == 0 {
                                    // First route
                                    RouteDetailItem(time: route.time1, station: route.station1, type: 1)
                                } else {
                                    // Intermediate or last routes
                                    RouteDetailItem(time: route.time1, station: route.station1, type: 2)
                                }
                                
                                if index == app.routes.count - 1 {
                                    // Last route
                                    RouteDetailItem(time: route.time2, station: route.station2, type: 3)
                                } else {
                                    // Intermediate or first routes
                                    RouteDetailItem(time: route.time2, station: route.station2, type: 2)
                                }
                            }
                            
                            if route.delay > 1 {
                                DelayView(delay: route.delay, isDelayed: route.delay > 3)
                            }
                        }.padding(.trailing)
                            .padding(.leading)
                    }.padding()
                    
                    VStack{
                        
                        NavigationLink(destination: RouteActive_GoogleMapView().environmentObject(app)) {
                            HStack {
                                Image(systemName: "map")
                                    .resizable()
                                    .frame(width: 20, height: 20)
                                    .foregroundColor(.primaryTextColor)
                                    .padding(.trailing, 5)
                                
                                Text("Kde je má zastávka")
                                    .fontWeight(.bold)
                                    .foregroundColor(.primaryTextColor)
                            }
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.blue)
                            .cornerRadius(30) // Rounded corners
                            
                            
                        }
                        
                        Button(action: {
                            app.activeSlide = 0
                            app.goalPlace = ""
                        }){
                            
                            HStack {
                                Image(systemName: "arrowtriangle.up.circle.fill")
                                    .resizable()
                                    .frame(width: 20, height: 20)
                                    .foregroundColor(.primaryTextColor)
                                    .padding(.trailing, 5)
                                
                                Text("Změnit cílovou stanici")
                                    .fontWeight(.bold)
                                    .foregroundColor(.primaryTextColor)
                            }
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.primaryColor)
                            .cornerRadius(30) // Rounded corners
                        }
                        
                        
                        Button(action: {
                            app.activeSlide = 0
                            
                            app.resetSearchData()
                            
                        }){
                            HStack {
                                Image(systemName: "square.fill")
                                    .resizable()
                                    .frame(width: 12, height: 12)
                                    .foregroundColor(.primaryTextColor)
                                    .padding(.trailing, 9)
                                    .padding(.leading, 4)
                                
                                Text("Ukončit")
                                    .fontWeight(.bold)
                                    .foregroundColor(.primaryTextColor)
                            }
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.red)
                            .cornerRadius(30)
                        }
                        .buttonStyle(PlainButtonStyle())
                        
                    }.padding()
                }
                
                
            }
            
            
            
            
            
            
            
        }
        .onAppear{
            requestNotificationPermission()
        }
    }
    
    func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if granted {
                print("Notification permission granted.")
                NotificationScheduler.scheduleNotification(
                    title: "\(app.startPlace) - \(app.goalPlace)",
                    subtitle: "Blíží se čas odjezdu. Měli by jste vyrazit!",
                    body: "This is your notification scheduled for 17:07.",
                    hour: 17,
                    minute: 20
                )
            } else {
                print("Notification permission denied.")
            }
        }
    }
    
    
    
}

struct RouteResponse: Decodable {
    let route: String
}


#Preview {
    RouteActiveView()
        .environmentObject(AppData())
}
