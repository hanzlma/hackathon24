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
    
    
    @State private var calculatedTime: String = ""
    @State private var startTime: String = ""
    @State private var travelDuration: String = ""
    
    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 20) {
                    RouteHeaderView(
                        startPlace: app.startPlace,
                        goalPlace: app.goalPlace,
                        estimatedTime: calculatedTime,
                        travelDuration: travelDuration
                    )
                    
                    ForEach(app.routes.indices, id: \.self) { index in
                        RouteCard(route: app.routes[index], index: index, isLast: index == app.routes.count - 1)
                            .padding(.horizontal)
                            .onAppear {
                                if index == 0 {
                                    startTime = app.routes[index].time1
                                    updateTravelDuration()
                                }
                                
                                if index == app.routes.count - 1 {
                                    let lastRoute = app.routes[index]
                                    let lastRouteTime = lastRoute.time2
                                    let delayInMinutes = lastRoute.delay
                                    
                                    if let calculated = addDelayToTime(time: lastRouteTime, delay: delayInMinutes) {
                                        calculatedTime = calculated
                                        updateTravelDuration()
                                    }
                                }
                            }
                        if index != app.routes.count - 1 {
                            Divider().padding([.leading, .trailing])
                        }
                    }
                    Spacer()
                    
                    ActionButtonsView()
                        .padding()
                }
            }
            .safeAreaInset(edge: .top) {
                Color.white.frame(height: 0)
            }
            .onAppear {
                requestNotificationPermission(h:0, m:39)
            }
        }.padding(.top, 1)
    }
    
    func updateTravelDuration() {
        guard !startTime.isEmpty, !calculatedTime.isEmpty else {
            travelDuration = "Bohužel se vyskytla chyba"
            return
        }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        
        guard let startDate = dateFormatter.date(from: startTime),
              let endDate = dateFormatter.date(from: calculatedTime) else {
            travelDuration = "Bohužel se vyskytla chyba"
            return
        }
        
        let components = Calendar.current.dateComponents([.hour, .minute], from: startDate, to: endDate)
        if let hours = components.hour, let minutes = components.minute {
            
            var hDur = ""
            if hours == 1 {
                hDur = "\(hours) hodina"
            } else if hours > 1 && hours < 5 {
                hDur = "\(hours) hodiny"
            } else if hours >= 5 {
                hDur = "\(hours) hodin"
            }
            
            var dMin = ""
            if minutes == 1 {
                dMin = "\(minutes) minuta"
            } else if minutes > 1 && minutes < 5 {
                dMin = "\(minutes) minuty"
            } else if minutes >= 5 || minutes == 0 {
                dMin = "\(minutes) minut"
            }
            
            travelDuration = "\(hDur) \(dMin)"
        } else {
            travelDuration = "Bohužel se vyskytla chyba"
        }
    }
    
    /// Adds delay to the given time
    func addDelayToTime(time: String, delay: Int) -> String? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        
        if let date = dateFormatter.date(from: time) {
            let delayedDate = Calendar.current.date(byAdding: .minute, value: delay, to: date)
            return dateFormatter.string(from: delayedDate!)
        } else {
            return nil
        }
    }
    func calculateTravelDuration(startTime: String) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        
        guard let startDate = dateFormatter.date(from: startTime),
              let endDate = dateFormatter.date(from: calculatedTime) else {
            travelDuration = "N/A"
            return
        }
        
        let components = Calendar.current.dateComponents([.hour, .minute], from: startDate, to: endDate)
        if let hours = components.hour, let minutes = components.minute {
            
            var hDur = ""
            if hours == 1 {
                hDur = "\(hours) hodina"
            } else if hours > 1 && hours < 5 {
                hDur = "\(hours) hodiny"
            } else if hours >= 5 {
                hDur = "\(hours) hodin"
            }
            
            var dMin = ""
            if minutes == 1 {
                dMin = "\(minutes) minuta"
            } else if minutes > 1 && minutes < 5 {
                dMin = "\(minutes) minuty"
            } else if minutes >= 5 || minutes == 0 {
                dMin = "\(minutes) minut"
            }
        } else {
            travelDuration = "Bohužel se vyskytla chyba"
        }
    }
    
    
    
    private func requestNotificationPermission(h: Int, m: Int) {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if granted {
                NotificationScheduler.scheduleNotification(
                    title: "\(app.startPlace) - \(app.goalPlace)",
                    subtitle: "Blíží se čas odjezdu. Měli byste vyrazit!",
                    body: "This is your notification scheduled for 17:07.",
                    hour: h,
                    minute: m
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
    let estimatedTime: String
    let travelDuration: String
    
    @State private var isAnimating = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            
            HStack{
                ZStack {
                    Circle()
                        .strokeBorder(Color.green.opacity(0.6), lineWidth: 2)
                        .frame(width: 20, height: 20)
                    
                    Circle()
                        .fill(Color.green)
                        .frame(width: 12, height: 12)
                        .scaleEffect(isAnimating ? 1.25 : 1.0)
                        .opacity(isAnimating ? 0.6 : 1.0)
                        .animation(
                            Animation.easeInOut(duration: 1.5)
                                .repeatForever(autoreverses: true),
                            value: isAnimating
                        )
                }
                .onAppear {
                    isAnimating = true
                }.onDisappear{
                    isAnimating = false
                }
                
                Text("\(startPlace) - \(goalPlace)")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundStyle(.secondary)
            }
            .padding([.leading, .top])
            
            Text("Předpokládaný čas příjezdu: \(estimatedTime)\nCelková doba cesty: \(travelDuration)")
                .font(.headline)
                .padding(.leading)
            
        }
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
