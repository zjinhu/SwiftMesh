//
//  MeshRequest.swift
//  SwiftMesh
//
//  Created by iOS on 2019/12/27.
//  Copyright © 2019 iOS. All rights reserved.
//
import Foundation
import Alamofire

/// 泛型封装普通请求,支持解析后直接返回泛型model
public class MeshRequest <T: Codable> {
    
    public typealias requestCallBack = (_ data: T?) -> Void
    
    /// get请求
    /// - Parameters:
    ///   - url: 请求地址
    ///   - parameters: 请求参数
    ///   - callBack: 返回闭包
    public class func get(_ url: String, parameters: [String: Any] = [:], callBack: requestCallBack?) {
        self.request(url, parameters: parameters, callBack: callBack)
    }
    /// post请求
    /// - Parameters:
    ///   - url: 请求地址
    ///   - parameters: 请求参数
    ///   - callBack: 返回闭包
    public class func post(_ url: String, parameters: [String: Any] = [:], callBack: requestCallBack?) {
        self.request(url, requestMethod: .post, parameters: parameters, callBack: callBack)
    }
    
    class private func request(_ url: String, requestMethod : HTTPMethod = .get , parameters: [String: Any] = [:], callBack: requestCallBack?) {
        
        MeshManager.shared.requestWithConfig(configBlock: { (config) in
            config.requestMethod = requestMethod
            config.URLString = url
            config.parameters = parameters
        }, success: { (config) in
            
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            guard let data = config.responseData, let model = try? decoder.decode(T.self, from: data) else {
                callBack?(nil)
                return
            }
            
            callBack?(model)
            
        }) { (config) in
            callBack?(nil)
        }
        
    }
    
    
}
