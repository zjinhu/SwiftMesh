//
//  BaseRequest.swift
//  SwiftMesh
//
//  Created by iOS on 2019/12/27.
//  Copyright © 2019 iOS. All rights reserved.
//
import Foundation
import UIKit
import Alamofire
// MARK: 错误码
enum ServerCode : Int {
    case success = 0 //请求成功的状态吗
    case error = 99 //请求失败的状态吗
}

// MARK: 内部解析 model
struct BaseModel: Decodable {
    var code: Int
    var msg: String
    var data: Content
    struct Content: Decodable {
        
    }
    
    var serverCode: Int {
        return code
    }
    
    var serverMessage: String {
        return msg
    }
}

class BaseRequest : MeshManager{
    
    static func setHeader() {
        MeshManager.shared.setGlobalHeaders(["aaa":"bbb"])
        MeshManager.shared.setDefaultParameters(["String" : "Any","a":"1","b":"2"])
    }
    
    static func get(_ url: String, parameters: [String: Any] = [:], success: RequestSuccess?, failure: RequestFailure?) {
        
        MeshManager.shared.requestWithConfig(configBlock: { (config) in
            config.requestType = .get
            config.URLString = url
            config.parameters = parameters
        }, success: success, failure: failure)
        
    }
}
