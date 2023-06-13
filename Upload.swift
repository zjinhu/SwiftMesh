//
//  Upload.swift
//  SwiftMesh
//
//  Created by iOS on 2023/6/13.
//

import Foundation
import Alamofire
extension Mesh{
    public func upload<T: Decodable>(of type: T.Type,
                                     modelKeyPath: String? = nil,
                                     configClosure: ConfigClosure) async throws -> T{
        
        let config = Config()
        configClosure(config)
        
        switch config.uploadType {
        case .multipart:
            return try await sendUploadMultipart(of: type,
                                                 modelKeyPath: modelKeyPath,
                                                 config: config)
        default:
            return try await sendUpload(of: type,
                                        modelKeyPath: modelKeyPath,
                                        config: config)
        }
    }
    
    private func sendUpload<T: Decodable>(of type: T.Type,
                                          modelKeyPath: String? = nil,
                                          config: Config) async throws -> T{
        
        guard let url = config.URLString else {
            fatalError("URLString 为空")
        }
        
        var uploadRequest : UploadRequest
        
        switch config.uploadType {
        case .file:
            guard let fileURL = config.fileURL else {
                fatalError("fileURL 为空")
            }
            uploadRequest = AF.upload(fileURL,
                                      to: url,
                                      method: config.requestMethod,
                                      headers: config.addHeads,
                                      interceptor: config.interceptor,
                                      requestModifier: { request in request.timeoutInterval = config.timeout})
            
        case .stream:
            guard let stream = config.stream else {
                fatalError("stream 为空")
            }
            uploadRequest = AF.upload(stream,
                                      to: url,
                                      method: config.requestMethod,
                                      headers: config.addHeads,
                                      interceptor: config.interceptor,
                                      requestModifier: { request in request.timeoutInterval = config.timeout})
            
        default:
            guard let fileData = config.fileData else {
                fatalError("fileData 为空")
            }
            uploadRequest = AF.upload(fileData,
                                      to: url,
                                      method: config.requestMethod,
                                      headers: config.addHeads,
                                      interceptor: config.interceptor,
                                      requestModifier: { request in request.timeoutInterval = config.timeout})
            
        }
        
        if let path = modelKeyPath{
            let requestTask = uploadRequest.serializingData(automaticallyCancelling: true)
            
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
            let requestTask = uploadRequest.serializingDecodable(T.self,
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
    
    private func sendUploadMultipart<T: Decodable>(of type: T.Type,
                                                   modelKeyPath: String? = nil,
                                                   config: Config) async throws -> T{
        
        guard let url = config.URLString, let uploadDatas = config.uploadDatas  else {
            fatalError("URLString / uploadDatas 为空")
        }
        
        let uploadRequest = AF.upload(multipartFormData: { (multi) in
            
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
                                      interceptor: config.interceptor,
                                      requestModifier: { request in request.timeoutInterval = config.timeout}
        )
        
        if let path = modelKeyPath{
            let requestTask = uploadRequest.serializingData(automaticallyCancelling: true)
            
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
            let requestTask = uploadRequest.serializingDecodable(T.self,
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
}
