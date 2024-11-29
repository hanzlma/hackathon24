import SwiftUI

struct RouteDetailView: View {
    @Binding var routes: [Route]
    @EnvironmentObject var app: AppData
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                
                Text("\(app.startPlace) - \(app.goalPlace)")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundStyle(.secondary)
                
                ForEach(routes.indices, id: \.self) { index in
                    let route = routes[index]
                    VStack(alignment: .leading, spacing: 10) {
                        
                        if route.routeName == "C" {
                            HStack{
                                Image(systemName: "tram")
                                Text(route.routeName)
                                    .font(.headline)
                                    .fontWeight(.bold)
                                    
                            }.foregroundStyle(Color.red)
                        }
                        else if route.routeName == "B" {
                            HStack{
                                Image(systemName: "tram")
                                Text(route.routeName)
                                    .font(.headline)
                                    .fontWeight(.bold)
                                    
                            }.foregroundStyle(Color.yellow)
                        }
                        else if route.routeName == "A" {
                            HStack{
                                Image(systemName: "tram")
                                Text(route.routeName)
                                    .font(.headline)
                                    .fontWeight(.bold)
                                    
                            }.foregroundStyle(Color.green)
                        }else{
                            
                            Text(route.routeName)
                                .font(.headline)
                                .fontWeight(.bold)
                                .foregroundStyle(Color.primaryColor)
                            
                        }
                        VStack(alignment: .leading, spacing: 10) {
                            if index == 0 {
                                
                                RouteDetailItem(time: route.time1, station: route.station1, type: 1)
                            } else {
                                RouteDetailItem(time: route.time1, station: route.station1, type: 2)
                                
                            }
                            
                            if index == routes.count - 1 {
                                RouteDetailItem(time: route.time2, station: route.station2, type: 3)
                            } else {
                                RouteDetailItem(time: route.time2, station: route.station2, type: 2)
                            }
                        }
                        
                        if route.delay > 1 {
                            DelayView(delay: route.delay, isDelayed: route.delay > 3)
                        }
                        
                        if index != app.routes.count - 1 {
                            Divider()
                        }
                        
                    }
                    .padding([.leading, .trailing])
                }
                
                
                RoundedButton(
                    text: "Spustit trasu",
                    image: Image(systemName: "arrowtriangle.down.circle.fill"),
                    setMaxWidth: true
                ) {
                    print("Trasa zahájena")
                    
                    app.routes = routes
                    
                    
                    
                    app.activeSlide = 1
                }
                .padding(.top)
            }
            .padding()
        }
        
    }
}

struct DelayView: View {
    let delay: Int
    let isDelayed: Bool
    
    var body: some View {
        if delay > 1 {
            LazyHStack(spacing: 10) {
                if delay == 5 {
                    Image(systemName: "goforward.5").resizable().frame(width: 23, height: 25)
                } else if delay == 10 {
                    Image(systemName: "goforward.10")
                        .resizable().frame(width: 23, height: 25)
                } else if delay == 15 {
                    Image(systemName: "goforward.15")
                        .resizable().frame(width: 23, height: 25)
                } else if delay == 30 {
                    Image(systemName: "goforward.30")
                        .resizable().frame(width: 23, height: 25)
                } else {
                    Image(systemName: "timer")
                        .resizable().frame(width: 23, height: 25)
                }
                
                Text(delay > 4 ? "Aktuální zpoždění \(delay) minut" : "Aktuálně zpoždění \(delay) minuty")
                    .fontWeight(.bold)
                
            }
            .foregroundStyle(isDelayed ? .red : .green)
        }
    }
}

struct RouteDetailItem: View {
    let time: String
    let station: String
    let type: Int
    
    var body: some View {
        HStack(alignment: .center, spacing: 10) {
            if type == 1{
                Image(systemName: "location.fill")
                    .frame(width: 20)
            }
            if type == 2{
                Image(systemName: "circle.fill")
                    .resizable()
                    .frame(width: 10, height: 10).padding(.leading, 5)
                    .padding(.trailing, 5)
                    .foregroundStyle(.gray.opacity(0.3))
            }
            if type == 3{
                Image(systemName: "house.fill")
                    .frame(width: 20)
            }
            
            VStack(alignment: .leading, spacing: 5) {
                Text(time).bold()
                Text(station).foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 5)
    }
}

