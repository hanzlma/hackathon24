
import Foundation
import Combine

class AppData: ObservableObject {
    @Published var test: Int = 0
    @Published var startPlace: String = ""
    @Published var goalPlace: String = ""
    @Published var dTime: Date = Date()
    
    @Published var  goalLatitude: Double = 0.0
    @Published var  goalLongitude: Double = 0.0
    
    @Published var  startLatitude: Double = 0.0
    @Published var  startLongitude: Double = 0.0
    
    @Published var  startClosestLatitude: Double = 0.0
    @Published var  startClosestLongitude: Double = 0.0
    @Published var  startClosestName: String = ""
    @Published var  startClosestID: String = ""
    
    @Published var  goalClosestLatitude: Double = 0.0
    @Published var  goalClosestLongitude: Double = 0.0
    @Published var  goalClosestName: String = ""
    @Published var  goalClosestID: String = ""
    
    
    @Published var  routes: [Route] = []
    
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
    
    
    //
    @Published var  activeSlide: Int = 0
}
