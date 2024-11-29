
import Foundation
import Combine

class AppData: ObservableObject, Codable {
    @Published var test: Int = 0
    @Published var startPlace: String = ""
    @Published var goalPlace: String = ""
    @Published var dTime: Date = Date()
    @Published var goalLatitude: Double = 0.0
    @Published var goalLongitude: Double = 0.0
    @Published var startLatitude: Double = 0.0
    @Published var startLongitude: Double = 0.0
    @Published var startClosestLatitude: Double = 0.0
    @Published var startClosestLongitude: Double = 0.0
    @Published var startClosestName: String = ""
    @Published var startClosestID: String = ""
    @Published var goalClosestLatitude: Double = 0.0
    @Published var goalClosestLongitude: Double = 0.0
    @Published var goalClosestName: String = ""
    @Published var goalClosestID: String = ""
    @Published var routes: [Route] = []
    @Published var activeSlide: Int = 0

    enum CodingKeys: String, CodingKey {
        case test, startPlace, goalPlace, dTime, goalLatitude, goalLongitude, startLatitude, startLongitude,
             startClosestLatitude, startClosestLongitude, startClosestName, startClosestID,
             goalClosestLatitude, goalClosestLongitude, goalClosestName, goalClosestID,
             routes, activeSlide
    }

    // Default initializer
    init() {}

    // Decodable initializer
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.test = try container.decode(Int.self, forKey: .test)
        self.startPlace = try container.decode(String.self, forKey: .startPlace)
        self.goalPlace = try container.decode(String.self, forKey: .goalPlace)
        self.dTime = try container.decode(Date.self, forKey: .dTime)
        self.goalLatitude = try container.decode(Double.self, forKey: .goalLatitude)
        self.goalLongitude = try container.decode(Double.self, forKey: .goalLongitude)
        self.startLatitude = try container.decode(Double.self, forKey: .startLatitude)
        self.startLongitude = try container.decode(Double.self, forKey: .startLongitude)
        self.startClosestLatitude = try container.decode(Double.self, forKey: .startClosestLatitude)
        self.startClosestLongitude = try container.decode(Double.self, forKey: .startClosestLongitude)
        self.startClosestName = try container.decode(String.self, forKey: .startClosestName)
        self.startClosestID = try container.decode(String.self, forKey: .startClosestID)
        self.goalClosestLatitude = try container.decode(Double.self, forKey: .goalClosestLatitude)
        self.goalClosestLongitude = try container.decode(Double.self, forKey: .goalClosestLongitude)
        self.goalClosestName = try container.decode(String.self, forKey: .goalClosestName)
        self.goalClosestID = try container.decode(String.self, forKey: .goalClosestID)
        self.routes = try container.decode([Route].self, forKey: .routes)
        self.activeSlide = try container.decode(Int.self, forKey: .activeSlide)
    }

    // Encodable
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(test, forKey: .test)
        try container.encode(startPlace, forKey: .startPlace)
        try container.encode(goalPlace, forKey: .goalPlace)
        try container.encode(dTime, forKey: .dTime)
        try container.encode(goalLatitude, forKey: .goalLatitude)
        try container.encode(goalLongitude, forKey: .goalLongitude)
        try container.encode(startLatitude, forKey: .startLatitude)
        try container.encode(startLongitude, forKey: .startLongitude)
        try container.encode(startClosestLatitude, forKey: .startClosestLatitude)
        try container.encode(startClosestLongitude, forKey: .startClosestLongitude)
        try container.encode(startClosestName, forKey: .startClosestName)
        try container.encode(startClosestID, forKey: .startClosestID)
        try container.encode(goalClosestLatitude, forKey: .goalClosestLatitude)
        try container.encode(goalClosestLongitude, forKey: .goalClosestLongitude)
        try container.encode(goalClosestName, forKey: .goalClosestName)
        try container.encode(goalClosestID, forKey: .goalClosestID)
        try container.encode(routes, forKey: .routes)
        try container.encode(activeSlide, forKey: .activeSlide)
    }

    func resetSearchData() {
        startPlace = ""
        goalPlace = ""
        dTime = Date()
        goalLatitude = 0.0
        goalLongitude = 0.0
        startLatitude = 0.0
        startLongitude = 0.0
        startClosestLatitude = 0.0
        startClosestLongitude = 0.0
        startClosestName = ""
        startClosestID = ""
        goalClosestLatitude = 0.0
        goalClosestLongitude = 0.0
        goalClosestName = ""
        goalClosestID = ""
        routes = []
    }
}
