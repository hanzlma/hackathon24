//
//  RouteGroupView.swift
//  atthack24
//
//  Created by Tom on 28.11.2024.
//


import SwiftUI

struct RouteGroupView: View {
    @Binding var routes: [Route]
    
    var body: some View {
        LazyVStack(alignment: .leading) {
            ForEach(routes.indices, id: \.self) { index in
                let route = routes[index]
                RouteItem(
                    delay: .constant(route.delay),
                    routeName: .constant(route.routeName),
                    time1: .constant(route.time1),
                    time2: .constant(route.time2),
                    station1: .constant(route.station1),
                    station2: .constant(route.station2)
                )
            }
        }
    }
}


