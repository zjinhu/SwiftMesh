//
//  Codable+.swift
//  SwiftMesh
//
//  Created by iOS on 2023/5/31.
//

import Foundation

// MARK: - Default Value Property Wrappers
// MARK: - 默认值属性包装器

/**
 * Property wrappers for resilient decoding with fallback defaults.
 * When a JSON field is missing or has an incorrect type, these wrappers
 * provide sensible default values instead of throwing decoding errors.
 *
 * 用于弹性解码的属性包装器，提供回退默认值。
 * 当 JSON 字段缺失或类型不正确时，这些包装器提供合理的默认值，
 * 而不是抛解码错误。
 *
 * Reference / 参考:
 * https://swiftbysundell.com/tips/default-decoding-values/
 *
 * Example usage / 示例用法:
 * ```swift
 * struct Response {
 *     @Default.True var isEnabled: Bool          // defaults to true / 默认 true
 *     @Default.False var isDeleted: Bool         // defaults to false / 默认 false
 *     @Default.EmptyString var identifier: String // defaults to "" / 默认 ""
 *     @Default.EmptyInt var count: Int           // defaults to 0 / 默认 0
 *     @Default.EmptyArray var values: [String]   // defaults to [] / 默认 []
 *     @Default.EmptyDictionary var meta: [String: Int] // defaults to [:] / 默认 [:]
 *     @Default.Now var createdAt: Date           // defaults to Date() / 默认当前时间
 * }
 * ```
 */

// MARK: - Default Type Aliases / Default 类型别名

extension Default {
    /// Defaults to `true` when the field is missing or invalid
    /// 字段缺失或无效时默认为 `true`
    public typealias True = Wrapper<Sources.True>

    /// Defaults to `false` when the field is missing or invalid
    /// 字段缺失或无效时默认为 `false`
    public typealias False = Wrapper<Sources.False>

    /// Defaults to empty string `""` when the field is missing or invalid
    /// 字段缺失或无效时默认为空字符串 `""`
    public typealias EmptyString = Wrapper<Sources.EmptyString>

    /// Defaults to `0` when the field is missing or invalid
    /// 字段缺失或无效时默认为 `0`
    public typealias EmptyInt = Wrapper<Sources.EmptyInt>

    /// Defaults to empty array `[]` when the field is missing or invalid
    /// 字段缺失或无效时默认为空数组 `[]`
    public typealias EmptyArray<T: List> = Wrapper<Sources.EmptyList<T>>

    /// Defaults to empty dictionary `[:]` when the field is missing or invalid
    /// 字段缺失或无效时默认为空字典 `[:]`
    public typealias EmptyDictionary<T: Map> = Wrapper<Sources.EmptyMap<T>>

    /// Defaults to current date `Date()` when the field is missing or invalid
    /// 字段缺失或无效时默认为当前日期 `Date()`
    public typealias Now = Wrapper<Sources.Now>
}

// MARK: - Default Value Provider Protocol
// MARK: - 默认值提供者协议

/// Protocol for types that provide a default value.
/// 提供默认值的类型所遵循的协议。
public protocol DefaultValueProvider {
    associatedtype Value
    static var defaultValue: Value { get }
}

/// Optional types default to `.none` (nil).
/// Optional 类型默认为 `.none`（nil）。
extension Optional: DefaultValueProvider {
    public static var defaultValue: Wrapped? { return .none }
}

/// Namespace enum for default value wrappers.
/// 默认值包装器的命名空间枚举。
public enum Default {}

/// Codable conformance for the Default wrapper.
/// Default 包装器的 Codable 一致性。
extension Default.Wrapper: Codable where Value: Codable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        wrappedValue = try container.decode(Value.self)
    }
}

/// Custom decoding for keyed containers to handle missing fields gracefully.
/// 键控容器的自定义解码，优雅处理缺失字段。
extension KeyedDecodingContainer {
    func decode<T>(_ type: Default.Wrapper<T>.Type,
                   forKey key: Key) throws -> Default.Wrapper<T> where T.Value: Codable {
        try decodeIfPresent(type, forKey: key) ?? .init()
    }
}

// MARK: - Default Wrapper Implementation
// MARK: - Default 包装器实现

extension Default {
    /// Generic property wrapper that applies a default value on decode failure.
    /// 通用属性包装器，在解码失败时应用默认值。
    @propertyWrapper
    public struct Wrapper<Source: DefaultValueProvider> {
        public typealias Value = Source.Value
        public var wrappedValue = Source.defaultValue

        public init(wrappedValue: Value = Source.defaultValue) {
            self.wrappedValue = wrappedValue
        }
    }
}

// MARK: - Default Value Sources
// MARK: - 默认值来源

extension Default {
    public typealias Source = DefaultValueProvider
    public typealias List = Codable & ExpressibleByArrayLiteral
    public typealias Map = Codable & ExpressibleByDictionaryLiteral

    public enum Sources {
        /// Default value: `true` / 默认值：`true`
        public enum True: Source {
            public static var defaultValue: Bool { true }
        }

        /// Default value: `false` / 默认值：`false`
        public enum False: Source {
            public static var defaultValue: Bool { false }
        }

        /// Default value: `""` (empty string) / 默认值：`""`（空字符串）
        public enum EmptyString: Source {
            public static var defaultValue: String { "" }
        }

        /// Default value: `0` (zero) / 默认值：`0`（零）
        public enum EmptyInt: Source {
            public static var defaultValue: Int { 0 }
        }

        /// Default value: `[]` (empty array) / 默认值：`[]`（空数组）
        public enum EmptyList<T: List>: Source {
            public static var defaultValue: T { [] }
        }

        /// Default value: `[:]` (empty dictionary) / 默认值：`[:]`（空字典）
        public enum EmptyMap<T: Map>: Source {
            public static var defaultValue: T { [:] }
        }

        /// Default value: `Date()` (current date/time) / 默认值：`Date()`（当前日期/时间）
        public enum Now: Source {
            public static var defaultValue: Date { Date() }
        }
    }
}

// MARK: - IgnoreError Property Wrapper
// MARK: - IgnoreError 属性包装器

/// Decodes a value when possible, otherwise yields `nil`.
/// Provides resilient handling of JSON with unexpected shapes such as
/// missing fields or incorrect types. Without this, a single bad field
/// would throw a `DecodingError` and abort the entire decode process.
///
/// 尽可能解码值，否则返回 `nil`。
/// 为具有意外形状（如缺失字段或类型不正确）的 JSON 提供弹性处理。
/// 不使用此包装器时，单个错误字段会抛出 `DecodingError` 并中止整个解码过程。
///
/// For global error handling, consider: https://github.com/Pircate/CleanJSON
/// 如需全局错误处理，可参考：https://github.com/Pircate/CleanJSON
///
/// Example / 示例:
/// ```swift
/// struct Response {
///     @IgnoreError var description: String?  // nil if decoding fails / 解码失败时为 nil
/// }
/// ```
@propertyWrapper public struct IgnoreError<Wrapped: Codable> {
    /// The decoded value, or nil if decoding failed.
    /// 解码后的值，如果解码失败则为 nil。
    public let wrappedValue: Wrapped?

    public init(wrappedValue: Wrapped?) {
        self.wrappedValue = wrappedValue
    }
}

extension IgnoreError: Decodable {
    public init(from decoder: Decoder) throws {
        let container = try? decoder.singleValueContainer()
        wrappedValue = try? container?.decode(Wrapped.self)
    }
}

/// Protocol to work around Swift compiler limitations with property wrappers
/// and non-existing fields. Without this, the compiler always fails when
/// there is no matching key for a property wrapper.
/// 解决 Swift 编译器对属性包装器和不存在字段的限制。
/// 没有此协议时，编译器在属性包装器没有匹配键时总是会失败。
public protocol NullableCodable {
    associatedtype Wrapped: Decodable, ExpressibleByNilLiteral
    var wrappedValue: Wrapped { get }
    init(wrappedValue: Wrapped)
}

extension IgnoreError: NullableCodable {}

extension KeyedDecodingContainer {
    /// Custom decoding for NullableCodable types to handle missing fields.
    /// Returns nil instead of throwing when the key doesn't exist.
    /// NullableCodable 类型的自定义解码，处理缺失字段。
    /// 当键不存在时返回 nil 而不是抛出错误。
    public func decode<T: NullableCodable>(_ type: T.Type, forKey key: Key) throws -> T where T: Decodable {
        let decoded = try self.decodeIfPresent(T.self, forKey: key) ?? T(wrappedValue: nil)
        return decoded
    }
}

extension IgnoreError: Encodable where Wrapped: Encodable {
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(wrappedValue)
    }
}

extension IgnoreError: Equatable where Wrapped: Equatable {}

extension IgnoreError: Hashable where Wrapped: Hashable {}

#if swift(>=5.5)
extension IgnoreError: Sendable where Wrapped: Sendable {}
#endif

// MARK: - Type Conversion Property Wrappers
// MARK: - 类型转换属性包装器

/// Flexible decoder that accepts String, Int, or Double from JSON
/// and converts to String?. Returns nil if none match.
///
/// 灵活的解码器，接受 JSON 中的 String、Int 或 Double，
/// 并转换为 String?。如果都不匹配则返回 nil。
///
/// Example / 示例:
/// ```swift
/// struct Response {
///     @ConvertToString var version: String?  // "1", 1, or 1.0 all become "1" / "1"、1 或 1.0 都变为 "1"
/// }
/// ```
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
                    // Set to "" if you prefer non-optional String
                    // 如果不需要可选 String，可在此处赋值为 ""
                    string = nil
                }
            }
        }
        wrappedValue = string
    }
}

/// Flexible decoder that accepts Int, String, or Double from JSON
/// and converts to Int?. Returns nil if none match.
///
/// 灵活的解码器，接受 JSON 中的 Int、String 或 Double，
/// 并转换为 Int?。如果都不匹配则返回 nil。
///
/// Example / 示例:
/// ```swift
/// struct Response {
///     @ConvertToInt var count: Int?  // 42, "42", or 42.0 all become 42 / 42、"42" 或 42.0 都变为 42
/// }
/// ```
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

/// Flexible decoder that accepts Double, Int, Float, or String from JSON
/// and converts to Double?. Returns nil if none match.
///
/// 灵活的解码器，接受 JSON 中的 Double、Int、Float 或 String，
/// 并转换为 Double?。如果都不匹配则返回 nil。
///
/// Example / 示例:
/// ```swift
/// struct Response {
///     @ConvertToDouble var price: Double?  // 9.99, 10, "9.99" all become 9.99 / 9.99、10、"9.99" 都变为 9.99
/// }
/// ```
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

/// Flexible decoder that accepts Float, Int, Double, or String from JSON
/// and converts to Float?. Returns nil if none match.
///
/// 灵活的解码器，接受 JSON 中的 Float、Int、Double 或 String，
/// 并转换为 Float?。如果都不匹配则返回 nil。
///
/// Example / 示例:
/// ```swift
/// struct Response {
///     @ConvertToFloat var rating: Float?  // 4.5, 5, "4.5" all become 4.5 / 4.5、5、"4.5" 都变为 4.5
/// }
/// ```
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
