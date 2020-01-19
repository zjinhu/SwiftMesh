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
    case noReachable
    case unKnown
    case onWiFi
    case onCellular
}

public class MeshManager{
    //单例
    public static let shared = MeshManager()
    
    public typealias NetworkStatusListener = (_ status: NetworkStatus) -> Void
    public typealias RequestConfig = (_ config: MeshConfig) -> Void
    public typealias RequestSuccess = (_ config: MeshConfig) -> Void
    public typealias RequestFailure = (_ config: MeshConfig) -> Void
    public typealias ProgressListener = (_ progress: Progress) -> Void 
    
    public var canLogging = false
    
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
    public var isReachableCellular: Bool {
        get {
            return self.networkManager.isReachableOnCellular
        }
    }
    
    // MARK: 统一发起请求(回调配置) 支持 GET POST PUT DELETE
    public func requestWithConfig(configBlock: RequestConfig?, success: RequestSuccess?, failure: RequestFailure?){
        let config = MeshConfig.init()
        if configBlock != nil {
            configBlock!(config)
            print(config)
        }
        self.sendRequest(config: config, success: success, failure: failure)
    }
    
    // MARK: 发起请求(需要配置) 支持GET POST PUT DELETE
    public func sendRequest(config: MeshConfig!, success: RequestSuccess?, failure: RequestFailure?) {
        ///设置默认参数 header
        self.changeConfig(config)
        ///先判断网络状态
        if self.isReachable {
            AF.request(config.URLString ?? "", method: config.requestMethod, parameters: config.parameters, encoding: config.requestEncoding, headers: config.addHeads).responseJSON { (response) in
                
                guard let json = response.data else {
                    config.code = RequestCode.errorResponse.rawValue
                    failure!(config)
                    return
                }
                ///打印输出
                self.meshLog(config, response: response)
                ///配置信息赋值用于解析
                config.responseData = json
                
                switch response.result {
                case .success:
                    //可添加统一解析
                    config.code = RequestCode.success.rawValue
                    if success != nil {
                        success!(config)
                    }
                case .failure:
                    config.code = RequestCode.errorResult.rawValue
                    if failure != nil {
                        failure!(config)
                    }
                }
            }
        } else {
            config.code = RequestCode.errorRequest.rawValue
            if failure != nil {
                failure!(config)
            }
        }
        
    }
    // MARK: 统一下载 需要配置更改配置参数
    public func downLoadWithConfig(configBlock: RequestConfig?, progress: ProgressListener?, success: RequestSuccess?, failure: RequestFailure?) {
        
        let config = MeshConfig.init()
        if configBlock != nil {
            configBlock!(config)
            print(config)
        }
        
        self.changeConfig(config)
        
        switch config.downloadType {
        case .resume:
            self.sendDownloadResume(config: config, progress: progress, success: success, failure: failure)
        default:
            self.sendDownload(config: config, progress: progress, success: success, failure: failure)
        }
        
    }
    // MARK: 下载文件
    public func sendDownload(config: MeshConfig!, progress: ProgressListener?, success: RequestSuccess?, failure: RequestFailure?) {
        AF.download(config.URLString ?? "", method: config.requestMethod, parameters: config.parameters, encoding: config.requestEncoding, headers: config.addHeads, to: config.destination).downloadProgress(closure: { (progr) in
            if progress != nil{
                progress!(progr)
            }
        }).responseData { (responseData) in
            
            config.fileURL = responseData.fileURL
            config.resumeData = responseData.resumeData
            
            switch responseData.result {
            case .success:
                config.mssage = "下载完成"
                config.code = RequestCode.success.rawValue
                if success != nil {
                    success!(config)
                }
            case .failure:
                config.mssage = "下载失败"
                config.code = RequestCode.errorResult.rawValue
                if failure != nil {
                    failure!(config)
                }
            }
        }
    }
    // MARK: 下载文件续传
    public func sendDownloadResume(config: MeshConfig!, progress: ProgressListener?, success: RequestSuccess?, failure: RequestFailure?) {
        AF.download(resumingWith: config.resumeData!, to: config.destination).downloadProgress(closure: { (progr) in
            if progress != nil{
                progress!(progr)
            }
        }).responseData { (responseData) in
            
            config.fileURL = responseData.fileURL
            config.resumeData = responseData.resumeData
            
            switch responseData.result {
            case .success:
                config.mssage = "下载完成"
                config.code = RequestCode.success.rawValue
                if success != nil {
                    success!(config)
                }
            case .failure:
                config.mssage = "下载失败"
                config.code = RequestCode.errorResult.rawValue
                if failure != nil {
                    failure!(config)
                }
            }
            
        }
        
    }
    // MARK: 统一上传方法
    public func uploadWithConfig(configBlock: RequestConfig?, progress: ProgressListener?, success: RequestSuccess?, failure: RequestFailure?) {
        
        let config = MeshConfig.init()
        if configBlock != nil {
            configBlock!(config)
            print(config)
        }
        
        self.changeConfig(config)
        
        switch config.uploadType {
        case .multipart:
            self.sendUploadMultipart(config: config, progress: progress, success: success, failure: failure)
        default:
            self.sendUpload(config: config, progress: progress, success: success, failure: failure)
        }
    }
    // MARK: 简单上传文件方法
    public func sendUpload(config: MeshConfig!, progress: ProgressListener?, success: RequestSuccess?, failure: RequestFailure?) {
        
        let uploadRequest : UploadRequest
        
        switch config.uploadType {
        case .file:
            uploadRequest = AF.upload(config.fileURL!, to: config.URLString!, method: config.requestMethod, headers: config.addHeads)
            
        case .stream:
            uploadRequest = AF.upload(config.stream!, to: config.URLString!, method: config.requestMethod, headers: config.addHeads)
            
        default:
            uploadRequest = AF.upload(config.fileData!, to: config.URLString!, method: config.requestMethod, headers: config.addHeads)
            
        }
        
        uploadRequest.uploadProgress { (progr) in
            if progress != nil{
                progress!(progr)
            }
        }
        
        uploadRequest.responseJSON { (response) in
            switch response.result {
            case .success:
                config.code = RequestCode.success.rawValue
                config.mssage = "上传成功"
                if success != nil {
                    success!(config)
                }
            case .failure:
                config.code = RequestCode.errorResult.rawValue
                config.mssage = "上传失败"
                if failure != nil {
                    failure!(config)
                }
            }
        }
        
    }
    // MARK: 表单上传
    public func sendUploadMultipart(config: MeshConfig!, progress: ProgressListener?, success: RequestSuccess?, failure: RequestFailure?) {
        AF.upload(multipartFormData: { (multi) in
            for  updataConfig in config.uploadDatas!{
                if updataConfig.fileData != nil {
                    ///Data数据表单,图片等类型
                    if updataConfig.fileName != nil && updataConfig.mimeType != nil {
                        multi.append(updataConfig.fileData!, withName: updataConfig.name!, fileName: updataConfig.fileName!, mimeType: updataConfig.mimeType!)
                    }else{
                        multi.append(updataConfig.fileData!, withName: updataConfig.name!)
                    }
                }else if updataConfig.fileURL != nil{
                    ///文件类型表单,从 URL 路径获取文件上传
                    if updataConfig.fileName != nil && updataConfig.mimeType != nil {
                        multi.append(updataConfig.fileURL!, withName: updataConfig.name!, fileName: updataConfig.fileName!, mimeType: updataConfig.mimeType!)
                    }else{
                        multi.append(updataConfig.fileURL!, withName: updataConfig.name!)
                    }
                }
            }
            
        }, to: config.URLString!, method: config.requestMethod, headers: config.addHeads).response { (response) in
            
            switch response.result{
            case .success( _):
                config.code = RequestCode.success.rawValue
                config.mssage = "上传成功"
                if success != nil {
                    success!(config)
                }
                print("****:\(response) ****")
            case .failure(let error):
                config.code = RequestCode.errorResult.rawValue
                config.mssage = "上传失败"
                if failure != nil {
                    failure!(config)
                }
                print(error)
            }

        }
    }
    
    /// 取消特定请求
    /// - Parameter url: 请求的地址,内部判断是否包含,请添加详细的 path
    public func cancelRequest(_ url :String){
        Session.default.session.getAllTasks { (tasks) in
            tasks.forEach { (task) in
                if (task.currentRequest?.url?.absoluteString.contains(url))!{
                    task.cancel()
                }
            }
        }
    }
    
    /// 清空所有请求
    public func cancelAllRequest(){
        Session.default.session.getAllTasks { (tasks) in
            tasks.forEach { (task) in
                task.cancel()
            }
        }
    }
    
    ///私有方法
    private func changeConfig(_ config: MeshConfig!){
        ///设置默认参数 header
        var param = self.defaultParameters ?? [:]
        param.merge(config.parameters ?? [:]) { (_, new) in new}
        config.parameters = param

        guard let headers = self.globalHeaders else {
            return
        }
        headers.forEach {
            config.addHeads?.update($0)
        }
    }
    // MARK: 网络监视
    var isStartNetworkMonitoring = false
    let networkManager = NetworkReachabilityManager(host: "www.baidu.com")!
    
    func startNetworkMonitoring(listener: NetworkStatusListener? = nil) {

        networkManager.startListening { (status) in
            self.isStartNetworkMonitoring = true
            var netStatus = NetworkStatus.noReachable
            switch status{
            case .notReachable:
                netStatus = .noReachable
            case .unknown:
                netStatus = .unKnown
            case .reachable(.ethernetOrWiFi):
                netStatus = .onWiFi
            case .reachable(.cellular):
                netStatus = .onCellular
            }
            if listener != nil {
                listener!(netStatus)
            }
        }
    }
    // MARK:- 打印输出
    private func meshLog(_ config: MeshConfig, response: AFDataResponse<Any>?) {
        #if DEBUG
        
        if self.canLogging{
            print("\n\n<><><><><>-「Alamofire Log」-<><><><><>\n\n>>>>>>>>>>>>>>>API:>>>>>>>>>>>>>>>\n\n\(String(describing: config.URLString))\n\n>>>>>>>>>>>>>>>parameters:>>>>>>>>>>>>>>>\n\n\(String(describing: config.parameters))\n\n>>>>>>>>>>>>>>>headers:>>>>>>>>>>>>>>>\n\n\(String(describing: config.addHeads))\n\n>>>>>>>>>>>>>>>response:>>>>>>>>>>>>>>>\n\n\(String(describing: response))\n\n<><><><><>-「Alamofire END」-<><><><><>\n\n")
        }
        
        #endif
    }
}
