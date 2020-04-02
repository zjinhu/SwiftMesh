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
    private let networkManager = NetworkReachabilityManager()
    // MARK: 设置全局 headers
    public func setGlobalHeaders(_ headers: HTTPHeaders?) {
        globalHeaders = headers
    }
    
    // MARK: 设置默认参数
    public func setDefaultParameters(_ parameters: [String: Any]?) {
        defaultParameters = parameters
    }
    
    // MARK: 是否联网
    public var isReachable: Bool {
        get {
            return networkManager?.isReachable ?? false
        }
    }
    // MARK: 是否WiFi
    public var isReachableWiFi: Bool {
        get {
            return networkManager?.isReachableOnEthernetOrWiFi ?? false
        }
    }
    // MARK: 是否WWAN
    public var isReachableCellular: Bool {
        get {
            return networkManager?.isReachableOnCellular ?? false
        }
    }
    
    // MARK: 统一发起请求(回调配置) 支持 GET POST PUT DELETE
    public func requestWithConfig(configBlock: RequestConfig?, success: RequestSuccess?, failure: RequestFailure?){
        guard let block = configBlock else {
            return
        }
        let config = MeshConfig.init()
        block(config)
        
        sendRequest(config: config, success: success, failure: failure)
    }
    
    // MARK: 发起请求(需要配置) 支持GET POST PUT DELETE
    public func sendRequest(config: MeshConfig, success: RequestSuccess?, failure: RequestFailure?) {
        
        guard let url = config.URLString else {
            return
        }
        ///设置默认参数 header
        changeConfig(config)
        ///先判断网络状态
        if isReachable {
            AF.request(url, method: config.requestMethod, parameters: config.parameters, encoding: config.requestEncoding, headers: config.addHeads).responseJSON { (response) in
                
                guard let json = response.data else {
                    config.code = RequestCode.errorResponse.rawValue
                    failure?(config)
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
                    success?(config)
                case .failure:
                    config.code = RequestCode.errorResult.rawValue
                    failure?(config)
                }
            }
        } else {
            config.code = RequestCode.errorRequest.rawValue
            failure?(config)
        }
        
    }
    // MARK: 统一下载 需要配置更改配置参数
    public func downLoadWithConfig(configBlock: RequestConfig?, progress: ProgressListener?, success: RequestSuccess?, failure: RequestFailure?) {
        
        guard let block = configBlock else {
            return
        }
        let config = MeshConfig.init()
        block(config)
        
        changeConfig(config)
        
        switch config.downloadType {
        case .resume:
            sendDownloadResume(config: config, progress: progress, success: success, failure: failure)
        default:
            sendDownload(config: config, progress: progress, success: success, failure: failure)
        }
        
    }
    // MARK: 下载文件
    public func sendDownload(config: MeshConfig, progress: ProgressListener?, success: RequestSuccess?, failure: RequestFailure?) {
        
        guard let url = config.URLString else {
            return
        }

        AF.download(url, method: config.requestMethod, parameters: config.parameters, encoding: config.requestEncoding, headers: config.addHeads, to: config.destination).downloadProgress(closure: { (progr) in
            
            progress?(progr)
            
        }).responseData { (responseData) in
            
            config.fileURL = responseData.fileURL
            config.resumeData = responseData.resumeData
            
            switch responseData.result {
            case .success:
                config.mssage = "下载完成"
                config.code = RequestCode.success.rawValue
                success?(config)
            case .failure:
                config.mssage = "下载失败"
                config.code = RequestCode.errorResult.rawValue
                failure?(config)
            }
        }
    }
    // MARK: 下载文件续传
    public func sendDownloadResume(config: MeshConfig, progress: ProgressListener?, success: RequestSuccess?, failure: RequestFailure?) {
        
        guard let resumeData = config.resumeData else {
            return
        }

        AF.download(resumingWith: resumeData, to: config.destination).downloadProgress(closure: { (progr) in
            
            progress?(progr)
            
        }).responseData { (responseData) in
            
            config.fileURL = responseData.fileURL
            config.resumeData = responseData.resumeData
            
            switch responseData.result {
            case .success:
                config.mssage = "下载完成"
                config.code = RequestCode.success.rawValue
                success?(config)
            case .failure:
                config.mssage = "下载失败"
                config.code = RequestCode.errorResult.rawValue
                failure?(config)
            }
            
        }
        
    }
    // MARK: 统一上传方法
    public func uploadWithConfig(configBlock: RequestConfig?, progress: ProgressListener?, success: RequestSuccess?, failure: RequestFailure?) {
        
        guard let block = configBlock else {
            return
        }
        
        let config = MeshConfig.init()
        block(config)
        changeConfig(config)
        
        switch config.uploadType {
        case .multipart:
            sendUploadMultipart(config: config, progress: progress, success: success, failure: failure)
        default:
            sendUpload(config: config, progress: progress, success: success, failure: failure)
        }
    }
    // MARK: 简单上传文件方法
    public func sendUpload(config: MeshConfig, progress: ProgressListener?, success: RequestSuccess?, failure: RequestFailure?) {
        
        guard let url = config.URLString else {
            return
        }

        let uploadRequest : UploadRequest
        
        switch config.uploadType {
        case .file:
            guard let fileURL = config.fileURL else {
                return
            }
            uploadRequest = AF.upload(fileURL, to: url, method: config.requestMethod, headers: config.addHeads)
            
        case .stream:
            guard let stream = config.stream else {
                return
            }
            uploadRequest = AF.upload(stream, to: url, method: config.requestMethod, headers: config.addHeads)
            
        default:
            guard let fileData = config.fileData else {
                return
            }
            uploadRequest = AF.upload(fileData, to: url, method: config.requestMethod, headers: config.addHeads)
            
        }
        
        uploadRequest.uploadProgress { (progr) in
            progress?(progr)
        }
        
        uploadRequest.responseJSON { (response) in
            switch response.result {
            case .success:
                config.code = RequestCode.success.rawValue
                config.mssage = "上传成功"
                success?(config)
            case .failure:
                config.code = RequestCode.errorResult.rawValue
                config.mssage = "上传失败"
                failure?(config)
            }
        }
        
    }
    // MARK: 表单上传
    public func sendUploadMultipart(config: MeshConfig, progress: ProgressListener?, success: RequestSuccess?, failure: RequestFailure?) {
        
        guard let url = config.URLString, let uploadDatas = config.uploadDatas  else {
            return
        }
        
        AF.upload(multipartFormData: { (multi) in

            uploadDatas.forEach { (updataConfig) in
                if let fileData = updataConfig.fileData{
                    ///Data数据表单,图片等类型
                    if let fileName = updataConfig.fileName,
                        let mimeType =  updataConfig.mimeType{
                        multi.append(fileData, withName: updataConfig.name ?? "", fileName: fileName, mimeType: mimeType)
                    }else{
                        multi.append(fileData, withName: updataConfig.name ?? "")
                    }
                }else if let fileURL = updataConfig.fileURL{
                    ///文件类型表单,从 URL 路径获取文件上传
                    if let fileName = updataConfig.fileName,
                        let mimeType =  updataConfig.mimeType{
                        multi.append(fileURL, withName: updataConfig.name ?? "", fileName: fileName, mimeType: mimeType)
                    }else{
                        multi.append(fileURL, withName: updataConfig.name ?? "")
                    }
                }
            }
            
        }, to: url, method: config.requestMethod, headers: config.addHeads).response { (response) in
            
            switch response.result{
            case .success( _):
                config.code = RequestCode.success.rawValue
                config.mssage = "上传成功"
                success?(config)
//                debugPrint("****:\(response) ****")
            case .failure( _):
                config.code = RequestCode.errorResult.rawValue
                config.mssage = "上传失败"
                failure?(config)
//                debugPrint(error)
            }

        }
    }
    
    /// 取消特定请求
    /// - Parameter url: 请求的地址,内部判断是否包含,请添加详细的 path
    public func cancelRequest(_ url :String){
        
        Session.default.session.getAllTasks { (tasks) in
            tasks.forEach { (task) in
                if let _ : Bool = task.currentRequest?.url?.absoluteString.contains(url){
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
    private func changeConfig(_ config: MeshConfig){
        ///设置默认参数 header
        var param = defaultParameters ?? [:]
        param.merge(config.parameters ?? [:]) { (_, new) in new}
        config.parameters = param

        guard let headers = globalHeaders else {
            return
        }
        headers.forEach {
            config.addHeads?.update($0)
        }
    }
    
    // MARK:- 打印输出
    private func meshLog(_ config: MeshConfig, response: AFDataResponse<Any>?) {
        #if DEBUG
        
        if canLogging{
            print("\n\n<><><><><>-「Alamofire Log」-<><><><><>\n\n>>>>>>>>>>>>>>>接口API:>>>>>>>>>>>>>>>\n\n\(String(describing: config.URLString))\n\n>>>>>>>>>>>>>>>参数parameters:>>>>>>>>>>>>>>>\n\n\(String(describing: config.parameters))\n\n>>>>>>>>>>>>>>>头headers:>>>>>>>>>>>>>>>\n\n\(String(describing: config.addHeads))\n\n>>>>>>>>>>>>>>>报文response:>>>>>>>>>>>>>>>\n\n\(replaceUnicode(unicodeStr:"\(String(describing: response))"))\n\n<><><><><>-「Alamofire END」-<><><><><>\n\n")
        }
        
        #endif
    }
    
    private func replaceUnicode(unicodeStr: String) -> String {
        let tempStr1 = unicodeStr.replacingOccurrences(of: "\\u", with: "\\U")
        let tempStr2 = tempStr1.replacingOccurrences(of: "\"", with: "\\\"")
        let tempStr3 = "\"".appending(tempStr2).appending("\"")
        guard let tempData = tempStr3.data(using: String.Encoding.utf8) else {
            return "unicode转码失败"
        }
        var returnStr:String = ""
        do {
            returnStr = try PropertyListSerialization.propertyList(from: tempData, options: [.mutableContainers], format: nil) as! String
        } catch {
            debugPrint(error)
        }
        return returnStr.replacingOccurrences(of: "\\r\\n", with: "\n")
    }

}
