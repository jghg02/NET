//
//  NETClientTest.swift
//  
//
//  Created by Josue Hernandez on 11-10-22.
//

@testable import NET
import XCTest

class NETClientTest: XCTestCase {

    @available(iOS 15.0, *)
    func test_request() async {
        let request = FakeNETRequest()
        let client = NETClient<NETEmpty, NETEmpty>(requestLoader: request)

        _ = await client.request(NETRequest(url: URL.test))

        XCTAssertEqual(request.lastLoadedRequest, URLRequest.test)
    }

    @available(iOS 15.0, *)
    func test_requestWithURL() async {
        let request = FakeNETRequest()
        let client = NETClient<NETEmpty, NETEmpty>(requestLoader: request)

        let expectedURL = URLRequest.testWithExtraProperties
        _ = await client.request(expectedURL)

        XCTAssertEqual(request.lastLoadedRequest, expectedURL)
    }

    @available(iOS 15.0, *)
    func test_request200() async throws {
        let request = FakeNETRequest()
        let client = NETClient<TestObject, NETEmpty>(requestLoader: request)

        let testObj = TestObject()
        let data = try XCTUnwrap(JSONEncoder.convertingKeysFromSnakeCase.encode(testObj))
        request.nextData = data

        let response = HTTPURLResponse(url: URL.test, statusCode: 200, httpVersion: nil, headerFields: nil)
        request.nextResponse = response

        let result = await client.request(NETRequest(url: URL.test))
        XCTAssertEqual(try? result.get().value, testObj)
    }

    @available(iOS 15.0, *)
    func test_request_fails() async {
        let request = FakeNETRequest()
        let client = NETClient<NETEmpty, NETEmpty>(requestLoader: request)

        request.nextResponse = URLResponse()

        let result = await client.request(NETRequest(url: URL.test))
        XCTAssertNotNil(result)
    }

}

// MARK: - Helper

class FakeNETRequest: NETRequestLoader {
    var nextData: Data?
    var nextResponse: URLResponse?
    var nextError: URLError?

    private(set) var lastLoadedRequest: URLRequest?

    func request(_ request: URLRequest, completion: @escaping (Data?, URLResponse?, URLError?) -> Void) {
        lastLoadedRequest = request
        completion(nextData, nextResponse, nextError)
    }

    func request(_ request: URLRequest) async throws -> (Data, URLResponse) {
        lastLoadedRequest = request
        if let error = nextError {
            throw error
        }
        return (nextData ?? Data(), nextResponse ?? HTTPURLResponse())
    }

}

// MARK: - Helper JSONDecoder
extension JSONEncoder {
    static var convertingKeysFromSnakeCase: JSONEncoder {
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        return encoder
    }
}
