//
//  MeshConfig.swift
//  SwiftMesh
//
//  Created by iOS on 2019/12/27.
//  Copyright © 2019 iOS. All rights reserved.
//

import Foundation
import Alamofire
public class MeshConfig {
    /// 超时配置
    var timeout : TimeInterval = 15.0
    /// 添加请求头
    var addHeads : HTTPHeaders?
    /// 请求方式
    var requestType : HTTPMethod = .get
    /// 请求地址
    var URLString : String?

    ///参数
    var parameters : [String: Any]?
    
    //服务端返回参数 定义错误码 错误信息 或者 正确信息
    var code : Int = 0
    var mssage : String?
}
