//
//  SwiftJson.swift
//  Example
//
//  Created by FunWidget on 2024/7/11.
//

import Foundation
import SwiftyJSON
import Alamofire
import SwiftMesh

public protocol JSONable {
    init(json: JSON)
}

public extension Mesh{
    func request<T: JSONable>(of type: T.Type) async throws -> T {
        
        let url = checkUrl()
        
        mergeConfig()
        
        let request = AF.request(url,
                                 method: requestMethod,
                                 parameters: parameters,
                                 encoding: requestEncoding,
                                 headers: HTTPHeaders(addHeads),
                                 interceptor: interceptor,
                                 requestModifier: { $0.timeoutInterval = self.timeout }
        )
        
        return try await handleModel(of: type, request: request)
    }
    
    
    func handleModel<T: JSONable>(of type: T.Type,
                                  request: DataRequest) async throws -> T {
        
        let requestTask = request.serializingData()
        
        let result = await requestTask.response.result
        
        return try await withCheckedThrowingContinuation { continuation in
            switch result{
            case .success(let data):
                
                if let json = try? JSON(data: data){
                    let model = T.init(json: json)
                    continuation.resume(returning: model)
                }else{
                    continuation.resume(throwing: APIError.jsonError(reason: "Json 解析失败"))
                }
            case .failure(let error):
                
                continuation.resume(throwing: self.handleError(error: error))
            }
        }
    }
}

enum APIError: Error {
    case jsonError(reason: String)
}
