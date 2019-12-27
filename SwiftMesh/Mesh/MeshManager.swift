//
//  MeshManager.swift
//  SwiftMesh
//
//  Created by iOS on 2019/12/26.
//  Copyright © 2019 iOS. All rights reserved.
//
import Foundation
import Alamofire

public enum NetworkStatus {
    case notReachable
    case unknown
    case ethernetOrWiFi
    case wwan
}

open class MeshManager{
    //单例
    public static let shared = MeshManager()
    
    // MARK: 回调 Block
    public typealias RequestConfig = (_ config: MeshConfig) -> Void
    
    public typealias RequestSuccess = (_ data: Data) -> Void
    public typealias RequestFailure = (_ config: MeshConfig) -> Void
    public typealias NetworkStatusListener = (_ status: NetworkStatus) -> Void
    
    private var globalHeaders: HTTPHeaders?
    private var defaultParameters: [String: Any]?
    
    // MARK: 设置全局 headers
    public func setGlobalHeaders(_ headers: HTTPHeaders?) {
        self.globalHeaders = headers
    }
    
    // MARK: 设置默认参数
    public func setDefaultParameters(_ parameters: [String: Any]?) {
        self.defaultParameters = parameters
    }
    
    var isStartNetworkMonitoring = false
    let networkManager = NetworkReachabilityManager(host: "www.baidu.com")!
    // MARK: 网络监视
    func startNetworkMonitoring(listener: NetworkStatusListener? = nil) {
        self.networkManager.listener = { status in
            self.isStartNetworkMonitoring = true
            var netStatus = NetworkStatus.notReachable
            switch status {
            case .notReachable:
                netStatus = NetworkStatus.notReachable
            case .unknown:
                netStatus = NetworkStatus.unknown
            case .reachable(.ethernetOrWiFi):
                netStatus = NetworkStatus.ethernetOrWiFi
            case .reachable(.wwan):
                netStatus = NetworkStatus.wwan
            }
            if listener != nil {
                listener!(netStatus)
            }
        }
        self.networkManager.startListening()
    }
    // MARK: 是否联网
    public var isReachable: Bool {
        get {
            return self.isStartNetworkMonitoring ? self.networkManager.isReachable : true
        }
    }
    // MARK: 是否WiFi
    public var isReachableWiFi: Bool {
        get {
            return self.networkManager.isReachableOnEthernetOrWiFi
        }
    }
    // MARK: 是否WWAN
    public var isReachableWWAN: Bool {
        get {
            return self.networkManager.isReachableOnWWAN
        }
    }
    
    
    func requestWithConfig(configBlock: RequestConfig?, success: RequestSuccess?, failure: RequestFailure?){
        let config = MeshConfig.init()
        if configBlock != nil {
            configBlock!(config)
            print(config)
        }
        self.sendRequest(config: config, success: success, failure: failure)
        
    }
    func sendRequest(config: MeshConfig!, success: RequestSuccess?, failure: RequestFailure?) {
        var param = self.defaultParameters ?? [:]
        param.merge(config.parameters ?? [:]) { (_, new) in new}
        config.parameters = param
        
        var header = self.globalHeaders ?? [:]
        header.merge(config.addHeads ?? [:]) { (_, new) in new}
        config.addHeads = header

        self.request(config: config, success: success, failure: failure)
    }
    
    // MARK: 统一请求
    private func request (config: MeshConfig!, success: RequestSuccess?, failure: RequestFailure?, encoding: ParameterEncoding = URLEncoding.default) {
        
        if self.isReachable {
            
            Alamofire.request(config.URLString ?? "", method: config.requestType, parameters: config.parameters, encoding: encoding, headers: config.addHeads).responseJSON { (response) in
                
                guard let json = response.data else {
                    failure!(config)
                    return
                }
                
                switch response.result {
                case .success:
                    //可添加统一解析
                    print((response.request!.url?.absoluteString)! + "\t******\tresponse:\r\(response)")
                    if success != nil {
                        success!(json)
                    }
                case .failure:
                    if failure != nil {
                        failure!(config)
                    }
                }
            }
        } else {
            if failure != nil {
                failure!(config)
            }
        }
    }
    
    public func decoderJson<T : Decodable>(_ type:[T].Type ,_ data:Data) throws -> T {
        let decoder = JSONDecoder()
        let model = try! decoder.decode(type, from: data)
        return model as! T
    }
}
