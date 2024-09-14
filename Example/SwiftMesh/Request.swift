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
    
    @IgnoreError
    var aqi: String? //本身为Int类型,添加忽略错误,保证其他解析成功
    
    var notice: String?
    
    @IgnoreError
    var date: Int?
    
}


@MainActor
class RequestModel: ObservableObject {
    @Published var yesterday: Forecast?
    //    @Published var cityResult: CityResult?
    
    @Published var downloadUrl: URL?
    
    func getResult() async {
        
        do {
            //全部解析
            //let data = try await Mesh.shared.request(of: CityResult.self, configClosure: { config in
            //   config.URLString = "http://t.weather.itboy.net/api/weather/city/101030100"
            //})
            //只解析需要的部分
            
            yesterday =
            try await Mesh()
                .setRequestMethod(.get)
                .setUrlHost("http://t.weather.itboy.net/api/")
                .setUrlPath("weather/city/101030100")
                .request(of: Forecast.self, modelKeyPath: "data.yesterday")
                
            
        } catch let error {
            print(error.localizedDescription)
        }
        
    }
    
    func download() async{
        
        do {
            downloadUrl = 
            try await Mesh()
                .setUrlHost("http://clips.vorwaerts-gmbh.de/")
                .setUrlPath("big_buck_bunny.mp4")
                .download()
        } catch let error {
            print(error.localizedDescription)
        }
        
    }
}
