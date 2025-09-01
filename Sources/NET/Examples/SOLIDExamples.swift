//
//  SOLIDExamples.swift
//  NET
//
//  Created by SOLID Principles Enhancement
//

import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

/// This file contains examples demonstrating SOLID principles improvements
/// These are demonstration examples and not part of the main library

#if DEBUG

// MARK: - Example Models

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
    let code: String?
    
    var errorDescription: String? { message }
}

// MARK: - Basic Usage Examples (Backward Compatible)

@available(iOS 15.0, *)
class BasicUsageExamples {
    
    /// Example 1: Original API (still works)
    func originalAPIExample() async {
        let client = NETClient<[Recipe], APIError>()
        let request = NETRequest(url: URL(string: "https://api.example.com/recipes")!)
        
        switch await client.request(request) {
        case .success(let response):
            print("✅ Received \(response.value.count) recipes")
        case .failure(let error):
            print("❌ Error: \(error.localizedDescription)")
        }
    }
    
    /// Example 2: Enhanced client with default configuration
    func enhancedClientBasicExample() async {
        let client = EnhancedNETClient<[Recipe], APIError>()
        let request = NETRequest(url: URL(string: "https://api.example.com/recipes")!)
        
        switch await client.request(request) {
        case .success(let response):
            print("✅ Enhanced client: Received \(response.value.count) recipes")
        case .failure(let error):
            print("❌ Enhanced client error: \(error.localizedDescription)")
        }
    }
}

// MARK: - SOLID Principles Demonstration

@available(iOS 15.0, *)
class SOLIDPrinciplesExamples {
    
    /// Example 3: Single Responsibility Principle
    /// Separate parsing logic from networking logic
    func singleResponsibilityExample() async {
        // Custom parser with different decoding strategy
        let customParser = DefaultJSONParser(
            successKeyDecodingStrategy: .useDefaultKeys,
            errorKeyDecodingStrategy: .convertFromSnakeCase
        )
        
        let client = EnhancedNETClient<[Recipe], APIError>(
            responseParser: customParser
        )
        
        let request = NETRequest(url: URL(string: "https://api.example.com/recipes")!)
        let result = await client.request(request)
        
        print("🎯 SRP: Custom parser handled response")
    }
    
    /// Example 4: Open/Closed Principle
    /// Extend functionality without modifying existing code
    func openClosedPrincipleExample() async {
        let client = EnhancedNETClientBuilder<[Recipe], APIError>()
            .with(authentication: BearerTokenAuthProvider(token: "your-api-token"))
            .enableLogging(requests: true, responses: false)
            .addRequestInterceptor(CustomHeaderInterceptor())
            .build()
        
        let request = NETRequest(url: URL(string: "https://api.example.com/recipes")!)
        let result = await client.request(request)
        
        print("🎯 OCP: Extended client with authentication and logging")
    }
    
    /// Example 5: Interface Segregation Principle
    /// Use specific interfaces for specific needs
    func interfaceSegregationExample() async {
        // Client that only validates content type, not status codes
        let contentTypeValidator = ContentTypeValidator(expectedContentType: "application/json")
        
        let client = EnhancedNETClient<[Recipe], APIError>(
            responseValidator: contentTypeValidator
        )
        
        let request = NETRequest(url: URL(string: "https://api.example.com/recipes")!)
        let result = await client.request(request)
        
        print("🎯 ISP: Client with specific content-type validation")
    }
    
    /// Example 6: Dependency Inversion Principle
    /// Depend on abstractions, not concretions
    func dependencyInversionExample() async {
        // Custom configuration
        let config = CustomConfiguration()
        
        // Custom network executor (for testing)
        let networkExecutor = MockNetworkExecutor()
        
        let client = EnhancedNETClient<[Recipe], APIError>(
            requestLoader: networkExecutor,
            configuration: config
        )
        
        let request = NETRequest(url: URL(string: "https://api.example.com/recipes")!)
        let result = await client.request(request)
        
        print("🎯 DIP: Client with injected dependencies")
    }
    
    /// Example 7: Complex Real-World Setup
    func complexRealWorldExample() async {
        let client = EnhancedNETClientBuilder<[Recipe], APIError>()
            .with(configuration: ProductionConfiguration())
            .with(authentication: BearerTokenAuthProvider(token: "prod-token"))
            .with(responseValidator: CompositeValidator(validators: [
                HTTPStatusValidator(validStatusCodes: 200...299),
                ContentTypeValidator(expectedContentType: "application/json")
            ]))
            .addRequestInterceptor(RequestTimingInterceptor())
            .addResponseInterceptor(CacheInterceptor())
            .enableLogging(requests: false, responses: true)
            .build()
        
        let request = NETRequest(url: URL(string: "https://api.example.com/recipes")!)
        let result = await client.request(request)
        
        print("🎯 Real-world: Production-ready client with all features")
    }
}

// MARK: - Custom Implementations (Examples)

struct CustomConfiguration: NetworkConfiguration {
    let successKeyDecodingStrategy: JSONDecoder.KeyDecodingStrategy = .useDefaultKeys
    let errorKeyDecodingStrategy: JSONDecoder.KeyDecodingStrategy = .convertFromSnakeCase
    let keyEncodingStrategy: JSONEncoder.KeyEncodingStrategy = .useDefaultKeys
    let requestTimeoutInterval: TimeInterval = 30.0
    let defaultHeaders: [String: String] = [
        "User-Agent": "MyApp/1.0",
        "Accept": "application/json"
    ]
}

struct ProductionConfiguration: NetworkConfiguration {
    let successKeyDecodingStrategy: JSONDecoder.KeyDecodingStrategy = .convertFromSnakeCase
    let errorKeyDecodingStrategy: JSONDecoder.KeyDecodingStrategy = .convertFromSnakeCase
    let keyEncodingStrategy: JSONEncoder.KeyEncodingStrategy = .convertToSnakeCase
    let requestTimeoutInterval: TimeInterval = 60.0
    let defaultHeaders: [String: String] = [
        "User-Agent": "ProductionApp/2.1.0",
        "Accept": "application/json",
        "X-Client-Version": "2.1.0"
    ]
}

struct CustomHeaderInterceptor: RequestInterceptor {
    func intercept(_ request: URLRequest) async -> URLRequest {
        var modifiedRequest = request
        modifiedRequest.setValue(UUID().uuidString, forHTTPHeaderField: "X-Request-ID")
        modifiedRequest.setValue("iOS", forHTTPHeaderField: "X-Platform")
        return modifiedRequest
    }
}

struct RequestTimingInterceptor: RequestInterceptor {
    func intercept(_ request: URLRequest) async -> URLRequest {
        var modifiedRequest = request
        modifiedRequest.setValue("\(Date().timeIntervalSince1970)", forHTTPHeaderField: "X-Request-Time")
        return modifiedRequest
    }
}

struct CacheInterceptor: ResponseInterceptor {
    func intercept(_ response: URLResponse, data: Data) async -> (URLResponse, Data) {
        // In a real implementation, this would cache the response
        print("📦 CacheInterceptor: Response cached")
        return (response, data)
    }
}

@available(iOS 15.0, *)
struct MockNetworkExecutor: NETRequestLoader {
    func request(_ request: URLRequest) async throws -> (Data, URLResponse) {
        // Mock successful response
        let mockData = """
        [
            {
                "id": "1",
                "name": "Mock Recipe",
                "headline": "A delicious mock recipe",
                "image": "https://example.com/image.jpg",
                "preparation_minutes": 30
            }
        ]
        """.data(using: .utf8)!
        
        let mockResponse = HTTPURLResponse(
            url: request.url!,
            statusCode: 200,
            httpVersion: nil,
            headerFields: ["Content-Type": "application/json"]
        )!
        
        return (mockData, mockResponse)
    }
}

#endif