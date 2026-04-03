//
//  KeyPath.swift
//  SwiftMesh
//
//  Created by iOS on 2023/6/13.
//

import Foundation

// MARK: - JSON Key Path Decoder
// MARK: - JSON 键路径解码器

public extension JSONDecoder {

    /// Default JSONDecoder configured with snake_case to camelCase conversion
    /// and ISO8601 date decoding strategy.
    /// 默认 JSONDecoder，配置了蛇形命名转驼峰命名策略和 ISO8601 日期解码策略。
    static let `default`: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        decoder.dateDecodingStrategy = .iso8601
        return decoder
    }()

    /// Decode a nested JSON value at a given dot-separated key path.
    /// This allows extracting only a portion of the JSON without parsing the entire response.
    /// 在给定的点分隔键路径处解码嵌套 JSON 值。
    /// 这允许仅提取 JSON 的一部分，而无需解析整个响应。
    ///
    /// Example / 示例:
    /// ```swift
    /// // JSON: { "data": { "yesterday": { "temp": 25 } } }
    /// // Extract only the "yesterday" object:
    /// let weather = try JSONDecoder.default.decode(Weather.self, from: data, keyPath: "data.yesterday")
    /// ```
    ///
    /// - Parameters:
    ///   - type: The Decodable type to decode into / 要解码的目标类型
    ///   - data: The raw JSON data / 原始 JSON 数据
    ///   - keyPath: Dot-separated key path (e.g., "data.yesterday")
    ///              点分隔的键路径（例如 "data.yesterday"）
    ///   - separator: Key path separator character (default: ".")
    ///                键路径分隔符（默认 "."）
    /// - Returns: Decoded model instance / 解码后的模型实例
    /// - Throws: Decoding errors if the key path is invalid or type mismatch
    ///           如果键路径无效或类型不匹配则抛出解码错误
    func decode<T>(_ type: T.Type,
                   from data: Data,
                   keyPath: String,
                   keyPathSeparator separator: String = ".") throws -> T where T: Decodable {
        userInfo[keyPathUserInfoKey] = keyPath.components(separatedBy: separator)
        return try decode(KeyPathWrapper<T>.self, from: data).object
    }

    /// Decode an array of nested JSON values at a given dot-separated key path.
    /// 在给定的点分隔键路径处解码嵌套 JSON 值数组。
    ///
    /// - Parameters:
    ///   - type: The collection type to decode into / 要解码的目标集合类型
    ///   - data: The raw JSON data / 原始 JSON 数据
    ///   - keyPath: Dot-separated key path / 点分隔的键路径
    ///   - separator: Key path separator character (default: ".")
    ///                键路径分隔符（默认 "."）
    /// - Returns: Decoded collection / 解码后的集合
    /// - Throws: Decoding errors / 解码错误
    func decodeArray<T>(_ type: T.Type,
                        from data: Data,
                        keyPath: String,
                        keyPathSeparator separator: String = ".") throws -> T where T: RangeReplaceableCollection, T.Element: Decodable {
        userInfo[keyPathUserInfoKey] = keyPath.components(separatedBy: separator)
        return T(try self.decode([KeyPathWrapper<T.Element>].self, from: data).map(\.object))
    }
}

/// UserInfo key for storing the key path during decoding
/// 用于在解码过程中存储键路径的 UserInfo 键
private let keyPathUserInfoKey = CodingUserInfoKey(rawValue: "keyPathUserInfoKey")!

/// Wrapper that traverses the JSON hierarchy to extract a value at a given key path.
/// 包装器，用于遍历 JSON 层级以提取指定键路径处的值。
private final class KeyPathWrapper<T: Decodable>: Decodable {

    /// Internal error for key path traversal failures
    /// 键路径遍历失败的内部错误
    enum KeyPathError: Error {
        case `internal`
    }

    /// Generic CodingKey implementation for JSON traversal
    /// 用于 JSON 遍历的通用 CodingKey 实现
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
        let rootContainer = try decoder.container(keyedBy: Key.self)
        let (keyedContainer, key) = try objectContainer(for: Array(keyPath.dropFirst()), in: rootContainer, key: rootKey)
        object = try keyedContainer.decode(T.self, forKey: key)
    }

    /// The decoded object at the target key path
    /// 目标键路径处解码的对象
    let object: T
}
