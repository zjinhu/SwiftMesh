//
//  Request.swift
//  SwiftMesh
//
//  Created by iOS on 2023/4/18.
//

import Foundation

struct CityResult: Codable {
    let message: String?
    let status: Int?
//    let date: String
//    let time: String
    let cityInfo: CityInfo?
}

struct CityInfo: Codable {
    let city: String?
    let citykey: String?
    let parent: String?
    let updateTime: String?
    let forecast: [Forecast]?
}

struct Forecast: Codable {
    let ymd: String?
    let week: String?
    let notice: String?
}

class RequestModel: ObservableObject {
    @MainActor @Published var cityResult: CityResult?
 
    func getAppliances() {
        Task{
            do {
     
                let data = try await Mesh.shared.request(of: CityResult.self, configClosure: { config in
                    config.URLString = "http://t.weather.itboy.net/api/weather/city/101030100"
                })
                
                await MainActor.run {
                    self.cityResult = data
                }
                
            } catch let error {
                print(error.localizedDescription)
            }
        }

    }
}
