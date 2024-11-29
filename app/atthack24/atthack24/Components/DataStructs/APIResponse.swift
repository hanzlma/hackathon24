//
//  APIResponse.swift
//  atthack24
//
//  Created by Tom on 28.11.2024.
//


struct APIResponse: Decodable {
    let cords: Cords
}

struct Cords: Decodable {
    let latitude: Double
    let longitude: Double
    
    enum CodingKeys: String, CodingKey {
        case lat, lng
        case latitude, longitude
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        if let latitude = try? container.decode(Double.self, forKey: .latitude),
           let longitude = try? container.decode(Double.self, forKey: .longitude) {
            self.latitude = latitude
            self.longitude = longitude
        } else {
            self.latitude = try container.decode(Double.self, forKey: .lat)
            self.longitude = try container.decode(Double.self, forKey: .lng)
        }
    }
}


struct ClosestResponse: Decodable {
    let id: String
    let name: String
    let cords: Cords
}
