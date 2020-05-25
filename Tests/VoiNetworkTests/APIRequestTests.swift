//
//  APIRequestTests.swift
//  voi-appTests
//
//  Created by Nikhil Bhosale on 2020-04-28.
//  Copyright © 2020 Voi Technology. All rights reserved.
//

import XCTest
import VoiNetwork

class APIRequestTests: XCTestCase {

    func testUrlRequestQueryItems_withPath_withoutQueryParameters() {
        let mockRequest = MockRequest.requestPathWithoutQueryparameters
        let urlRequest = mockRequest.urlRequest
        let urlComponents = URLComponents.init(url: urlRequest!.url!, resolvingAgainstBaseURL: true)
        XCTAssertNil(urlComponents?.queryItems)
    }
    
    func testUrlRequestQueryItems_withPath_withQueryParameters() {
        let mockRequest = MockRequest.requestPathWithQueryparameters
        let urlRequest = mockRequest.urlRequest
        let urlComponents = URLComponents.init(url: urlRequest!.url!, resolvingAgainstBaseURL: true)
        XCTAssertNotNil(urlComponents?.queryItems)
        XCTAssertEqual(urlComponents!.queryItems!.count, 2)
    }
    
    func testUrlRequestQueryItems_withPath_withoutQueryParameters_hadPropertyQueryParameters() {
        let mockRequest = MockRequest.requestPathWithoutQueryparametersButHasPropertyQueryParameters
        let urlRequest = mockRequest.urlRequest
        let urlComponents = URLComponents.init(url: urlRequest!.url!, resolvingAgainstBaseURL: true)
        XCTAssertNotNil(urlComponents?.queryItems)
        XCTAssertEqual(urlComponents!.queryItems!.count, 3)
    }
}

enum MockRequest: APIRequest {
    case requestPathWithQueryparameters
    case requestPathWithoutQueryparameters
    case requestPathWithoutQueryparametersButHasPropertyQueryParameters
    
    var baseURLPath: String {
        switch self {
        case .requestPathWithoutQueryparameters, .requestPathWithoutQueryparametersButHasPropertyQueryParameters: return "https://example.com"
        case .requestPathWithQueryparameters: return ""
        }
    }
    
    var path: String {
        switch self {
        case .requestPathWithoutQueryparameters: return "/path"
        case .requestPathWithQueryparameters, .requestPathWithoutQueryparametersButHasPropertyQueryParameters: return urlWithQueryparameters
        }
    }
    
    var method: HTTPMethod {
        switch self {
        case .requestPathWithoutQueryparameters: return .put
        case .requestPathWithQueryparameters: return .put
        case .requestPathWithoutQueryparametersButHasPropertyQueryParameters: return .put
        }
    }
    
    var queryParameters: [String: String]? {
        switch self {
        case .requestPathWithoutQueryparameters, .requestPathWithQueryparameters: return nil
        case .requestPathWithoutQueryparametersButHasPropertyQueryParameters: return ["key": "value"]
        }
    }
    
    private var urlWithQueryparameters: String {
        return "https://example.com/test?param1=1&param2=2"
    }
}
