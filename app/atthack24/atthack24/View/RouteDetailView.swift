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
                            
                            if index == routes.count - 1 {
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
                    }
                    .padding()
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
        LazyHStack(spacing: 10) {
            if delay == 5 {
                Image(systemName: "goforward.5")
            } else if delay == 10 {
                Image(systemName: "goforward.10")
            } else if delay == 15 {
                Image(systemName: "goforward.15")
            } else if delay == 30 {
                Image(systemName: "goforward.30")
            } else {
                Image(systemName: "timer")
            }

            Text(delay > 5 ? "Aktuální zpoždění \(delay) minut" : "Aktuálně zpoždění \(delay) minuty")
                .fontWeight(.bold)
        }
        .foregroundStyle(isDelayed ? .red : .green)
    }
}

struct RouteDetailItem: View {
    let time: String
    let station: String
    let type: Int

    var body: some View {
        HStack(alignment: .center, spacing: 10) {
            if type == 1{
                Image(systemName: "mappin.and.ellipse")
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

#Preview {
    RouteDetailView(
        routes: .constant([
            Route(
                delay: 5,
                routeName: "Tram 10",
                time1: "10:00",
                time2: "10:10",
                station1: "Vozovna Komín",
                station2: "Brno - Hlavní nádraží"
            ),
            Route(
                delay: 3,
                routeName: "Tram 9",
                time1: "10:12",
                time2: "10:20",
                station1: "Brno - Hlavní nádraží",
                station2: "Brno - Centrum"
            )
        ])
    )
    .environmentObject(AppData())
}
