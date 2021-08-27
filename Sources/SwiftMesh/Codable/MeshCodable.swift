//
//  MeshCodable.swift
//  SwiftMesh
//
//  Created by iOS on 2021/8/27.
//  Copyright © 2021 iOS. All rights reserved.
//

import Foundation

enum MeshCodable: Codable {
    case string(String)
    case int(Int)
    case double(Double)
    case boolean(Bool)
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        
        if let value = try? container.decode(String.self) {
            self = .string(value)
            return
        }
        
        if let value = try? container.decode(Int.self) {
            self = .int(value)
            return
        }
        
        if let value = try? container.decode(Double.self) {
            self = .double(value)
            return
        }
        
        if let value = try? container.decode(Bool.self) {
            self = .boolean(value)
            return
        }
        throw DecodingError.typeMismatch(MeshCodable.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Wrong type for MeshCodable"))
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .string(let value):
            try container.encode(value)
        case .int(let value):
            try container.encode(value)
        case .double(let value):
            try container.encode(value)
        case .boolean(let value):
            try container.encode(value)
        }
    }
    
    var stringValue: String {
        switch self {
        case .string(let value):
            return value
        default:
            return ""
        }
    }
    

    var intValue: Int {
        switch self {
        case .int(let value):
            return value
        default:
            return 0
        }
    }
    
    var doubleValue: Double {
        switch self {
        case .double(let value):
            return value
        default:
            return 0
        }
    }
    
    var booleanValue: Bool {
        switch self {
        case .boolean(let value):
            return value
        default:
            return false
        }
    }
    
}
