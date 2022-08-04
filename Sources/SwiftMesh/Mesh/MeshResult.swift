//
//  MeshResult.swift
//  SwiftMesh
//
//  Created by 狄烨 on 2022/8/3.
//  Copyright © 2022 iOS. All rights reserved.
//

import Foundation
import Alamofire

public struct MeshMessage {
    /// 错误码
    var code = -1
    /// 错误描述
    var description: String

}

public typealias SuccessClosure = (_ responseData: Data?) -> Void
public typealias FailureClosure = (_ error: MeshMessage) -> Void
public typealias ProgressClosure = (Progress) -> Void

public class MeshResult {
    ///当前请求
    public var request: Alamofire.Request?
    /// AF请求下来的完整response，可自行处理
    public var response: AFDataResponse<Data?>?
    ///已下载的部分文件存放URL,下载完成时取地址用
    public var fileURL: URL?
    ///已下载的部分数据
    public var resumeData : Data?
    
    func handleResponse(response: AFDataResponse<Data?>) {
        
        self.response = response

        switch response.result {
        case .failure(let error):
            if let closure = failureClosure {
                let error = MeshMessage(code: error.responseCode ?? -1, description: error.localizedDescription)
                closure(error)
            }
        case .success(let data):
            if let data = data {
                if let closure = successClosure {
                    closure(data)
                }
            }else{
                if let closure = failureClosure {
                    let error = MeshMessage(code: -1, description: "response.data 空")
                    closure(error)
                }
            }
        }
    }

    func handleDownloadResponse(response: AFDownloadResponse<Data>) {
        
        self.fileURL = response.fileURL
        self.resumeData = response.resumeData
        
        switch response.result {
        case .failure(let error):
            if let closure = failureClosure {
                let error = MeshMessage(code: error.responseCode ?? -1, description: error.localizedDescription)
                closure(error)
            }
        case .success:
            if let closure = successClosure {
                closure(nil)
            }
        }
    }
    
    func handleUploadResponse(response: AFDataResponse<Data>) {
 
        switch response.result {
        case .failure(let error):
            if let closure = failureClosure {
                let error = MeshMessage(code: error.responseCode ?? -1, description: error.localizedDescription)
                closure(error)
            }
        case .success(let data):
            if let closure = successClosure {
                closure(data)
            }
        }
    }
    
    func handleProgress(progress: Foundation.Progress) {
        
        if let closure = progressClosure {
            closure(progress)
        }
    }
     
    private var successClosure: SuccessClosure?
    private var failureClosure: FailureClosure?
    private var progressClosure: ProgressClosure?
    
    @discardableResult
    public func success(_ closure: @escaping SuccessClosure) -> Self {
        successClosure = closure
        return self
    }

    @discardableResult
    public func failed(_ closure: @escaping FailureClosure) -> Self {
        failureClosure = closure
        return self
    }
    @discardableResult
    public func progress(closure: @escaping ProgressClosure) -> Self {
        progressClosure = closure
        return self
    }

    public func cancel() {
        request?.cancel()
    }
 }
