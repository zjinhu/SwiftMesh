//
//  Request.swift
//  SwiftMesh
//
//  Created by iOS on 2023/4/18.
//

import Foundation
import SwiftMesh
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
    @ConvertToString
    var aqi: String?

    var notice: String?
    @Default.EmptyString
    var date: String
}

@MainActor
class RequestModel: ObservableObject {
    @Published var yesterday: Forecast?
//    @Published var cityResult: CityResult?
    
    func getResult() async {
        
        do {
            //全部解析
            //let data = try await Mesh.shared.request(of: CityResult.self, configClosure: { config in
            //   config.URLString = "http://t.weather.itboy.net/api/weather/city/101030100"
            //})
            //只解析需要的部分
            yesterday = try await Mesh.shared.request(of: Forecast.self,
                                                     modelKeyPath: "data.yesterday",
                                                     configClosure: { config in
                config.URLString = "http://t.weather.itboy.net/api/weather/city/101030100"
            })
 
        } catch let error {
            print(error.localizedDescription)
        }

    }
}
