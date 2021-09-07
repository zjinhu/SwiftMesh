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

    
    class func setHeader() {
//        MeshManager.shared.canLogging = true
//        MeshManager.shared.setGlobalHeaders(["aaa":"bbb"])
//        MeshManager.shared.setDefaultParameters(["String" : "Any","a":"1","b":"2"])
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        MeshManager.shared.canLogging = true
        // Do any additional setup after loading the view.
        MeshManager.shared.disableHttpsProxy()

        MeshRequest.get("https://jsonplaceholder.typicode.com/posts", modelType: [BaseModel].self) { (model) in
            print("\(String(describing: model))")
        }
        
        let a = MeshRequest.get("http://t.weather.itboy.net/api/weather/city/101030100", modelType: ResultModel.self, modelKeyPath: "cityInfo") { (model) in
            print("22222\(String(describing: model))")
        }
        a?.cancel()
        
        MeshManager.shared.requestWithConfig { (config) in
            config.URLString = "https://timor.tech/api/holiday/year/2021/"
            config.requestMethod = .get
        } success: { (config) in

            let dic : [String: Any] = config.response?.value as! [String : Any]
            print("\(dic["holiday"])")

        } failure: { (_) in
            print("error getHoliday")
        }

    }

    func get(dd: Double, ss: String){
        print("\(dd),\(ss)")
    }
}

