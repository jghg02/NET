# NET

[![iOS](https://img.shields.io/badge/iOS-14.0+-000000?style=for-the-badge&logo=ios&logoColor=white)](https://developer.apple.com/ios/)
[![macOS](https://img.shields.io/badge/macOS-12.0+-000000?style=for-the-badge&logo=apple&logoColor=white)](https://developer.apple.com/macos/)
[![Swift](https://img.shields.io/badge/Swift-5.6+-FA7343?style=for-the-badge&logo=swift&logoColor=white)](https://swift.org/)
[![Swift Package Manager](https://img.shields.io/badge/Swift%20Package%20Manager-compatible-brightgreen.svg?style=for-the-badge)](https://github.com/apple/swift-package-manager)

A modern, lightweight Swift networking library that provides all the necessary logic to make HTTP requests to any API from your application. Built with Swift's native `async` and `await` concurrency features for clean, readable asynchronous code.

## Features

- ✅ **Modern Async/Await**: Built with Swift 5.6+ concurrency features
- ✅ **Type-Safe**: Generic-based API with Codable support
- ✅ **Error Handling**: Comprehensive error types with localized descriptions
- ✅ **Flexible Configuration**: Customizable JSON encoding/decoding strategies
- ✅ **HTTP Methods**: Support for GET, POST, DELETE, and PATCH requests
- ✅ **Request/Response Bodies**: Easy JSON body encoding and response parsing
- ✅ **Header Management**: Simple header configuration
- ✅ **Lightweight**: Minimal dependencies, built on URLSession
- ✅ **Testable**: Protocol-based design for easy mocking and testing

## Requirements

- iOS 14.0+ / macOS 12.0+
- Swift 5.6+
- Xcode 13.0+

## Installation

### Swift Package Manager

Add NET as a dependency to your `Package.swift` file:

```swift
dependencies: [
    .package(url: "https://github.com/jghg02/NET", from: "1.0.0")
]
```

Or add it through Xcode:

1. Open your project in Xcode
2. Go to File → Add Package Dependencies
3. Enter the repository URL: `https://github.com/jghg02/NET`
4. Choose the version rule and add the package


## Usage

### Basic Usage

First, import the NET library:

```swift
import NET
```

### Defining Your Models

Define your response and error models that conform to `Codable`:

```swift
struct Recipe: Codable {
    let id: String
    let name: String
    let headline: String
    let image: String?
    let preparationMinutes: Int
}

struct APIError: LocalizedError, Codable, Equatable {
    let status: Int
    let message: String
    
    var errorDescription: String? { message }
}
```

### Making a GET Request

```swift
@available(iOS 15.0, *)
func fetchRecipes() async {
    let client = NETClient<[Recipe], APIError>()
    let request = NETRequest(
        url: URL(string: "https://api.example.com/recipes")!,
        method: .GET,
        headers: ["Authorization": "Bearer your-token"]
    )
    
    switch await client.request(request) {
    case .success(let response):
        print("Received \(response.value.count) recipes")
        // Access response headers if needed
        print("Response headers: \(response.headers)")
    case .failure(let error):
        print("Request failed: \(error.localizedDescription)")
    }
}
```

### Making a POST Request with Body

```swift
struct CreateRecipeRequest: Codable {
    let name: String
    let headline: String
    let preparationMinutes: Int
}

@available(iOS 15.0, *)
func createRecipe() async {
    let client = NETClient<Recipe, APIError>()
    let newRecipe = CreateRecipeRequest(
        name: "Delicious Pasta",
        headline: "A quick and tasty pasta recipe",
        preparationMinutes: 30
    )
    
    let request = NETBodyRequest(
        url: URL(string: "https://api.example.com/recipes")!,
        method: .POST,
        body: newRecipe,
        headers: ["Authorization": "Bearer your-token"]
    )
    
    switch await client.request(request) {
    case .success(let response):
        print("Recipe created: \(response.value)")
    case .failure(let error):
        print("Failed to create recipe: \(error.localizedDescription)")
    }
}
```

### Error Handling

The library provides comprehensive error handling with the `NETHTTPError` enum:

```swift
@available(iOS 15.0, *)
func handleErrors() async {
    let client = NETClient<Recipe, APIError>()
    let request = NETRequest(url: URL(string: "https://api.example.com/recipes/1")!)
    
    switch await client.request(request) {
    case .success(let response):
        print("Success: \(response.value)")
        
    case .failure(let error):
        switch error {
        case .failedRequest(let urlError):
            print("Network error: \(urlError?.localizedDescription ?? "Unknown")")
            
        case .invalidRequest(let apiError):
            print("API error: \(apiError.localizedDescription)")
            
        case .invalidResponse(let statusCode):
            print("HTTP error with status code: \(statusCode)")
            
        case .responseTypeMismatch:
            print("Response doesn't match expected type")
        }
    }
}
```

### Configuration

You can customize the JSON encoding and decoding strategies globally:

```swift
// Configure JSON key strategies (default is snake_case conversion)
NETConfig.keyDecodingStrategy = .convertFromSnakeCase
NETConfig.keyEncodingStrategy = .convertToSnakeCase

// Use a custom URLSession if needed
NETConfig.requestLoader = URLSession(configuration: .default)
```

### Supported HTTP Methods

- `GET` - Retrieve data
- `POST` - Create new resources  
- `DELETE` - Remove resources
- `PATCH` - Update existing resources

```swift
// Different HTTP methods
let getRequest = NETRequest(url: url, method: .GET)
let postRequest = NETBodyRequest(url: url, method: .POST, body: data)
let deleteRequest = NETRequest(url: url, method: .DELETE)
let patchRequest = NETBodyRequest(url: url, method: .PATCH, body: updateData)
```

## API Reference

### Core Types

#### `NETClient<N, E>`
The main client for making HTTP requests.
- `N`: The expected response type (must conform to `Decodable`)
- `E`: The expected error type (must conform to `LocalizedError`, `Decodable`, and `Equatable`)

#### `NETRequest`
Basic request configuration for requests without a body.

#### `NETBodyRequest<N>`
Request configuration for requests that include a JSON body.
- `N`: The body type (must conform to `Encodable`)

#### `NETResponse<N>`
Wrapper for successful responses containing both the parsed value and headers.

#### `NETHTTPError<N>`
Comprehensive error type covering all possible failure scenarios.

### Configuration Options

The `NETConfig` enum provides global configuration:

- `keyDecodingStrategy`: JSON key decoding strategy (default: `.convertFromSnakeCase`)
- `keyEncodingStrategy`: JSON key encoding strategy (default: `.convertToSnakeCase`)  
- `requestLoader`: Custom request loader (default: `URLSession.shared`)

## Testing

The library is designed with testability in mind. You can inject a custom `NETRequestLoader` for testing:

```swift
class MockRequestLoader: NETRequestLoader {
    // Implement mock behavior
    func request(_ request: URLRequest) async throws -> (Data, URLResponse) {
        // Return mock data
    }
}

let client = NETClient<YourType, YourError>(requestLoader: MockRequestLoader())
```

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request. For major changes, please open an issue first to discuss what you would like to change.

### Development Setup

1. Clone the repository
2. Open `Package.swift` in Xcode
3. Build and run tests

### Code Style

This project uses SwiftLint for code formatting and style consistency. Make sure your code passes SwiftLint checks before submitting.

## License

This project is available under the MIT license. See the LICENSE file for more info.

## Author

Created by [Josue Hernandez](https://github.com/jghg02)

## Support

If you have any questions or need help, please [open an issue](https://github.com/jghg02/NET/issues) on GitHub.
