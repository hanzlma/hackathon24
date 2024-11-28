//
//  Route.swift
//  atthack24
//
//  Created by Tom on 28.11.2024.
//

import Foundation

struct Route: Identifiable, Hashable {
    let id = UUID()
    var delay: Int
    var routeName: String
    var time1: String
    var time2: String
    var station1: String
    var station2: String
}
