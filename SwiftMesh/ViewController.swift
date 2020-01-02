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

class ViewController: UIViewController {

    
    class func setHeader() {
//        MeshManager.shared.canLogging = true
        MeshManager.shared.setGlobalHeaders(["aaa":"bbb"])
        MeshManager.shared.setDefaultParameters(["String" : "Any","a":"1","b":"2"])
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        MeshManager.shared.canLogging = true
        // Do any additional setup after loading the view.

        MeshRequest<[BaseModel]>.get("https://jsonplaceholder.typicode.com/posts") { (model) in
            print(model!)
        }
        
        MeshRequest<TestModel>.get("https://api.apiopen.top/getJoke?page=1&count=2&type=video") { (model) in
            print(model!)
        }

        
    }


}

