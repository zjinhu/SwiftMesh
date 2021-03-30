![](Image/logo.png)

[![Version](https://img.shields.io/cocoapods/v/SwiftMesh.svg?style=flat)](http://cocoapods.org/pods/SwiftMesh)
[![SPM](https://img.shields.io/badge/SPM-supported-DE5C43.svg?style=flat)](https://swift.org/package-manager/)
![Xcode 11.0+](https://img.shields.io/badge/Xcode-11.0%2B-blue.svg)
![iOS 11.0+](https://img.shields.io/badge/iOS-11.0%2B-blue.svg)
![Swift 5.0+](https://img.shields.io/badge/Swift-5.0%2B-orange.svg)



SwiftMesh是基于Alamofire和Codable的二次封装，使用更加方便。

涉及到的设计模式有：适配器，单例，抽象等等



## 介绍
### MeshManager：单例
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
### MeshConfig：适配器

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

### MeshRequest：解析请求
对Post、Get网络请求的Codable封装，通过设置泛型model回调生成好的Model，方便使用。用例：
```swift
 MeshRequest<TestModel>.get(“https://api.apiopen.top/getJoke?page=1&count=2&type=video”) { (model) in
            print(model!)
        }
```



## 安装

### Cocoapods

1.在 Podfile 中添加 `pod ‘SwiftMesh’`  

不需要Codable解析的可以直接`pod ‘SwiftMesh/Mesh’`

2.执行 `pod install 或 pod update`

3.导入 `import SwiftMesh`

### Swift Package Manager

从 Xcode 11 开始，集成了 Swift Package Manager，使用起来非常方便。SwiftMesh 也支持通过 Swift Package Manager 集成。

在 Xcode 的菜单栏中选择 `File > Swift Packages > Add Pacakage Dependency`，然后在搜索栏输入

`https://github.com/jackiehu/SwiftMesh`，即可完成集成，默认依赖Alamofire。

### 手动集成

SwiftMesh 也支持手动集成，只需把Sources文件夹中的SwiftMesh文件夹拖进需要集成的项目即可



## 更多砖块工具加速APP开发

[![ReadMe Card](https://github-readme-stats.vercel.app/api/pin/?username=jackiehu&repo=SwiftBrick&theme=radical&locale=cn)](https://github.com/jackiehu/SwiftBrick)

[![ReadMe Card](https://github-readme-stats.vercel.app/api/pin/?username=jackiehu&repo=SwiftMediator&theme=radical&locale=cn)](https://github.com/jackiehu/SwiftMediator)

[![ReadMe Card](https://github-readme-stats.vercel.app/api/pin/?username=jackiehu&repo=SwiftShow&theme=radical&locale=cn)](https://github.com/jackiehu/SwiftShow)

[![ReadMe Card](https://github-readme-stats.vercel.app/api/pin/?username=jackiehu&repo=SwiftLog&theme=radical&locale=cn)](https://github.com/jackiehu/SwiftLog)

[![ReadMe Card](https://github-readme-stats.vercel.app/api/pin/?username=jackiehu&repo=SwiftyForm&theme=radical&locale=cn)](https://github.com/jackiehu/SwiftyForm)

[![ReadMe Card](https://github-readme-stats.vercel.app/api/pin/?username=jackiehu&repo=SwiftEmptyData&theme=radical&locale=cn)](https://github.com/jackiehu/SwiftEmptyData)

[![ReadMe Card](https://github-readme-stats.vercel.app/api/pin/?username=jackiehu&repo=SwiftPageView&theme=radical&locale=cn)](https://github.com/jackiehu/SwiftPageView)

[![ReadMe Card](https://github-readme-stats.vercel.app/api/pin/?username=jackiehu&repo=JHTabBarController&theme=radical&locale=cn)](https://github.com/jackiehu/JHTabBarController)

[![ReadMe Card](https://github-readme-stats.vercel.app/api/pin/?username=jackiehu&repo=SwiftNotification&theme=radical&locale=cn)](https://github.com/jackiehu/SwiftNotification)

[![ReadMe Card](https://github-readme-stats.vercel.app/api/pin/?username=jackiehu&repo=SwiftNetSwitch&theme=radical&locale=cn)](https://github.com/jackiehu/SwiftNetSwitch)

[![ReadMe Card](https://github-readme-stats.vercel.app/api/pin/?username=jackiehu&repo=SwiftButton&theme=radical&locale=cn)](https://github.com/jackiehu/SwiftButton)

[![ReadMe Card](https://github-readme-stats.vercel.app/api/pin/?username=jackiehu&repo=SwiftDatePicker&theme=radical&locale=cn)](https://github.com/jackiehu/SwiftDatePicker)