//
//  AppData+Persistence.swift
//  atthack24
//
//  Created by Tom on 28.11.2024.
//

import Foundation

extension AppData {
    private var userDefaultsKey: String { "AppDataStorage" }
    
    func save() {
        let encoder = JSONEncoder()
        if let encodedData = try? encoder.encode(self) {
            UserDefaults.standard.set(encodedData, forKey: userDefaultsKey)
        } else {
            print("Error: Failed to encode AppData")
        }
    }
    
    func load() {
        guard let savedData = UserDefaults.standard.data(forKey: userDefaultsKey) else {
            print("No saved data found.")
            return
        }
        let decoder = JSONDecoder()
        if let decodedData = try? decoder.decode(AppData.self, from: savedData) {
            self.copyFrom(decodedData)
        } else {
            print("Error: Failed to decode AppData")
        }
    }
    
    private func copyFrom(_ other: AppData) {
        self.test = other.test
        self.startPlace = other.startPlace
        self.goalPlace = other.goalPlace
        self.dTime = other.dTime
        self.goalLatitude = other.goalLatitude
        self.goalLongitude = other.goalLongitude
        self.startLatitude = other.startLatitude
        self.startLongitude = other.startLongitude
        self.startClosestLatitude = other.startClosestLatitude
        self.startClosestLongitude = other.startClosestLongitude
        self.startClosestName = other.startClosestName
        self.startClosestID = other.startClosestID
        self.goalClosestLatitude = other.goalClosestLatitude
        self.goalClosestLongitude = other.goalClosestLongitude
        self.goalClosestName = other.goalClosestName
        self.goalClosestID = other.goalClosestID
        self.routes = other.routes
        self.activeSlide = other.activeSlide
    }
}
