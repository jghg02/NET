# ``NET``

<img width="60" alt="iOS" src="https://img.shields.io/badge/iOS-000000?style=for-the-badge&logo=ios&logoColor=white"> <img width="60" alt="iOS" src="https://img.shields.io/badge/mac%20os-000000?style=for-the-badge&logo=apple&logoColor=white"> <img width="70" alt="iOS" src="https://img.shields.io/badge/Swift-FA7343?style=for-the-badge&logo=swift&logoColor=white">

This library provee all the necessary logic to make a request to any API from your application. This is an implementation using ``async`` and ``await``

## Requeriments
- `iOS >= 14`
- `macOS >= 10.15`

##  Installation

Add NET Client as a dependency through Xcode or directly to Package.swift:

```
.package(url: "https://github.com/jghg02/NET", branch: "main")
```


## Usage

### Basic Usage (Original API)

```swift 
struct Recipes: Codable {
    let id: String
    let name: String
    let headline: String
    let image: String?
    let preparationMinutes: Int
}

struct RegistrationError: LocalizedError, Codable, Equatable {
    let status: Int
    let message: String
    var errorDescription: String? { message }
}
```

```swift
// Original API - still fully supported
let client = NETClient<[Recipes], RegistrationError>()
let request = NETRequest(url: URL(string: "https://example.com")!)
switch await client.request(request) {
case .success(let data):
    print(data)
case .failure(let error):
    print("Error: \(error.localizedDescription)")
}
```

### Enhanced Usage with SOLID Principles

The library now includes enhanced clients that follow SOLID principles for better maintainability, testability, and extensibility:

#### Simple Enhanced Client
```swift
let client = EnhancedNETClient<[Recipes], RegistrationError>()
let request = NETRequest(url: URL(string: "https://example.com")!)
let result = await client.request(request)
```

#### Advanced Configuration with Builder Pattern
```swift
let client = EnhancedNETClientBuilder<[Recipes], RegistrationError>()
    .with(authentication: BearerTokenAuthProvider(token: "your-api-token"))
    .enableLogging(requests: true, responses: false)
    .with(configuration: CustomNetworkConfiguration())
    .addRequestInterceptor(CustomHeaderInterceptor())
    .build()

let request = NETRequest(url: URL(string: "https://api.example.com/recipes")!)
let result = await client.request(request)
```

#### Dependency Injection for Testing
```swift
let mockLoader = MockRequestLoader()
let testConfig = TestConfiguration()

let client = EnhancedNETClient<[Recipes], RegistrationError>(
    requestLoader: mockLoader,
    configuration: testConfig
)
```

## SOLID Principles Implementation

This library demonstrates and implements all five SOLID principles:

### 🎯 **Single Responsibility Principle (SRP)**
- **ResponseParser**: Handles only data parsing
- **NetworkConfiguration**: Manages only configuration
- **AuthenticationProvider**: Handles only authentication

### 🔄 **Open/Closed Principle (OCP)**
- **RequestInterceptor**: Extend request processing without modifying core
- **ResponseInterceptor**: Extend response processing without modifying core
- **AuthenticationProvider**: Add new auth methods without changes

### 🔄 **Liskov Substitution Principle (LSP)**
- All protocol implementations can be substituted without breaking functionality
- `URLSession` correctly implements `NETRequestLoader`

### 🧩 **Interface Segregation Principle (ISP)**
- **ResponseValidator**: Focused validation interfaces
- **AuthenticationProvider**: Specific authentication interface
- **NetworkConfiguration**: Configuration-specific interface

### ⬆️ **Dependency Inversion Principle (DIP)**
- Depends on protocols, not concrete implementations
- Configurable dependency injection
- Testable through mocking

For detailed analysis and examples, see [SOLID_ANALYSIS.md](SOLID_ANALYSIS.md).

## Features

- ✅ **Backward Compatible**: Original API continues to work unchanged
- 🏗️ **Protocol-Oriented**: Easy to extend and customize
- 🧪 **Testable**: Full dependency injection support
- 🔒 **Type Safe**: Compile-time guarantees for requests and responses  
- ⚡ **Async/Await**: Modern Swift concurrency support
- 🔌 **Extensible**: Interceptors and middleware support
- 🔐 **Authentication**: Built-in auth providers (Bearer, Basic, API Key)
- 📝 **Logging**: Configurable request/response logging
- ✅ **Validation**: Flexible response validation
