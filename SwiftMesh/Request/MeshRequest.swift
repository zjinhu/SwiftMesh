//
//  MeshRequest.swift
//  SwiftMesh
//
//  Created by iOS on 2019/12/27.
//  Copyright © 2019 iOS. All rights reserved.
//
import Foundation
import Alamofire

open class MeshRequest <T: Codable> {
    public typealias requestCallBack = (_ data: T?) -> Void

    public class func get(_ url: String, parameters: [String: Any] = [:], callBack: requestCallBack?) {
        self.request(url, parameters: parameters, callBack: callBack)
    }
    
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
            guard let model = try? decoder.decode(T.self, from: config.responseData!) else {
                if callBack != nil {
                    callBack!(nil)
                }
                return
            }

            if callBack != nil {
                callBack!(model)
            }
            
        }) { (config) in
            if callBack != nil {
                callBack!(nil)
            }
        }
        
    }
    
    
}
