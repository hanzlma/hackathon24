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
                    RouteHeaderView(startPlace: app.startPlace, goalPlace: app.goalPlace)
                    
                    ForEach(app.routes.indices, id: \.self) { index in
                        RouteCard(route: app.routes[index], index: index, isLast: index == app.routes.count - 1)
                            .padding(.horizontal)
                    }
                    
                    ActionButtonsView()
                        .padding()
                }
            }
            .safeAreaInset(edge: .top) {
                Color.white.frame(height: 0)
            }
            .onAppear {
                requestNotificationPermission()
            }
        }.padding(.top, 1)
    }
    
    /// Request permission for notifications
    private func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if granted {
                NotificationScheduler.scheduleNotification(
                    title: "\(app.startPlace) - \(app.goalPlace)",
                    subtitle: "Blíží se čas odjezdu. Měli byste vyrazit!",
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

struct RouteHeaderView: View {
    let startPlace: String
    let goalPlace: String
    
    var body: some View {
        Text("\(startPlace) - \(goalPlace)")
            .font(.title2)
            .fontWeight(.semibold)
            .foregroundStyle(.secondary)
            .padding()
    }
}

struct RouteCard: View {
    let route: Route
    let index: Int
    let isLast: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(route.routeName)
                .font(.headline)
                .fontWeight(.bold)
                .foregroundStyle(Color.primaryColor)
            
            VStack(alignment: .leading, spacing: 10) {
                RouteDetailItem(time: route.time1, station: route.station1, type: index == 0 ? 1 : 2)
                RouteDetailItem(time: route.time2, station: route.station2, type: isLast ? 3 : 2)
            }
            
            if route.delay > 1 {
                DelayView(delay: route.delay, isDelayed: route.delay > 3)
            }
        }
    }
}

struct ActionButtonsView: View {
    @EnvironmentObject var app: AppData
    
    var body: some View {
        VStack {
            NavigationLink(destination: RouteActive_GoogleMapView().environmentObject(app)) {
                ActionButton(
                    icon: Image(systemName: "map"),
                    title: "Kde je má zastávka",
                    backgroundColor: .blue
                )
            }
            
            Button(action: {
                app.activeSlide = 0
            }) {
                ActionButton(
                    icon: Image(systemName: "arrowtriangle.up.circle.fill"),
                    title: "Změnit cílovou stanici",
                    backgroundColor: Color.primaryColor
                )
            }
            
            Button(action: {
                app.activeSlide = 0
                app.resetSearchData()
            }) {
                ActionButton(
                    icon: Image(systemName: "square.fill"),
                    title: "Ukončit",
                    backgroundColor: .red
                )
            }
            .buttonStyle(PlainButtonStyle())
        }
    }
}

struct ActionButton: View {
    let icon: Image
    let title: String
    let backgroundColor: Color
    
    var body: some View {
        HStack {
            icon
                .resizable()
                .frame(width: 20, height: 20)
                .foregroundColor(.white)
                .padding(.trailing, 5)
            Text(title)
                .fontWeight(.bold)
                .foregroundColor(.white)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(backgroundColor)
        .cornerRadius(30)
    }
}


struct RouteResponse: Decodable {
    let route: String
}


#Preview {
    RouteActiveView()
        .environmentObject(AppData())
}
