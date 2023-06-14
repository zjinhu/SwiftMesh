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
    ///私有方法
    func mergeConfig(_ config: Config){
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
    
    func handleError(error: AFError) -> Error {
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
                                     modelKeyPath: String? = nil,
                                     config: Config) async throws -> T {
        
        if let path = modelKeyPath{
            let requestTask = request.serializingData(automaticallyCancelling: true)
            
            let result = await requestTask.response.result
            
            return try await withCheckedThrowingContinuation { continuation in
                switch result{
                case .success(let data):
                    if let model = try? JSONDecoder.default.decode(T.self, from: data, keyPath: path){
                        continuation.resume(returning: model)
                    }else{
                        continuation.resume(throwing: NSError(domain: "json解析失败,检查keyPath",
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
    
    func handleDownloadProgress(request: DownloadRequest){
        
        request.downloadProgress { progress in
            let completed: Float = Float(progress.completedUnitCount)
            let total: Float = Float(progress.totalUnitCount)
            
            self.downloadProgress = completed/total
        }
    }
    
    func handleUploadProgress(request: UploadRequest){
        
        request.uploadProgress { progress in
            let completed: Float = Float(progress.completedUnitCount)
            let total: Float = Float(progress.totalUnitCount)
            
            self.uploadProgress = completed/total
        }
    }
}
 
