# SwiftMesh
基于Alamofire和Codable的二次封装，更加方便的使用。涉及到的设计模式有：适配器，单例，抽象等等
## 介绍
### MeshManager
单例。
其中包括：
* 获取网络状态    —isReachableWiFi、isReachableCellular

  ```swift
      /// MARK: 是否WiFi
      /// 是否WiFi
      public var isReachableWiFi: Bool 
     
     // MARK: 是否WWAN
      /// 是否运营商网络
      public var isReachableCellular: Bool 
  ```

* 是否联网      —isReachable

  ```swift
      // MARK: 是否联网
      /// 是否联网
      public var isReachable: Bool 
  ```

* 设置默认参数     —setDefaultParameters

  ```swift
      // MARK: 设置默认参数
      /// 设置默认参数
      /// - Parameter parameters: 默认参数
      public func setDefaultParameters(_ parameters: [String: Any]?) 
  ```

* 默认header     —setGlobalHeaders

  ```swift
      // MARK: 设置全局 headers
      /// 设置全局 headers
      /// - Parameter headers:全局 headers
      public func setGlobalHeaders(_ headers: HTTPHeaders?) {
          globalHeaders = headers
      }
  ```

* 是否打印日志     —canLogging

  ```swift
  public var canLogging = false
  ```

* 取消/清空请求     -cancelRequest/cancelAllRequest

  ```swift
      /// 取消特定请求
      /// - Parameter url: 请求的地址,内部判断是否包含,请添加详细的 path
      public func cancelRequest(_ url :String)
      
          /// 清空所有请求
      public func cancelAllRequest()
  ```

* 上传/下载/普通请求   - - 所有请求都通过配置文件方式传递参数以及请求结果，通过闭包设置配置文件的属性即可，详情参看配置文件注释，用法参照`MeshRequest`。

  

  请求用例

  ```swift
      MeshManager.shared.requestWithConfig { (config) in
        config.URLString = "https://timor.tech/api/holiday/year/2021/"
        config.requestMethod = .get
      } success: { (config) in
        let dic : [String: Any] = config.response?.value as! [String : Any]
        print("\(dic["holiday"])")
      } failure: { (_) in
        print("error getHoliday")
      }
  ```
#### MeshConfig

网络请求的配置文件，用于设置请求超时时间、请求方式，参数，header，API地址，上传用的表单等等，以及请求完成回调回来的response都在里边。

```swift
/// 网络请求配置
public class MeshConfig {
    //MARK: 请求相关配置
    /// 超时配置
    public var timeout : TimeInterval = 15.0
    /// 添加请求头
    public var addHeads : HTTPHeaders?
    /// 请求方式
    public var requestMethod : HTTPMethod = .get
    /// 请求编码
    public var requestEncoding: ParameterEncoding = URLEncoding.default  //PropertyListEncoding.xml//JSONEncoding.default
    //MARK: 请求地址以及参数
    /// 请求地址
    public var URLString : String?
    ///参数  表单上传也可以用
    public var parameters : [String: Any]?
    //MARK: 请求完成返回数据
    //服务端返回参数 定义错误码 错误信息 或者 正确信息
    public var code : Int?
    public var mssage : String?

    /// AF请求下来的完整response，可自行处理
    public var response: AFDataResponse<Any>?
    //MARK: 下载
    ///下载用 设置文件下载地址覆盖方式等等
    public var destination : DownloadRequest.Destination?
    
    public var downloadType : DownloadType = .download
    public var fileURL: URL?   
    public var resumeData : Data?
```

### MeshRequest
对Post、Get网络请求的Codable封装，通过设置泛型model回调生成好的Model，方便使用。用例：
```swift
 MeshRequest<TestModel>.get(“https://api.apiopen.top/getJoke?page=1&count=2&type=video”) { (model) in
            print(model!)
        }
```

##  安装
### cocoapods导入
不需要Codable解析的可以直接`pod ‘SwiftMesh/Mesh’`

默认情况`pod ‘SwiftMesh‘`

### 手动导入
拖入代码即可

### SwiftPM

https://github.com/jackiehu/SwiftMesh

