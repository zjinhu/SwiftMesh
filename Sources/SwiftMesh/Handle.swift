//
//  Handle.swift
//  SwiftMesh
//
//  Created by iOS on 2023/6/14.
//

import Foundation
import Alamofire
import Combine
extension Mesh{
    public func checkUrl() -> String{
        guard let urlPath else {
            fatalError("urlHost OR urlPath nil")
        }
        
        var url: String?
        
        if let host = Mesh.defaultUrlHost{
            url = host
        }
        
        if let urlHost{
            url = urlHost
        }
        
        guard let url else {
            fatalError("urlHost nil")
        }
        return url + urlPath
    }
 
    public func mergeConfig(){
        ///设置默认参数
        var param = Mesh.defaultParameters ?? [:]
        param.merge(parameters ?? [:]) { (_, new) in new}
        parameters = param
        ///设置默认header
        let headers = Mesh.defaultHeaders ?? [:]
        addHeads.merge(headers) { (_, new) in new}
    }
    
    public func handleError(error: AFError) -> Error {
        if let underlyingError = error.underlyingError {
            let nserror = underlyingError as NSError
            let code = nserror.code
            if code == NSURLErrorNotConnectedToInternet ||
                code == NSURLErrorTimedOut ||
                code == NSURLErrorInternationalRoamingOff ||
                code == NSURLErrorDataNotAllowed ||
                code == NSURLErrorCannotFindHost ||
                code == NSURLErrorCannotConnectToHost ||
                code == NSURLErrorNetworkConnectionLost {
                var userInfo = nserror.userInfo
                userInfo[NSLocalizedDescriptionKey] = "Unable to connect to the server"
                let currentError = NSError(
                    domain: nserror.domain,
                    code: code,
                    userInfo: userInfo
                )
                return currentError
            }
        }
        return error
    }
    
    func handleDownload(request: DownloadRequest) async throws -> URL {

        let downloadTask = request.serializingDownloadedFileURL(automaticallyCancelling: true)
        let result = await downloadTask.response.result
        
        return try await withCheckedThrowingContinuation { continuation in
            switch result{
            case .success(let url):
                continuation.resume(returning: url)
            case .failure(let error):
                continuation.resume(throwing: self.handleError(error: error))
            }
        }
    }
    
    func handleCodable<T: Decodable>(of type: T.Type,
                                     request: DataRequest,
                                     modelKeyPath: String? = nil) async throws -> T {

        if let path = modelKeyPath{
            let requestTask = request.serializingData(automaticallyCancelling: true)
            
            let result = await requestTask.response.result
            
            return try await withCheckedThrowingContinuation { continuation in
                switch result{
                case .success(let data):
                    if let model = try? JSONDecoder.default.decode(T.self, from: data, keyPath: path){
                        continuation.resume(returning: model)
                    }else{
                        continuation.resume(throwing: NSError(domain: "json parsing failure, check keyPath",
                                                              code: 0))
                    }
                case .failure(let error):
                    continuation.resume(throwing: self.handleError(error: error))
                }
            }
        }else{
            let requestTask = request.serializingDecodable(T.self,
                                                           automaticallyCancelling: true,
                                                           decoder: JSONDecoder.default)
            
            let result = await requestTask.response.result
            
            return try await withCheckedThrowingContinuation { continuation in
                switch result{
                case .success(let model):
                    continuation.resume(returning: model)
                case .failure(let error):
                    continuation.resume(throwing: self.handleError(error: error))
                }
            }
        }
    }
//    
//    func handleDownloadProgress(request: DownloadRequest){
//        
//        request.downloadProgress { progress in
//            
//            print(progress.fractionCompleted)
//            
//            DispatchQueue.main.async {
//                let completed: Float = Float(progress.completedUnitCount)
//                let total: Float = Float(progress.totalUnitCount)
//                self.downloadProgress = completed/total
//            }
//        }
//    }
//    
//    func handleUploadProgress(request: UploadRequest){
//        
//        request.uploadProgress { progress in
//            let completed: Float = Float(progress.completedUnitCount)
//            let total: Float = Float(progress.totalUnitCount)
//            
//            self.uploadProgress = completed/total
//        }
//    }
// 
}
 
public class RetryPolicy: RequestInterceptor {
    // 最大重试次数
    private let maxRetryCount: Int

    // 初始化方法
    public init(maxRetryCount: Int = 3) {
        self.maxRetryCount = maxRetryCount
    }

    // 是否应该重试请求的方法
    public func retry(_ request: Request, for session: Session, dueTo error: Error, completion: @escaping (RetryResult) -> Void) {
        // 获取当前重试次数
        let retryCount = request.retryCount

        // 如果当前重试次数小于最大重试次数，进行重试
        if retryCount < maxRetryCount {
            // 设置重试时间间隔，例如1秒后重试
            let retryInterval = TimeInterval(retryCount + 1)
            completion(.retryWithDelay(retryInterval))
        } else {
            // 达到最大重试次数，不再重试
            completion(.doNotRetry)
        }
    }
}
