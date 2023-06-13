//
//  Download.swift
//  SwiftMesh
//
//  Created by iOS on 2023/6/13.
//

import Foundation
import Alamofire
extension Mesh{
    
    public func download(configClosure: ConfigClosure) async throws -> URL{
        
        let config = Config()
        configClosure(config)
        
        switch config.downloadType {
        case .resume:
            return try await sendDownloadResume(config)
        default:
            return try await sendDownload(config)
        }
    }
    
    
    private func sendDownload(_ config: Config) async throws -> URL{
        guard let url = config.URLString else {
            fatalError("URLString 为空")
        }
        let request = AF.download(url,
                                  method: config.requestMethod,
                                  parameters: config.parameters,
                                  encoding: config.requestEncoding,
                                  headers: config.addHeads,
                                  interceptor: config.interceptor,
                                  requestModifier: { request in request.timeoutInterval = config.timeout},
                                  to: config.destination)
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
    
    private func sendDownloadResume(_ config: Config) async throws -> URL{
        guard let resumeData = config.resumeData else {
            fatalError("resumeData 为空")
        }
        
        let request = AF.download(resumingWith: resumeData,
                                  interceptor: config.interceptor,
                                  to: config.destination)
        
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
}
