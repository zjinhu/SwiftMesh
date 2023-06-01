//
//  DefaultCodable.swift
//  SwiftMesh
//
//  Created by iOS on 2023/5/31.
//

import Foundation
/**
 * Property wrappers to allow providing default values to properties in `Decodable` types.
 * https://swiftbysundell.com/tips/default-decoding-values/
 * Example usage:
 * ```
 * struct Data {
 *   @Default.True var bool1: Bool
 *   @Default.False var bool2: Bool
 *   @Default.EmptyString var identifier: String
 *   @Default.EmptyArray var values: [String]
 *   @Default.EmptyDictionary var dictionary: [String: Int]
 *   @Default.Now var date: Date
 * }
 * ```
 */
extension Default {
    
    public typealias True = Wrapper<Sources.True>
    public typealias False = Wrapper<Sources.False>
    public typealias EmptyString = Wrapper<Sources.EmptyString>
    public typealias EmptyInt = Wrapper<Sources.EmptyInt>
    public typealias EmptyArray<T: List> = Wrapper<Sources.EmptyList<T>>
    public typealias EmptyDictionary<T: Map> = Wrapper<Sources.EmptyMap<T>>
    public typealias Now = Wrapper<Sources.Now>
    
}


public protocol DefaultValueProvider {
    associatedtype Value
    static var defaultValue: Value { get }
}

extension Optional: DefaultValueProvider {
    public static var defaultValue: Wrapped? { return .none }
}

public enum Default {}

extension Default.Wrapper: Codable where Value: Codable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        wrappedValue = try container.decode(Value.self)
    }
}

extension KeyedDecodingContainer {
    func decode<T>(_ type: Default.Wrapper<T>.Type,
                   forKey key: Key) throws -> Default.Wrapper<T> where T.Value: Codable {
        try decodeIfPresent(type, forKey: key) ?? .init()
    }
}

extension Default {
    @propertyWrapper
    public struct Wrapper<Source: DefaultValueProvider> {
        public typealias Value = Source.Value
        public var wrappedValue = Source.defaultValue
        
        public init(wrappedValue: Value = Source.defaultValue) {
            self.wrappedValue = wrappedValue
        }
    }
}

extension Default {
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

//  不确定服务器返回什么类型，都转换为 String 然后保证正常解析
//  当前支持 Double Int String
//  其他类型会解析成 nil
//
/// 将 String Int Double 解析为 String? 的包装器
@propertyWrapper public struct ConvertToString: Codable {
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

@propertyWrapper public struct ConvertToInt: Codable {
    public var wrappedValue: Int?
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        var int: Int?
        do {
            int = try container.decode(Int.self)
        } catch {
            do {
                int = Int(try container.decode(String.self))
            } catch {
                do {
                    int = Int(try container.decode(Double.self))
                } catch {
                    int = nil
                }
            }
        }
        wrappedValue = int
    }
}

@propertyWrapper public struct ConvertToDouble: Codable {
    public var wrappedValue: Double?
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        var double: Double?
        do {
            double = try container.decode(Double.self)
        } catch {
            do {
                double = Double(try container.decode(Int.self))
            } catch {
                do {
                    double = Double(try container.decode(Float.self))
                } catch {
                    do {
                        double = Double(try container.decode(String.self))
                    } catch {
                        double = nil
                    }
                }
            }
        }
        wrappedValue = double
    }
}

@propertyWrapper public struct ConvertToFloat: Codable {
    public var wrappedValue: Float?
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        var float: Float?
        do {
            float = try container.decode(Float.self)
        } catch {
            do {
                float = Float(try container.decode(Int.self))
            } catch {
                do {
                    float = Float(try container.decode(Double.self))
                } catch {
                    do {
                        float = Float(try container.decode(String.self))
                    } catch {
                        float = nil
                    }
                }
            }
        }
        wrappedValue = float
    }
}

// MARK: - IgnoreEncodable

/// A property wrapper that allows not encoding a value.
/// 允许不对值进行编码的属性包装器。
/// - Example:
/// ```
/// struct Data {
///     @Ignore var data: String // this value won't be encoded
/// }
/// ```
//@propertyWrapper
//public struct Ignore<Value>: Codable where Value: Codable  {
//
//    public var wrappedValue: Value
//    
//    public init(from decoder: Decoder) throws {
//        self.wrappedValue = try decoder.singleValueContainer().decode(Value.self)
//    }
//
//    public func encode(to encoder: Encoder) throws {}
//}
//
//
//extension Ignore: Equatable where Value: Equatable {}
//extension Ignore: Hashable where Value: Hashable {}
//
//extension KeyedEncodingContainer {
//
//    mutating func encode<T>(_ value: Ignore<T>, forKey key: K) throws {}
//
//}
