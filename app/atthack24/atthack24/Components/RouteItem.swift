//
//  RouteItem.swift
//  atthack24
//
//  Created by Tom on 28.11.2024.
//

import SwiftUI

struct RouteItem: View {
    @Binding var delay: Int
    @Binding var routeName: String
    @Binding var time1: String
    @Binding var time2: String
    @Binding var station1: String
    @Binding var station2: String
    
    var isDelayed: Bool {
        delay > 3
    }
    
    var body: some View {
        LazyVStack(alignment: .leading) {
            Text(routeName).font(.headline).foregroundStyle(Color.primaryColor)
            LazyVStack(alignment: .leading) {
                HStack {
                    Text(time1).bold()
                    Text(station1)
                }
                HStack {
                    Text(time2).bold()
                    Text(station2)
                }
                if delay > 1 {
                    LazyHStack{
                        
                        if delay == 5{
                            Image(systemName: "goforward.5")
                        }
                        else if delay == 10{
                            Image(systemName: "goforward.10")
                        }
                        else if delay == 15{
                            Image(systemName: "goforward.15")
                        }
                        else if delay == 30{
                            Image(systemName: "goforward.30")
                        }
                        else {
                            Image(systemName: "timer")
                        }
                        
                        
                        Text(delay > 4 ? "Aktuální zpoždění \(delay) minut" : "Aktuálně zpoždění \(delay) minuty")
                    }.foregroundStyle(isDelayed ? .red : .green).bold()
                }
            }.padding(.leading)
        }
        
    }
}

#Preview {
    RouteItem(
        delay: .constant(4),
        routeName: .constant("Tram 10"),
        time1: .constant("10:00"),
        time2: .constant("10:10"),
        station1: .constant("Vozovna Komín"),
        station2: .constant("Brno - Hlavní nádraží")
    )
}
