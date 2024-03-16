//
//  NETClient.swift
//  
//
//  Created by Josue Hernandez on 08-10-22.
//

import Foundation

public typealias NETClientResult<N, E> = Result<NETResponse<N>, NETHTTPError<E>>
    where N: Decodable, E: LocalizedError & Decodable & Equatable

/// This is the struct to implement the request
@available(iOS 15.0, *)
public struct NETClient<N, E> where N: Decodable, E: LocalizedError & Decodable & Equatable {

    /// client a session
    private let requestLoader: NETRequestLoader

    /// Init method to inject any implementation of the RequestLoader protocol
    /// - Parameter requestLoader: This is the conforming RequestLoader protocol cobject as the default parameter will instantiate an URLSession
    public init(requestLoader: NETRequestLoader = NETConfig.requestLoader) {
        self.requestLoader = requestLoader
    }

    /// Performs a API request
    /// - Parameters:
    ///   - request:All config to use in a request
    public func request(_ request: NETRequest) async -> NETClientResult<N, E> {
        await self.request(request.asURLRequest)
    }

    /// Performs a API request which is called by any service request class.
    /// It also performs an additional task of validating the auth token and refreshing if necessary
    ///
    /// - Parameters:
    ///   - request: APIModelType which contains the info about api path, header & http method type.
    public func request(_ request: URLRequest) async -> NETClientResult<N, E> {
        do {
            let (data, response) = try await requestLoader.request(request)
            return handleResponse(response, with: data)
        } catch {
            return .failure(.failedRequest(error as? URLError))
        }
    }

    private func handleResponse<N>(_ response: URLResponse, with data: Data) -> NETClientResult<N, E> {
        guard let response = response as? HTTPURLResponse
        else { return .failure(.failedRequest(nil)) }

        if (200 ..< 300).contains(response.statusCode) {
            return handleSuccess(data, headers: response.allHeaderFields)
        } else {
            return handleFailure(data, statusCode: response.statusCode)
        }
    }

    private func handleSuccess<N, E>(_ data: Data, headers: [AnyHashable: Any]) -> NETClientResult<N, E> {
        if let value: N = parse(data) {
            return .success(NETResponse(headers: headers, value: value))
        } else {
            return .failure(.responseTypeMismatch)
        }
    }

    private func handleFailure<N, E>(_ data: Data, statusCode: Int) -> NETClientResult<N, E> {
        if let error: E = parse(data) {
            return .failure(.invalidRequest(error))
        } else {
            return .failure(.invalidResponse(statusCode))
        }
    }

    /// Method to parser the data from services
    /// - Parameter data: Data
    /// - Returns: Struc/Class with al information decoded
    private func parse<N: Decodable>(_ data: Data?) -> N? {
        guard let data else { return nil }
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = NETConfig.keyDecodingStrategy
        return try? decoder.decode(N.self, from: data)
    }
}
