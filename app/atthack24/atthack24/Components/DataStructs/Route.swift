//
//  Route.swift
//  atthack24
//
//  Created by Tom on 28.11.2024.
//

import Foundation

struct Route: Codable {
    let delay: Int
    let routeName: String
    let time1: String
    let time2: String
    let station1: String
    let station2: String
    let startLatitude: Double
    let startLongitude: Double
    let endLatitude: Double
    let endLongitude: Double
}
