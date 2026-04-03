![](Image/logo.png)

[![Version](https://img.shields.io/cocoapods/v/SwiftMesh.svg?style=flat)](http://cocoapods.org/pods/SwiftMesh)
[![SPM](https://img.shields.io/badge/SPM-supported-DE5C43.svg?style=flat)](https://swift.org/package-manager/)
![Xcode 11.0+](https://img.shields.io/badge/Xcode-11.0%2B-blue.svg)
![iOS 13.0+](https://img.shields.io/badge/iOS-13.0%2B-blue.svg)
![Swift 5.0+](https://img.shields.io/badge/Swift-5.0%2B-orange.svg)

SwiftMesh is a secondary encapsulation based on Alamofire and Codable, uses Combine and Swift Concurrency, supports SwiftUI and UIKit, removes closure callbacks, is more concise, faster, and more convenient to use.

The design patterns involved are: adapter, singleton, builder, and property wrapper.

## Features

- **Async/Await API** — All request methods use `async throws`, eliminating callback hell
- **Fluent/Chainable Configuration** — Builder pattern with methods like `.setRequestMethod(.get).setUrlHost("...")`
- **JSON Key Path Parsing** — Extract nested JSON values at dot-separated paths (e.g., `"data.yesterday"`)
- **File Upload** — Supports file URL, Data, InputStream, and multipart form uploads
- **File Download** — Supports standard and resumable downloads
- **Global Defaults** — Set default headers, parameters, and URL host once; they merge with per-request overrides
- **Resilient Codable** — Property wrappers (`@Default`, `@IgnoreError`, `@ConvertToString`, etc.) for handling inconsistent API responses
- **Built-in Retry Policy** — Configurable retry with linear backoff
- **Network Logging** — Built-in logger that outputs cURL commands, status codes, timing, and pretty-printed JSON
- **Combine Integration** — Works naturally with `ObservableObject` and `@Published` for reactive UI updates
- **SwiftUI + UIKit Support** — Designed for mixed development environments

## Quick Start

### 1. Basic GET Request

```swift
let result = try await Mesh()
    .setRequestMethod(.get)
    .setUrlHost("https://api.example.com")
    .setUrlPath("/weather/city/101030100")
    .request(of: Weather.self)
```

### 2. GET with JSON Key Path

Extract only a nested portion of the JSON:

```swift
// JSON: { "code": 200, "data": { "yesterday": { "temp": 25 } } }
let yesterday = try await Mesh()
    .setRequestMethod(.get)
    .setUrlHost("https://api.example.com")
    .setUrlPath("/weather")
    .request(of: Forecast.self, modelKeyPath: "data.yesterday")
```

### 3. POST with Parameters

```swift
let result = try await Mesh()
    .setRequestMethod(.post)
    .setUrlHost("https://api.example.com")
    .setUrlPath("/login")
    .setParameters(["username": "admin", "password": "123456"])
    .request(of: LoginResult.self)
```

### 4. File Download

```swift
let fileURL = try await Mesh()
    .setRequestMethod(.get)
    .setUrlHost("https://example.com")
    .setUrlPath("/files/document.pdf")
    .setDestination { _, _ in
        let dest = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("document.pdf")
        return (dest, [.removePreviousFile, .createIntermediateDirectories])
    }
    .download()
```

### 5. File Upload (Multipart)

```swift
let result = try await Mesh()
    .setRequestMethod(.post)
    .setUrlHost("https://api.example.com")
    .setUrlPath("/upload/image")
    .setUploadType(.multipart)
    .setAddformData(name: "file",
                    fileName: "photo.jpg",
                    fileData: imageData,
                    mimeType: "image/jpeg")
    .upload(of: UploadResult.self)
```

---

## Usage

#### Swift+UIKit：

```swift
import UIKit
import Combine
import SwiftMesh

class ViewController: UIViewController {
    var request = RequestModel()
    private var cancellables: Set<AnyCancellable> = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
 
        request.getAppliances()
        
        request.$cityResult
            .receive(on: RunLoop.main)
            .sink { (model) in
                print("Request Data Model \(String(describing: model))")
         }.store(in: &cancellables)
        
        request.$yesterday
            .receive(on: RunLoop.main)
            .sink { (model) in
                print("Request Data Model \(String(describing: model))")
         }.store(in: &cancellables)
    }
 
}
```

#### SwiftUI：

```swift
struct SwiftUIView: View {
    @StateObject var request = RequestModel()
    
    var body: some View {
        
        VStack{
            Text("Hello, World!")
            Text(request.cityResult?.message ?? "")
            Text(request.yesterday?.notice ?? "")
        }.onAppear{
            request.getAppliances()
        }
    }
    
}
```

---

## API Reference

### Mesh：Core Builder Class

The central configuration holder for all network requests. Supports fluent chaining.

#### Global Static Methods

| Method | Description |
|--------|-------------|
| `Mesh.enableLog(_:)` | Enable network logging (`.print` or `.log`) |
| `Mesh.setHeaders(_:)` | Set global default headers for all requests |
| `Mesh.setParameters(_:)` | Set global default parameters for all requests |
| `Mesh.setUrlHost(_:)` | Set global default URL host |

#### Instance Configuration (Chainable)

| Method | Description |
|--------|-------------|
| `.setTimeout(_:)` | Request timeout in seconds (default: 15) |
| `.setInterceptor(_:)` | Request interceptor (e.g., RetryPolicy) |
| `.setRequestMethod(_:)` | HTTP method (GET, POST, PUT, DELETE, etc.) |
| `.setHeads(_:)` | Per-request headers |
| `.setRequestEncoding(_:)` | Parameter encoding (URLEncoding, JSONEncoding) |
| `.setUrlHost(_:)` | Per-request URL host |
| `.setUrlPath(_:)` | URL path |
| `.setParameters(_:)` | Request parameters |

#### Download Configuration

| Method | Description |
|--------|-------------|
| `.setDownloadType(_:)` | `.download` or `.resume` |
| `.setDestination(_:)` | File save location and behavior |
| `.setResumeData(_:)` | Resume data from interrupted download |

#### Upload Configuration

| Method | Description |
|--------|-------------|
| `.setUploadType(_:)` | `.file`, `.data`, `.stream`, or `.multipart` |
| `.setFileURL(_:)` | File URL for upload |
| `.setFileData(_:)` | File Data for upload |
| `.setStream(_:)` | InputStream for upload |
| `.setUploadDatas(_:)` | Array of multipart form entries |
| `.setAddformData(...)` | Quick add a single form field |

### Request：Execute Requests

| Method | Description |
|--------|-------------|
| `.request(of:modelKeyPath:)` | Send request and decode to Codable model |
| `.urlRequest(_:type:modelKeyPath:)` | Send URLRequest and decode to Codable model |
| `.requestData()` | Return raw response Data |
| `.requestString()` | Return response as String |
| `.upload(of:modelKeyPath:)` | Upload file and decode response |
| `.download()` | Download file and return local URL |

### Resilient Codable Wrappers

| Wrapper | Default Behavior |
|---------|-----------------|
| `@Default.True` | Missing → `true` |
| `@Default.False` | Missing → `false` |
| `@Default.EmptyString` | Missing → `""` |
| `@Default.EmptyInt` | Missing → `0` |
| `@Default.EmptyArray` | Missing → `[]` |
| `@Default.EmptyDictionary` | Missing → `[:]` |
| `@Default.Now` | Missing → `Date()` |
| `@IgnoreError` | Invalid → `nil` (no crash) |
| `@ConvertToString` | String/Int/Double → `String?` |
| `@ConvertToInt` | Int/String/Double → `Int?` |
| `@ConvertToDouble` | Double/Int/Float/String → `Double?` |
| `@ConvertToFloat` | Float/Int/Double/String → `Float?` |

### RetryPolicy

Built-in retry with linear backoff (1s, 2s, 3s...):

```swift
let policy = RetryPolicy(maxRetryCount: 3)  // default: 3 retries
```

---

## AI Skills Guide

SwiftMesh includes a comprehensive **SKILL.md** file designed for AI coding assistants. This file serves as a complete reference that AI tools can use to generate correct SwiftMesh code.

### What is SKILL.md?

`SKILL.md` is a structured documentation file that contains:
- Complete API reference with all methods and parameters
- 16+ ready-to-use code examples covering every scenario
- Property wrapper usage patterns
- AI prompt templates for common tasks
- Error handling and configuration guides

### How AI Uses SKILL.md

When working with an AI coding assistant (like Cursor, GitHub Copilot, Claude, or ChatGPT), the AI can reference `SKILL.md` to:

1. **Understand the API** — All methods, parameters, and return types are documented
2. **Generate correct code** — Examples show the exact syntax and chaining patterns
3. **Handle edge cases** — Resilient Codable wrappers for inconsistent APIs
4. **Follow best practices** — Proper Combine integration, error handling, etc.

### Using SKILL.md with AI Assistants

#### Method 1: Reference the File Directly

Tell your AI assistant to read the SKILL.md file:

```
Read the SKILL.md file in this project and use it to generate SwiftMesh code for my request.
```

#### Method 2: Use AI Prompt Templates

The SKILL.md includes pre-built prompt templates. Copy and fill them in:

**For GET requests:**
```
Use SwiftMesh to make a GET request to https://api.example.com/weather and decode the response into a Weather struct. Use key path "data.current" to extract nested data.
```

**For file uploads:**
```
Use SwiftMesh to upload an image Data to https://api.example.com/upload with multipart form field name "photo" and MIME type "image/jpeg". Decode the response as UploadResult.
```

**For handling inconsistent APIs:**
```
Create a Codable struct for this JSON: {"code": 200, "data": {"name": "test", "count": "42"}}. Use @Default, @IgnoreError, and @ConvertTo* wrappers to handle missing or inconsistent types.
```

#### Method 3: Quick Reference Card

The SKILL.md starts with a Quick Reference Card that AI can use for fast lookups:

| Need | Use |
|------|-----|
| GET request | `.request(of: Model.self)` |
| Nested JSON | `.request(of: Model.self, modelKeyPath: "data.user")` |
| Upload file | `.upload(of: Result.self)` |
| Download file | `.download()` |
| Auto-retry | `.setInterceptor(RetryPolicy())` |
| Enable logging | `Mesh.enableLog()` |

### SKILL.md Contents Overview

| Section | Content |
|---------|---------|
| Quick Reference Card | One-line lookup for common tasks |
| Core Architecture | File structure and design patterns |
| Usage Patterns | 16 complete code examples |
| Global Configuration | App-level setup |
| Resilient Codable | All property wrappers with examples |
| JSON Key Path | Nested extraction usage |
| Combine + SwiftUI | ObservableObject patterns |
| Error Handling | Error types and catching |
| RetryPolicy | Retry configuration |
| Logging | Logger setup and output |
| Method Reference | Complete API table |
| AI Prompt Templates | Fill-in-the-blank prompts |

---

## Install

### Cocoapods

1. Add `pod 'SwiftMesh'` to Podfile
2. Execute `pod install` or `pod update`
3. Import `import SwiftMesh`

### Swift Package Manager

Starting from Xcode 11, the Swift Package Manager is integrated, which is very convenient to use. SwiftMesh also supports integration via the Swift Package Manager.

Select `File > Swift Packages > Add Package Dependency` in Xcode's menu bar, and enter in the search bar:

`https://github.com/zjinhu/SwiftMesh`, you can complete the integration and rely on Alamofire by default.

### Manual Integration

SwiftMesh also supports manual integration, just drag the SwiftMesh folder in the Sources folder into the project that needs to be integrated.

---

## More tools to speed up APP development

[![ReadMe Card](https://github-readme-stats-sigma-five.vercel.app/api/pin/?username=zjinhu&repo=SwiftBrick&theme=radical)](https://github.com/zjinhu/SwiftBrick)

[![ReadMe Card](https://github-readme-stats-sigma-five.vercel.app/api/pin/?username=zjinhu&repo=SwiftMediator&theme=radical)](https://github.com/zjinhu/SwiftMediator)

[![ReadMe Card](https://github-readme-stats-sigma-five.vercel.app/api/pin/?username=zjinhu&repo=SwiftLog&theme=radical)](https://github.com/zjinhu/SwiftLog)

[![ReadMe Card](https://github-readme-stats-sigma-five.vercel.app/api/pin/?username=zjinhu&repo=SwiftNotification&theme=radical)](https://github.com/zjinhu/SwiftNotification)
