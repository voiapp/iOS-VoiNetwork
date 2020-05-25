//
//  APIExampleRequest.swift
//  voi-appTests
//
//  Created by David Jangdal on 2020-01-20.
//  Copyright © 2020 Voi Technology. All rights reserved.
//

import XCTest
import VoiNetwork

public extension APIRequest {
    var deviceHeaders: [String : String]? {
        ["header1": "value1"]
    }
}

enum APIExampleRequest: APIRequest {
    case exampleRequest
    
    var baseURLPath: String { "" }
    var path: String { "" }
    var method: HTTPMethod { HTTPMethod.get }
    var requestHeaders: [String : String]? {
        ["header2": "value2"]
    }
}

public class APIExampleRequestTests: XCTestCase {
    func testDeviceHeaders() {
        let request = APIExampleRequest.exampleRequest
        XCTAssertEqual(request.deviceHeaders!.values.count, 1)
        XCTAssertEqual(request.deviceHeaders!["header1"], "value1")
        
        let urlRequest = request.urlRequest!
        XCTAssertEqual(urlRequest.allHTTPHeaderFields!.values.count, 2)
        XCTAssertEqual(urlRequest.allHTTPHeaderFields!["header1"], "value1")
    }
    
    func testRequestHeaders() {
        let request = APIExampleRequest.exampleRequest
        XCTAssertEqual(request.requestHeaders!.values.count, 1)
        XCTAssertEqual(request.requestHeaders!["header2"], "value2")
        
        let urlRequest = request.urlRequest!
        XCTAssertEqual(urlRequest.allHTTPHeaderFields!.values.count, 2)
        XCTAssertEqual(urlRequest.allHTTPHeaderFields!["header2"], "value2")
    }
}
