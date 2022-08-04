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

public typealias ConfigClosure = (_ config: MeshConfig) -> Void

public class Mesh{
    
    public static var canLogging = false
    
    private static var globalHeaders: HTTPHeaders?
    private static var defaultParameters: [String: Any]?
    private static let networkManager = NetworkReachabilityManager()
    ///调用此方法可以防止网络请求被抓包,请在适当的位置调用,比如 func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool
    public static func disableHttpsProxy(){
        let sessionConfig = URLSessionConfiguration.af.default
        let proxyDict = [AnyHashable : Any]()
        sessionConfig.connectionProxyDictionary = proxyDict // 主要是这一行
    }
    // MARK: 设置全局 headers
    /// 设置全局 headers
    /// - Parameter headers:全局 headers
    public static func setGlobalHeaders(_ headers: HTTPHeaders?) {
        globalHeaders = headers
    }
    
    // MARK: 设置默认参数
    /// 设置默认参数
    /// - Parameter parameters: 默认参数
    public static func setDefaultParameters(_ parameters: [String: Any]?) {
        defaultParameters = parameters
    }
    
    // MARK: 是否联网
    /// 是否联网
    public static var isReachable: Bool {
        get {
            return networkManager?.isReachable ?? false
        }
    }
    // MARK: 是否WiFi
    /// 是否WiFi
    public static var isReachableWiFi: Bool {
        get {
            return networkManager?.isReachableOnEthernetOrWiFi ?? false
        }
    }
    // MARK: 是否WWAN
    /// 是否运营商网络
    public static var isReachableCellular: Bool {
        get {
            return networkManager?.isReachableOnCellular ?? false
        }
    }
    
    ///私有方法
    private static func changeConfig(_ config: MeshConfig){
        ///设置默认参数
        var param = defaultParameters ?? [:]
        param.merge(config.parameters ?? [:]) { (_, new) in new}
        config.parameters = param
        ///设置默认header
        guard let headers = globalHeaders else {
            return
        }
        
        if let _ = config.addHeads{
            
        }else{
            config.addHeads = []
        }
        
        headers.forEach {
            config.addHeads?.update($0)
            
        }
    }
    
    // MARK:- 打印输出
    private static func meshLog(_ config: MeshConfig,
                                response: AFDataResponse<Data?>?) {
#if DEBUG
        if canLogging{
            print("\n\n<><><><><>-「Alamofire Log」-<><><><><>\n\n>>>>>>>>>>>>>>>接口API:>>>>>>>>>>>>>>>\n\n\(String(describing: config.URLString))\n\n>>>>>>>>>>>>>>>参数parameters:>>>>>>>>>>>>>>>\n\n\(String(describing: config.parameters))\n\n>>>>>>>>>>>>>>>头headers:>>>>>>>>>>>>>>>\n\n\(String(describing: config.addHeads))\n\n>>>>>>>>>>>>>>>报文response:>>>>>>>>>>>>>>>\n\n\(String(describing: response))\n\n<><><><><>-「Alamofire END」-<><><><><>\n\n")
        }
#endif
    }
}

// MARK: 统一发起请求 支持 GET POST PUT DELETE
extension Mesh{
    
    ///适配器闭包发起请求(回调适配器) 支持 GET POST PUT DELETE
    /// - Parameters:
    ///   - configBlock: 请求适配器
    /// - Returns: 返回请求 MeshResult
    @discardableResult
    public static func requestWithConfig(_ configClosure: ConfigClosure) -> MeshResult {
        
        let config = MeshConfig()
        configClosure(config)
        
        return sendRequest(config)
    }
    
    /// 适配器发起请求 支持 GET POST PUT DELETE
    /// - Parameters:
    ///   - config: 实例好的适配器
    /// - Returns: 返回请求 MeshResult
    @discardableResult
    public static func sendRequest(_ config: MeshConfig)  -> MeshResult {
        
        guard let url = config.URLString else {
            fatalError("URLString 为空")
        }
        let result = MeshResult()
        
        ///设置默认参数 header
        changeConfig(config)
        
        result.request = AF.request(url,
                                    method: config.requestMethod,
                                    parameters: config.parameters,
                                    encoding: config.requestEncoding,
                                    headers: config.addHeads,
                                    interceptor: config.retry,
                                    requestModifier: { request in request.timeoutInterval = config.timeout}
        ).response { (response) in
            ///打印输出
            meshLog(config, response: response)
            result.handleResponse(response: response)
        }
        return result
    }
    
}

// MARK: 下载请求
extension Mesh{
    
    /// 适配器闭包发起下载请求
    /// - Parameters:
    ///   - configBlock: 适配器闭包
    /// - Returns: 返回请求 MeshResult
    @discardableResult
    public static func downLoadWithConfig(_ configClosure: ConfigClosure) -> MeshResult {
        
        let config = MeshConfig()
        configClosure(config)
        
        changeConfig(config)
        
        switch config.downloadType {
        case .resume:
            return sendDownloadResume(config)
        default:
            return sendDownload(config)
        }
        
    }
    
    /// 通过实例适配器发起下载请求
    /// - Parameters:
    ///   - config: 实例适配器
    /// - Returns: 返回请求 MeshResult
    @discardableResult
    public static func sendDownload(_ config: MeshConfig) -> MeshResult {
        
        guard let url = config.URLString else {
            fatalError("URLString 为空")
        }
        let result = MeshResult()
        
        result.request = AF.download(url,
                                     method: config.requestMethod,
                                     parameters: config.parameters,
                                     encoding: config.requestEncoding,
                                     headers: config.addHeads,
                                     interceptor: config.retry,
                                     requestModifier: { request in request.timeoutInterval = config.timeout},
                                     to: config.destination
        ).downloadProgress(closure: { (progress) in
            
            result.handleProgress(progress: progress)
            
        }).responseData { (responseData) in
            result.handleDownloadResponse(response: responseData)
        }
        return result
    }
    
    /// 通过实例适配器发起继续下载请求
    /// - Parameters:
    ///   - config: 实例适配器
    /// - Returns: 返回请求 MeshResult
    @discardableResult
    public static func sendDownloadResume(_ config: MeshConfig) -> MeshResult {
        
        guard let resumeData = config.resumeData else {
            fatalError("resumeData 为空")
        }
        let result = MeshResult()
        result.request = AF.download(resumingWith: resumeData,
                                     interceptor: config.retry,
                                     to: config.destination
        ).downloadProgress(closure: { (progress) in
            
            result.handleProgress(progress: progress)
            
        }).responseData { (responseData) in
            
            result.handleDownloadResponse(response: responseData)
            
        }
        return result
    }
}

// MARK: 上传请求
extension Mesh{
    
    /// 适配器闭包发起上传请求--支持表单通过适配器方法创建表单
    /// - Parameters:
    ///   - configBlock: 适配器闭包
    ///   - progress: 上传进度
    ///   - success: 成功回调
    ///   - failure: 失败回调
    /// - Returns: 返回请求 UploadRequest
    @discardableResult
    public static func uploadWithConfig(_ configClosure: ConfigClosure) -> MeshResult {
        
        let config = MeshConfig()
        configClosure(config)
        changeConfig(config)
        
        switch config.uploadType {
        case .multipart:
            return sendUploadMultipart(config)
        default:
            return sendUpload(config)
        }
    }
    
    /// 适配器发起上传请求--支持文件，流
    /// - Parameters:
    ///   - config: 适配器
    ///   - progress: 上传进度
    ///   - success: 成功回调
    ///   - failure: 失败回调
    /// - Returns: 返回请求 UploadRequest
    @discardableResult
    public static func sendUpload(_ config: MeshConfig) -> MeshResult {
        
        guard let url = config.URLString else {
            fatalError("URLString 为空")
        }
        let result = MeshResult()
        
        let uploadRequest : UploadRequest
        
        switch config.uploadType {
        case .file:
            guard let fileURL = config.fileURL else {
                fatalError("fileURL 为空")
            }
            uploadRequest = AF.upload(fileURL,
                                      to: url,
                                      method: config.requestMethod,
                                      headers: config.addHeads,
                                      interceptor: config.retry,
                                      requestModifier: { request in request.timeoutInterval = config.timeout})
            
        case .stream:
            guard let stream = config.stream else {
                fatalError("stream 为空")
            }
            uploadRequest = AF.upload(stream,
                                      to: url,
                                      method: config.requestMethod,
                                      headers: config.addHeads,
                                      interceptor: config.retry,
                                      requestModifier: { request in request.timeoutInterval = config.timeout})
            
        default:
            guard let fileData = config.fileData else {
                fatalError("fileData 为空")
            }
            uploadRequest = AF.upload(fileData,
                                      to: url,
                                      method: config.requestMethod,
                                      headers: config.addHeads,
                                      interceptor: config.retry,
                                      requestModifier: { request in request.timeoutInterval = config.timeout})
            
        }
        
        uploadRequest.uploadProgress { (progress) in
            result.handleProgress(progress: progress)
        }
        
        result.request = uploadRequest
        uploadRequest.responseData { (response) in
            result.handleUploadResponse(response: response)
        }
        return result
    }
    
    /// 适配器发起上传请求--表单 根据适配器中相应方法创建表单
    /// - Parameters:
    ///   - config: 适配器
    ///   - progress: 上传进度
    ///   - success: 成功回调
    ///   - failure: 失败回调
    /// - Returns: 返回请求 UploadRequest
    @discardableResult
    public static func sendUploadMultipart(_ config: MeshConfig) -> MeshResult {
        
        guard let url = config.URLString, let uploadDatas = config.uploadDatas  else {
            fatalError("URLString / uploadDatas 为空")
        }
        
        let result = MeshResult()
        
        result.request = AF.upload(multipartFormData: { (multi) in
            
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
            
        },
                                   to: url,
                                   method: config.requestMethod,
                                   headers: config.addHeads,
                                   interceptor: config.retry,
                                   requestModifier: { request in request.timeoutInterval = config.timeout}
        ).response { (response) in
            
            result.handleResponse(response: response)
            
        }.uploadProgress(closure: { progress in
            result.handleProgress(progress: progress)
        })
        return result
    }
}

// MARK: 取消请求
extension Mesh{
    /// 取消特定请求
    /// - Parameter url: 请求的地址,内部判断是否包含,请添加详细的 path
    public static func cancelRequest(_ url :String){
        
        Session.default.session.getAllTasks { (tasks) in
            tasks.forEach { (task) in
                if let _ : Bool = task.currentRequest?.url?.absoluteString.contains(url){
                    task.cancel()
                }
            }
        }
    }
    
    /// 清空所有请求
    public static func cancelAllRequest(){
        
        Session.default.session.getAllTasks { (tasks) in
            tasks.forEach { (task) in
                task.cancel()
            }
        }
    }
    
}
