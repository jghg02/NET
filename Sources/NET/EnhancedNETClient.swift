//
//  EnhancedNETClient.swift
//  NET
//
//  Created by SOLID Principles Enhancement
//

import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

/// Enhanced HTTP client that follows SOLID principles
/// Maintains backward compatibility while providing better separation of concerns
@available(iOS 15.0, *)
public struct EnhancedNETClient<Success, Failure> where Success: Decodable, Failure: LocalizedError & Decodable & Equatable {
    
    // MARK: - Dependencies (Following DIP)
    private let requestLoader: NETRequestLoader
    private let responseParser: ResponseParser
    private let configuration: NetworkConfiguration
    private let responseValidator: ResponseValidator
    private let requestInterceptors: [RequestInterceptor]
    private let responseInterceptors: [ResponseInterceptor]
    
    // MARK: - Initialization
    
    /// Initialize with full dependency injection
    /// Addresses Dependency Inversion Principle
    public init(
        requestLoader: NETRequestLoader = URLSession.shared,
        responseParser: ResponseParser = DefaultJSONParser(),
        configuration: NetworkConfiguration = DefaultNetworkConfiguration.fromLegacyConfig,
        responseValidator: ResponseValidator = HTTPStatusValidator(),
        requestInterceptors: [RequestInterceptor] = [],
        responseInterceptors: [ResponseInterceptor] = []
    ) {
        self.requestLoader = requestLoader
        self.responseParser = responseParser
        self.configuration = configuration
        self.responseValidator = responseValidator
        self.requestInterceptors = requestInterceptors
        self.responseInterceptors = responseInterceptors
    }
    
    /// Convenience initializer for backward compatibility
    public init() {
        self.init(
            requestLoader: NETConfig.requestLoader,
            responseParser: DefaultJSONParser(
                successKeyDecodingStrategy: NETConfig.keyDecodingStrategy,
                errorKeyDecodingStrategy: NETConfig.keyDecodingStrategy
            )
        )
    }
    
    // MARK: - Public API
    
    /// Performs an API request with enhanced SOLID principles support
    /// - Parameter request: Request configuration
    /// - Returns: Result with parsed success or error response
    public func request(_ request: NETRequest) async -> NETClientResult<Success, Failure> {
        // Build URL request
        var urlRequest = request.asURLRequest
        
        // Apply default headers from configuration
        for (key, value) in configuration.defaultHeaders {
            if urlRequest.value(forHTTPHeaderField: key) == nil {
                urlRequest.setValue(value, forHTTPHeaderField: key)
            }
        }
        
        // Apply timeout
        urlRequest.timeoutInterval = configuration.requestTimeoutInterval
        
        // Apply request interceptors (OCP - Open for extension)
        for interceptor in requestInterceptors {
            urlRequest = await interceptor.intercept(urlRequest)
        }
        
        return await executeRequest(urlRequest)
    }
    
    // MARK: - Private Methods (SRP - Single Responsibility)
    
    private func executeRequest(_ request: URLRequest) async -> NETClientResult<Success, Failure> {
        do {
            let (data, response) = try await requestLoader.request(request)
            
            // Apply response interceptors (OCP - Open for extension)
            var processedData = data
            var processedResponse = response
            for interceptor in responseInterceptors {
                (processedResponse, processedData) = await interceptor.intercept(processedResponse, data: processedData)
            }
            
            return handleResponse(processedResponse, with: processedData)
        } catch {
            return .failure(.failedRequest(error as? URLError))
        }
    }
    
    private func handleResponse(_ response: URLResponse, with data: Data) -> NETClientResult<Success, Failure> {
        // Validate response using injected validator (ISP - Interface Segregation)
        guard responseValidator.isValid(response) else {
            if let httpResponse = response as? HTTPURLResponse {
                return handleFailure(data, statusCode: httpResponse.statusCode)
            } else {
                return .failure(.failedRequest(nil))
            }
        }
        
        return handleSuccess(data, response: response)
    }
    
    private func handleSuccess(_ data: Data, response: URLResponse) -> NETClientResult<Success, Failure> {
        // Use injected parser (SRP - Single Responsibility for parsing)
        if let value = responseParser.parseSuccess(data, type: Success.self) {
            let headers = (response as? HTTPURLResponse)?.allHeaderFields ?? [:]
            return .success(NETResponse(headers: headers, value: value))
        } else {
            return .failure(.responseTypeMismatch)
        }
    }
    
    private func handleFailure(_ data: Data, statusCode: Int) -> NETClientResult<Success, Failure> {
        // Use injected parser for error parsing (SRP - Single Responsibility)
        if let error = responseParser.parseError(data, type: Failure.self) {
            return .failure(.invalidRequest(error))
        } else {
            return .failure(.invalidResponse(statusCode))
        }
    }
}

// MARK: - Builder Pattern for Enhanced Configuration

@available(iOS 15.0, *)
public class EnhancedNETClientBuilder<Success, Failure> where Success: Decodable, Failure: LocalizedError & Decodable & Equatable {
    private var requestLoader: NETRequestLoader = URLSession.shared
    private var responseParser: ResponseParser = DefaultJSONParser()
    private var configuration: NetworkConfiguration = DefaultNetworkConfiguration.fromLegacyConfig
    private var responseValidator: ResponseValidator = HTTPStatusValidator()
    private var requestInterceptors: [RequestInterceptor] = []
    private var responseInterceptors: [ResponseInterceptor] = []
    
    public init() {}
    
    @discardableResult
    public func with(requestLoader: NETRequestLoader) -> Self {
        self.requestLoader = requestLoader
        return self
    }
    
    @discardableResult
    public func with(responseParser: ResponseParser) -> Self {
        self.responseParser = responseParser
        return self
    }
    
    @discardableResult
    public func with(configuration: NetworkConfiguration) -> Self {
        self.configuration = configuration
        return self
    }
    
    @discardableResult
    public func with(responseValidator: ResponseValidator) -> Self {
        self.responseValidator = responseValidator
        return self
    }
    
    @discardableResult
    public func addRequestInterceptor(_ interceptor: RequestInterceptor) -> Self {
        self.requestInterceptors.append(interceptor)
        return self
    }
    
    @discardableResult
    public func addResponseInterceptor(_ interceptor: ResponseInterceptor) -> Self {
        self.responseInterceptors.append(interceptor)
        return self
    }
    
    @discardableResult
    public func with(authentication: AuthenticationProvider) -> Self {
        let authInterceptor = AuthenticationInterceptor(authenticationProvider: authentication)
        return addRequestInterceptor(authInterceptor)
    }
    
    @discardableResult
    public func enableLogging(requests: Bool = true, responses: Bool = true) -> Self {
        let loggingInterceptor = LoggingInterceptor(logRequests: requests, logResponses: responses)
        self.requestInterceptors.append(loggingInterceptor)
        self.responseInterceptors.append(loggingInterceptor)
        return self
    }
    
    public func build() -> EnhancedNETClient<Success, Failure> {
        return EnhancedNETClient(
            requestLoader: requestLoader,
            responseParser: responseParser,
            configuration: configuration,
            responseValidator: responseValidator,
            requestInterceptors: requestInterceptors,
            responseInterceptors: responseInterceptors
        )
    }
}