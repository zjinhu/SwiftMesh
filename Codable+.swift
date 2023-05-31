//
//  DefaultCodable.swift
//  SwiftMesh
//
//  Created by iOS on 2023/5/31.
//

import Foundation

//  不确定服务器返回什么类型，都转换为 String 然后保证正常解析
//  当前支持 Double Int String
//  其他类型会解析成 nil
//
/// 将 String Int Double 解析为 String? 的包装器
@propertyWrapper public struct DefaultString: Codable {
    public var wrappedValue: String?
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        var string: String?
        do {
            string = try container.decode(String.self)
        } catch {
            do {
                string = String(try container.decode(Int.self))
            } catch {
                do {
                    string = String(try container.decode(Double.self))
                } catch {
                    // 如果不想要 String? 可以在此处给 string 赋值  = “”
                    string = nil
                }
            }
        }
        wrappedValue = string
    }
}

public protocol DefaultValueProvider {
    associatedtype Value: Codable
    static var defaultValue: Value { get }
}

public enum Codables {}

extension Codables.Wrapper: Codable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        wrappedValue = try container.decode(Value.self)
    }
}

extension KeyedDecodingContainer {
    func decode<T>(_ type: Codables.Wrapper<T>.Type,
                   forKey key: Key) throws -> Codables.Wrapper<T> {
        try decodeIfPresent(type, forKey: key) ?? .init()
    }
}

extension Codables {
    @propertyWrapper
    public struct Wrapper<Source: DefaultValueProvider> {
        public typealias Value = Source.Value
        public var wrappedValue = Source.defaultValue
        
        public init(wrappedValue: Value = Source.defaultValue) {
            self.wrappedValue = wrappedValue
        }
    }
}

extension Codables {
    public typealias Source = DefaultValueProvider
    public typealias List = Codable & ExpressibleByArrayLiteral
    public typealias Map = Codable & ExpressibleByDictionaryLiteral
    
    public enum Sources {
        public enum True: Source {
            public static var defaultValue: Bool { true }
        }
        
        public enum False: Source {
            public static var defaultValue: Bool { false }
        }
        
        public enum EmptyString: Source {
            public static var defaultValue: String { "" }
        }
        
        public enum EmptyInt: Source {
            public static var defaultValue: Int { 0 }
        }
        
        public enum EmptyList<T: List>: Source {
            public static var defaultValue: T { [] }
        }
        
        public enum EmptyMap<T: Map>: Source {
            public static var defaultValue: T { [:] }
        }
        
        public enum Now: Source{
            public static var defaultValue: Date { Date() }
        }
    }
}
/**
 * Property wrappers to allow providing default values to properties in `Decodable` types.
 * https://swiftbysundell.com/tips/default-decoding-values/
 * Example usage:
 * ```
 * struct Data {
 *   @CodableDefault.True var bool1: Bool
 *   @CodableDefault.False var bool2: Bool
 *   @CodableDefault.EmptyString var identifier: String
 *   @CodableDefault.EmptyArray var values: [String]
 *   @CodableDefault.EmptyDictionary var dictionary: [String: Int]
 *   @CodableDefault.Now var date: Date
 * }
 * ```
 */
extension Codables {
    
    public typealias True = Wrapper<Sources.True>
    public typealias False = Wrapper<Sources.False>
    public typealias EmptyString = Wrapper<Sources.EmptyString>
    public typealias EmptyInt = Wrapper<Sources.EmptyInt>
    public typealias EmptyArray<T: List> = Wrapper<Sources.EmptyList<T>>
    public typealias EmptyDictionary<T: Map> = Wrapper<Sources.EmptyMap<T>>
    public typealias Now = Wrapper<Sources.Now>
    
}
