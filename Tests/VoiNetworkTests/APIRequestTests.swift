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
        XCTAssertEqual(urlRequest?.httpMethod, "GET")
        XCTAssertNil(urlComponents?.queryItems)
    }
    
    func testUrlRequestQueryItems_withPath_withQueryParameters() {
        let mockRequest = MockRequest.requestPathWithQueryparameters
        let urlRequest = mockRequest.urlRequest
        let urlComponents = URLComponents.init(url: urlRequest!.url!, resolvingAgainstBaseURL: true)
        XCTAssertEqual(urlRequest?.httpMethod, "POST")
        XCTAssertNotNil(urlComponents?.queryItems)
        XCTAssertEqual(urlComponents!.queryItems!.count, 2)
    }
    
    func testUrlRequestQueryItems_withPath_withoutQueryParameters_hadPropertyQueryParameters() {
        let mockRequest = MockRequest.requestPathWithoutQueryparametersButHasPropertyQueryParameters
        let urlRequest = mockRequest.urlRequest
        let urlComponents = URLComponents.init(url: urlRequest!.url!, resolvingAgainstBaseURL: true)
        XCTAssertEqual(urlRequest?.httpMethod, "PUT")
        XCTAssertNotNil(urlComponents?.queryItems)
        XCTAssertEqual(urlComponents!.queryItems!.count, 3)
    }
    
    func testRequestUsingPATCH_isCapitalised() {
        let mockRequest = MockRequest.requestUsingPATCH
        let urlRequest = mockRequest.urlRequest
        XCTAssertEqual(urlRequest?.httpMethod, "PATCH")
    }
}

enum MockRequest: APIRequest {
    case requestPathWithQueryparameters
    case requestPathWithoutQueryparameters
    case requestPathWithoutQueryparametersButHasPropertyQueryParameters
    case requestUsingPATCH
    
    var baseURLPath: String {
        switch self {
        case .requestPathWithoutQueryparameters, .requestPathWithoutQueryparametersButHasPropertyQueryParameters: return "https://example.com"
        case .requestPathWithQueryparameters, .requestUsingPATCH: return ""
        }
    }
    
    var path: String {
        switch self {
        case .requestPathWithoutQueryparameters: return "/path"
        case .requestPathWithQueryparameters, .requestPathWithoutQueryparametersButHasPropertyQueryParameters: return urlWithQueryparameters
        case .requestUsingPATCH: return ""
        }
    }
    
    var method: HTTPMethod {
        switch self {
        case .requestPathWithoutQueryparameters: return .get
        case .requestPathWithQueryparameters: return .post
        case .requestPathWithoutQueryparametersButHasPropertyQueryParameters: return .put
        case .requestUsingPATCH: return .patch
        }
    }
    
    var queryParameters: [String: String]? {
        switch self {
        case .requestPathWithoutQueryparameters, .requestPathWithQueryparameters, .requestUsingPATCH: return nil
        case .requestPathWithoutQueryparametersButHasPropertyQueryParameters: return ["key": "value"]
        }
    }
    
    private var urlWithQueryparameters: String {
        return "https://example.com/test?param1=1&param2=2"
    }
}
