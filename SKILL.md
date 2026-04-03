# SwiftMesh AI Skill

> A comprehensive AI reference for using SwiftMesh — an Alamofire + Codable wrapper with async/await, Combine, fluent configuration, file upload/download, JSON key path parsing, resilient Codable wrappers, and built-in logging.

---

## Quick Reference Card

| Feature | Method | Description |
|---------|--------|-------------|
| **GET Request** | `.request(of: Model.self)` | Decode response to Codable model |
| **Key Path** | `.request(of: Model.self, modelKeyPath: "data.user")` | Extract nested JSON |
| **File Upload** | `.upload(of: Result.self)` | Upload file/Data/stream/multipart |
| **File Download** | `.download()` | Download or resume download |
| **Raw Data** | `.requestData()` | Get raw response Data |
| **Raw String** | `.requestString()` | Get response as String |
| **Retry Policy** | `.setInterceptor(RetryPolicy())` | Auto-retry with backoff |
| **Logging** | `Mesh.enableLog()` | Enable network logging |

---

## Core Architecture

SwiftMesh uses a **builder pattern** on the `Mesh` class. Every configuration method returns `Self`, enabling fluent chaining. The flow is:

```
Configure (Mesh + Config) → Execute (Request/Upload/Download) → Handle (Handle)
```

### File Structure

| File | Purpose |
|------|---------|
| `Mesh.swift` | Core builder class with all properties |
| `Config.swift` | Fluent chainable setters + global config |
| `Request.swift` | async/await request execution |
| `Handle.swift` | URL construction, error handling, response processing, RetryPolicy |
| `Upload.swift` | File upload (file, data, stream, multipart) |
| `Download.swift` | File download (standard, resumable) |
| `KeyPath.swift` | JSON key path decoder for nested extraction |
| `Codable+.swift` | Resilient property wrappers (@Default, @IgnoreError, @ConvertTo*) |
| `Log.swift` | Network logger (cURL, status, timing, JSON) |

---

## Usage Patterns

### 1. Basic GET Request

```swift
let result = try await Mesh()
    .setRequestMethod(.get)
    .setUrlHost("https://api.example.com")
    .setUrlPath("/weather/city/101030100")
    .request(of: Weather.self)
```

### 2. GET with JSON Key Path Extraction

Extract only a nested portion of the JSON response without parsing the entire structure:

```swift
// JSON: { "code": 200, "data": { "yesterday": { "temp": 25, "notice": "Sunny" } } }
let yesterday = try await Mesh()
    .setRequestMethod(.get)
    .setUrlHost("https://api.example.com")
    .setUrlPath("/weather")
    .request(of: Forecast.self, modelKeyPath: "data.yesterday")
```

### 3. POST Request with Parameters

```swift
let result = try await Mesh()
    .setRequestMethod(.post)
    .setUrlHost("https://api.example.com")
    .setUrlPath("/login")
    .setParameters(["username": "admin", "password": "123456"])
    .request(of: LoginResult.self)
```

### 4. POST with JSON Encoding

```swift
let result = try await Mesh()
    .setRequestMethod(.post)
    .setUrlHost("https://api.example.com")
    .setUrlPath("/api/data")
    .setRequestEncoding(JSONEncoding.default)
    .setParameters(["key": "value"])
    .request(of: Response.self)
```

### 5. Request with Custom Headers

```swift
let result = try await Mesh()
    .setUrlHost("https://api.example.com")
    .setUrlPath("/secure/data")
    .setHeads(["Authorization": "Bearer token123"])
    .request(of: SecureData.self)
```

### 6. Request with Retry Policy

```swift
let result = try await Mesh()
    .setUrlHost("https://api.example.com")
    .setUrlPath("/unstable-api")
    .setInterceptor(RetryPolicy(maxRetryCount: 3))
    .request(of: Data.self)
```

### 7. URLRequest-based Request

When you already have a `URLRequestConvertible`:

```swift
let urlRequest = try URLRequest(url: URL(string: "https://api.example.com/data")!, method: .get)
let result = try await Mesh()
    .urlRequest(urlRequest, type: Response.self)
```

### 8. Raw Data Response

```swift
let data = try await Mesh()
    .setRequestMethod(.get)
    .setUrlHost("https://api.example.com")
    .setUrlPath("/raw")
    .requestData()
```

### 9. Raw String Response

```swift
let string = try await Mesh()
    .setRequestMethod(.get)
    .setUrlHost("https://api.example.com")
    .setUrlPath("/text")
    .requestString()
```

### 10. File Download

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

### 11. Resumable Download

```swift
let fileURL = try await Mesh()
    .setUrlHost("https://example.com")
    .setUrlPath("/files/large-file.zip")
    .setDownloadType(.resume)
    .setResumeData(savedResumeData)  // from previous interrupted download
    .download()
```

### 12. Single File Upload (URL)

```swift
let result = try await Mesh()
    .setRequestMethod(.post)
    .setUrlHost("https://api.example.com")
    .setUrlPath("/upload")
    .setUploadType(.file)
    .setFileURL(fileURL)
    .upload(of: UploadResult.self)
```

### 13. Single File Upload (Data)

```swift
let result = try await Mesh()
    .setRequestMethod(.post)
    .setUrlHost("https://api.example.com")
    .setUrlPath("/upload")
    .setUploadType(.data)
    .setFileData(imageData)
    .upload(of: UploadResult.self)
```

### 14. Multipart Form Upload

```swift
let result = try await Mesh()
    .setRequestMethod(.post)
    .setUrlHost("https://api.example.com")
    .setUrlPath("/upload/multi")
    .setUploadType(.multipart)
    .setAddformData(name: "file",
                    fileName: "photo.jpg",
                    fileData: imageData,
                    mimeType: "image/jpeg")
    .setAddformData(name: "description",
                    fileData: "My photo".data(using: .utf8))
    .upload(of: UploadResult.self)
```

### 15. Multipart with Pre-built UploadDatas

```swift
let uploads = [
    MultipleUpload.formData(name: "file1", fileName: "a.jpg", fileData: data1, mimeType: "image/jpeg"),
    MultipleUpload.formData(name: "file2", fileName: "b.pdf", fileURL: fileURL)
]

let result = try await Mesh()
    .setRequestMethod(.post)
    .setUrlHost("https://api.example.com")
    .setUrlPath("/upload/batch")
    .setUploadType(.multipart)
    .setUploadDatas(uploads)
    .setParameters(["userId": "123"])  // additional form fields
    .upload(of: BatchResult.self)
```

### 16. Custom Timeout

```swift
let result = try await Mesh()
    .setUrlHost("https://api.example.com")
    .setUrlPath("/slow-api")
    .setTimeout(60)  // 60 seconds
    .request(of: Response.self)
```

---

## Global Configuration

Set these once at app launch (e.g., in `AppDelegate`):

```swift
// Enable network logging
Mesh.enableLog(.log)  // or .print

// Set global default headers
Mesh.setHeaders(["Authorization": "Bearer token", "App-Version": "1.0"])

// Set global default parameters
Mesh.setParameters(["platform": "ios", "sdk_version": "2.0"])

// Set global URL host
Mesh.setUrlHost("https://api.example.com")
```

Then per-request configuration only needs the path:

```swift
// Uses global headers, parameters, and urlHost
let result = try await Mesh()
    .setUrlPath("/weather")
    .request(of: Weather.self)
```

---

## Resilient Codable Property Wrappers

Handle inconsistent API responses gracefully without decoding failures.

### @Default Wrappers

Provide fallback values when fields are missing or invalid:

```swift
struct Response: Codable {
    @Default.True var isEnabled: Bool              // Missing → true
    @Default.False var isDeleted: Bool             // Missing → false
    @Default.EmptyString var name: String          // Missing → ""
    @Default.EmptyInt var count: Int               // Missing → 0
    @Default.EmptyArray var tags: [String]         // Missing → []
    @Default.EmptyDictionary var meta: [String: Int] // Missing → [:]
    @Default.Now var createdAt: Date               // Missing → Date()
}
```

### @IgnoreError

Returns `nil` instead of throwing when a field fails to decode:

```swift
struct Response: Codable {
    @IgnoreError var description: String?   // Invalid type → nil (no crash)
    @IgnoreError var nested: NestedModel?   // Missing/malformed → nil
}
```

### @ConvertToString

Accepts String, Int, or Double from JSON → converts to `String?`:

```swift
struct Response: Codable {
    @ConvertToString var version: String?  // "1.0", 1, or 1.0 → "1.0", "1", "1.0"
}
```

### @ConvertToInt

Accepts Int, String, or Double from JSON → converts to `Int?`:

```swift
struct Response: Codable {
    @ConvertToInt var count: Int?  // 42, "42", or 42.9 → 42, 42, 42
}
```

### @ConvertToDouble

Accepts Double, Int, Float, or String from JSON → converts to `Double?`:

```swift
struct Response: Codable {
    @ConvertToDouble var price: Double?  // 9.99, 10, "9.99" → 9.99, 10.0, 9.99
}
```

### @ConvertToFloat

Accepts Float, Int, Double, or String from JSON → converts to `Float?`:

```swift
struct Response: Codable {
    @ConvertToFloat var rating: Float?  // 4.5, 5, "4.5" → 4.5, 5.0, 4.5
}
```

---

## JSON Key Path Decoder

Extract nested JSON values without parsing the entire response:

```swift
// JSON: { "code": 200, "data": { "list": [{ "id": 1 }, { "id": 2 }] } }

// Extract a single nested object
let firstItem = try await Mesh()
    .setRequestMethod(.get)
    .setUrlPath("/items")
    .request(of: Item.self, modelKeyPath: "data.list.0")

// The KeyPath decoder also works directly:
let decoder = JSONDecoder.default
let item = try decoder.decode(Item.self, from: jsonData, keyPath: "data.list.0")
let items = try decoder.decodeArray([Item].self, from: jsonData, keyPath: "data.list")
```

The default decoder auto-configures:
- `keyDecodingStrategy = .convertFromSnakeCase` (snake_case → camelCase)
- `dateDecodingStrategy = .iso8601`

---

## Combine + SwiftUI Integration

### ObservableObject Pattern

```swift
class RequestModel: ObservableObject {
    @MainActor @Published var weather: Weather?
    @MainActor @Published var errorMessage: String?
    
    func fetchWeather() {
        Task {
            do {
                let result = try await Mesh()
                    .setRequestMethod(.get)
                    .setUrlHost("https://api.example.com")
                    .setUrlPath("/weather")
                    .request(of: Weather.self)
                
                await MainActor.run { self.weather = result }
            } catch {
                await MainActor.run { self.errorMessage = error.localizedDescription }
            }
        }
    }
}
```

### SwiftUI Usage

```swift
struct WeatherView: View {
    @StateObject private var model = RequestModel()
    
    var body: some View {
        VStack {
            if let weather = model.weather {
                Text("\(weather.temperature)°C")
            }
            if let error = model.errorMessage {
                Text(error).foregroundColor(.red)
            }
        }
        .onAppear { model.fetchWeather() }
    }
}
```

### UIKit + Combine Usage

```swift
class ViewController: UIViewController {
    private var model = RequestModel()
    private var cancellables: Set<AnyCancellable> = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        model.$weather
            .receive(on: RunLoop.main)
            .sink { weather in
                print("Weather: \(String(describing: weather))")
            }
            .store(in: &cancellables)
        
        model.fetchWeather()
    }
}
```

---

## Error Handling

SwiftMesh normalizes common network errors into user-friendly `NSError`:

| Error Code | Description |
|------------|-------------|
| `NSURLErrorNotConnectedToInternet` | No internet connection |
| `NSURLErrorTimedOut` | Request timeout |
| `NSURLErrorCannotFindHost` | Host not found |
| `NSURLErrorCannotConnectToHost` | Cannot connect to host |
| `NSURLErrorNetworkConnectionLost` | Connection lost during request |

All normalized errors return the message: `"Unable to connect to the server"`

Catch errors in your async code:

```swift
do {
    let result = try await Mesh()
        .setUrlPath("/api")
        .request(of: Response.self)
} catch let error as NSError {
    print("Error \(error.code): \(error.localizedDescription)")
}
```

---

## RetryPolicy

Built-in retry with linear backoff (1s, 2s, 3s...):

```swift
// Default: 3 retries
let policy = RetryPolicy()

// Custom: 5 retries
let policy = RetryPolicy(maxRetryCount: 5)

// Use with request
let result = try await Mesh()
    .setUrlPath("/unstable-api")
    .setInterceptor(policy)
    .request(of: Response.self)
```

---

## Logging

Enable at app launch:

```swift
// Using Apple's unified Logger (os.log)
Mesh.enableLog(.log)

// Using Swift print()
Mesh.enableLog(.print)
```

Output includes:
- cURL command (for easy reproduction)
- HTTP status code
- Elapsed time
- Pretty-printed JSON response

---

## Configuration Method Reference

All methods are chainable (return `Self`):

### Basic Configuration
| Method | Type | Description |
|--------|------|-------------|
| `.setTimeout(_:)` | `TimeInterval` | Request timeout in seconds (default: 15) |
| `.setInterceptor(_:)` | `RequestInterceptor?` | Retry policy / credential handler |
| `.setRequestMethod(_:)` | `HTTPMethod` | GET, POST, PUT, DELETE, etc. |
| `.setHeads(_:)` | `[String: String]` | Per-request headers |
| `.setRequestEncoding(_:)` | `ParameterEncoding` | URLEncoding, JSONEncoding, etc. |
| `.setUrlHost(_:)` | `String?` | Per-request URL host |
| `.setUrlPath(_:)` | `String?` | URL path |
| `.setParameters(_:)` | `[String: Any]?` | Request parameters |

### Download Configuration
| Method | Type | Description |
|--------|------|-------------|
| `.setDownloadType(_:)` | `DownloadType` | `.download` or `.resume` |
| `.setDestination(_:)` | `DownloadRequest.Destination` | File save location |
| `.setResumeData(_:)` | `Data?` | Resume data from interrupted download |

### Upload Configuration
| Method | Type | Description |
|--------|------|-------------|
| `.setUploadType(_:)` | `UploadType` | `.file`, `.data`, `.stream`, `.multipart` |
| `.setFileURL(_:)` | `URL?` | File URL for upload |
| `.setFileData(_:)` | `Data?` | File data for upload |
| `.setStream(_:)` | `InputStream?` | Input stream for upload |
| `.setUploadDatas(_:)` | `[MultipleUpload]` | Multipart form entries |
| `.setAddformData(name:fileName:fileData:fileURL:mimeType:)` | Multiple | Quick add form field |

### Global Static Methods
| Method | Description |
|--------|-------------|
| `Mesh.enableLog(_:)` | Enable network logging |
| `Mesh.setHeaders(_:)` | Set global default headers |
| `Mesh.setParameters(_:)` | Set global default parameters |
| `Mesh.setUrlHost(_:)` | Set global default URL host |

---

## Enums Reference

### DownloadType
| Case | Description |
|------|-------------|
| `.download` | Standard download |
| `.resume` | Resumable download (requires `resumeData`) |

### UploadType
| Case | Description |
|------|-------------|
| `.file` | Upload from file URL |
| `.data` | Upload from Data object |
| `.stream` | Upload from InputStream |
| `.multipart` | Multipart form upload |

### LogType
| Case | Description |
|------|-------------|
| `.print` | Output via Swift `print()` |
| `.log` | Output via Apple `os.log` |

---

## AI Prompt Templates

When using an AI coding assistant, use these templates:

### "Make a GET request"
```
Use SwiftMesh to make a GET request to {URL} and decode the response into a {Model} struct. Use key path "{keyPath}" to extract nested data.
```

### "Upload a file"
```
Use SwiftMesh to upload a {file/data/stream} to {URL} with multipart form field name "{name}" and MIME type "{mimeType}". Decode the response as {Model}.
```

### "Download a file"
```
Use SwiftMesh to download a file from {URL} and save it to {destination}. Use resumable download if needed.
```

### "Handle inconsistent API types"
```
Create a Codable struct for this JSON: {json}. Use @Default, @IgnoreError, and @ConvertTo* wrappers to handle missing or inconsistent types.
```
