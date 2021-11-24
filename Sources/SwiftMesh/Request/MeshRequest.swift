//
//  MeshRequest.swift
//  SwiftMesh
//
//  Created by iOS on 2019/12/27.
//  Copyright © 2019 iOS. All rights reserved.
//
import Foundation
import Alamofire

/// 泛型封装普通请求,支持解析后直接返回泛型model
public class MeshRequest{
    
    public typealias requestCallBack<T: Codable> = (_ data: T?) -> Void
    
    
    /// get请求
    /// - Parameters:
    ///   - url: 请求地址
    ///   - parameters: 参数
    ///   - modelType: model类型
    ///   - modelKeyPath: model解析路径
    ///   - callBack: 返回model实例
    /// - Returns: 请求
    @discardableResult
    public static func get<T: Codable>(_ url: String,
                                       parameters: [String: Any] = [:],
                                       modelType: T.Type,
                                       modelKeyPath: String? = nil,
                                       callBack: requestCallBack<T>?) -> DataRequest? {
        return request(url,
                       parameters: parameters,
                       modelType: modelType,
                       modelKeyPath: modelKeyPath,
                       callBack: callBack)
    }
    
    /// post请求
    /// - Parameters:
    ///   - url: 请求地址
    ///   - parameters: 参数
    ///   - modelType: model类型
    ///   - modelKeyPath: model解析路径
    ///   - callBack: 返回model实例
    /// - Returns: 请求
    @discardableResult
    public static func post<T: Codable>(_ url: String,
                                        parameters: [String: Any] = [:],
                                        modelType: T.Type,
                                        modelKeyPath: String? = nil,
                                        callBack: requestCallBack<T>?) -> DataRequest? {
        return request(url,
                       requestMethod: .post,
                       parameters: parameters,
                       modelType: modelType,
                       modelKeyPath: modelKeyPath,
                       callBack: callBack)
    }
    
    static private func request<T: Codable>(_ url: String,
                                            requestMethod : HTTPMethod = .get,
                                            parameters: [String: Any] = [:],
                                            modelType: T.Type,
                                            modelKeyPath: String? = nil,
                                            callBack: requestCallBack<T>?) -> DataRequest? {
        return request(configBlock: { config in
            config.requestMethod = requestMethod
            config.URLString = url
            config.parameters = parameters
        }, modelType: modelType, modelKeyPath: modelKeyPath, callBack: callBack)
    }
    
    @discardableResult
    static public func request<T: Codable>(configBlock: RequestConfig?,
                                           modelType: T.Type,
                                           modelKeyPath: String? = nil,
                                           callBack: requestCallBack<T>?) -> DataRequest? {
        
        return Mesh.requestWithConfig(configBlock: configBlock) { config in
            if let keypath = modelKeyPath, keypath.count > 0 {
                
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                guard let data = config.response?.data, let model = try? decoder.decode(modelType.self, from: data, keyPath: keypath) else {
                    callBack?(nil)
                    return
                }
                
                callBack?(model)
                
            }else{
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                guard let data = config.response?.data, let model = try? decoder.decode(modelType.self, from: data) else {
                    callBack?(nil)
                    return
                }
                
                callBack?(model)
            }
        } failure: { config in
            callBack?(nil)
        }
    }
}


public extension JSONDecoder {
    
    func decode<T>(_ type: T.Type,
                   from data: Data,
                   keyPath: String,
                   keyPathSeparator separator: String = ".") throws -> T where T : Decodable {
        userInfo[keyPathUserInfoKey] = keyPath.components(separatedBy: separator)
        return try decode(KeyPathWrapper<T>.self, from: data).object
    }
}

private let keyPathUserInfoKey = CodingUserInfoKey(rawValue: "keyPathUserInfoKey")!

private final class KeyPathWrapper<T: Decodable>: Decodable {
    
    enum KeyPathError: Error {
        case `internal`
    }
    
    struct Key: CodingKey {
        init?(intValue: Int) {
            self.intValue = intValue
            stringValue = String(intValue)
        }
        
        init?(stringValue: String) {
            self.stringValue = stringValue
            intValue = nil
        }
        
        let intValue: Int?
        let stringValue: String
    }
    
    typealias KeyedContainer = KeyedDecodingContainer<KeyPathWrapper<T>.Key>
    
    init(from decoder: Decoder) throws {
        guard let keyPath = decoder.userInfo[keyPathUserInfoKey] as? [String],
              !keyPath.isEmpty
        else { throw KeyPathError.internal }
        
        func getKey(from keyPath: [String]) throws -> Key {
            guard let first = keyPath.first,
                  let key = Key(stringValue: first)
            else { throw KeyPathError.internal }
            return key
        }
        
        func objectContainer(for keyPath: [String],
                             in currentContainer: KeyedContainer,
                             key currentKey: Key) throws -> (KeyedContainer, Key) {
            guard !keyPath.isEmpty else { return (currentContainer, currentKey) }
            let container = try currentContainer.nestedContainer(keyedBy: Key.self, forKey: currentKey)
            let key = try getKey(from: keyPath)
            return try objectContainer(for: Array(keyPath.dropFirst()), in: container, key: key)
        }
        
        let rootKey = try getKey(from: keyPath)
        let rooTContainer = try decoder.container(keyedBy: Key.self)
        let (keyedContainer, key) = try objectContainer(for: Array(keyPath.dropFirst()), in: rooTContainer, key: rootKey)
        object = try keyedContainer.decode(T.self, forKey: key)
    }
    
    let object: T
}
