//
//  APIExampleRequestTests.swift
//  voi-appTests
//
//  Created by David Jangdal on 2020-05-25.
//  Copyright © 2020 Voi Technology. All rights reserved.
//

import XCTest
import VoiNetwork

public class APIExampleRequestTests: XCTestCase {
    func testDeviceHeaders() {
        let request = APIExampleRequest.exampleRequest
        XCTAssertEqual(request.deviceHeaders.values.count, 1)
        XCTAssertEqual(request.deviceHeaders["header1"], "value1")
        
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
    
    func testRequestWithEncodableJSON() {
        let body = APIExampleRequest.ExampleBody(title: "foo", value: 42, nested: .init(condition: false))
        let request = APIExampleRequest.exampleRequestWithEncodableBody(body: body)
        let urlRequest = request.urlRequest
        XCTAssertNotNil(request.body)
        let decoded = try! JSONDecoder().decode(APIExampleRequest.ExampleBody.self, from: urlRequest!.httpBody!)
        XCTAssertEqual(decoded.title, body.title)
        XCTAssertEqual(decoded.value, body.value)
        XCTAssertEqual(decoded.nested.condition, body.nested.condition)
    }
    
    func testRequestWithDictionaryJSON() {
        let body: [String: Any] = ["valueString": "some string", "valueInt": 73]
        let request = APIExampleRequest.exampleRequestWithDictionaryBody(body: body)
        let urlRequest = request.urlRequest
        XCTAssertNotNil(request.body)
        let decoded = try! JSONDecoder().decode(Response.self, from: urlRequest!.httpBody!)
        XCTAssertEqual(decoded.valueString, body["valueString"] as! String)
        XCTAssertEqual(decoded.valueInt, body["valueInt"] as! Int)
        
        struct Response: Decodable {
            let valueString: String
            let valueInt: Int
        }
    }
}
