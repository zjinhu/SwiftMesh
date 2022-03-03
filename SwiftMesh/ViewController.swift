//
//  ViewController.swift
//  SwiftMesh
//
//  Created by iOS on 2019/12/26.
//  Copyright © 2019 iOS. All rights reserved.
//

import UIKit
struct BaseModel: Codable {
    let body: String
    let title: String
    let userId: Int
}

struct TestModel: Codable {
    let code: Int 
    let message: String
    let result: [Item]
}
struct Item: Codable {
    let text: String
    let video: String
}

struct ResultModel: Codable {
    let city: String
    let citykey: String
    let parent: String
    let updateTime: String
}

class ViewController: UIViewController {

    
    func setHeader() {
        Mesh.canLogging = true
        Mesh.setGlobalHeaders(["aaa":"bbb"])
        Mesh.setDefaultParameters(["String" : "Any","a":"1","b":"2"])
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setHeader()
        // Do any additional setup after loading the view.
        Mesh.disableHttpsProxy()

        MeshRequest.get("https://jsonplaceholder.typicode.com/posts", modelType: [BaseModel].self) { (model) in
            print("\(String(describing: model))")
        }
        
        let a = MeshRequest.get("http://t.weather.itboy.net/api/weather/city/101030100", modelType: ResultModel.self, modelKeyPath: "cityInfo") { (model) in
            print("22222\(String(describing: model))")
        }
        a?.cancel()
        
        Mesh.requestWithConfig { (config) in
            config.URLString = "https://timor.tech/api/holiday/year/2022/"
            config.requestMethod = .get
        } success: { (config) in

            guard let data = config.response?.data else {
                return
            }
            
            let dic = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String : Any]
            print("\(String(describing: dic?["holiday"]))")

        } failure: { (_) in
            print("error getHoliday")
        }

    }

    func get(dd: Double, ss: String){
        print("\(dd),\(ss)")
    }
}

