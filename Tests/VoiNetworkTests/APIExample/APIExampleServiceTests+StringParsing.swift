//
//  APIExampleServiceTests+StringParsing.swift
//  voi-appTests
//
//  Created by David Jangdal on 2020-01-21.
//  Copyright © 2020 Voi Technology. All rights reserved.
//

import Foundation
import XCTest
import VoiNetwork

class APIExampleServiceTests_StringParsing: XCTestCase {
    let dispatcher = MockAPIRequestDispatcher()
    var service: APIExampleServiceProtocol!
    
    override func setUp() {
        super.setUp()
        self.service = APIExampleService(dispatcher: dispatcher)
    }
    
    func testExampleRequest_ParseString_Successful() {
        let expectation = XCTestExpectation()
        dispatcher.data = "Test String".data(using: .utf8)
        service.requestWithStringResponse { result in
            switch result {
            case .failure:
                XCTFail()
            case .success(let string):
                XCTAssertEqual(string, "Test String")
            }
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1)
    }
    
    func testExampleRequest_ParseString_Fail() {
        let expectation = XCTestExpectation()
        service.requestWithStringResponse { result in
            if case .failure(let error) = result, let serviceError = error as? APIServiceError {
                XCTAssertEqual(serviceError, APIServiceError.couldNotParseToSpecifiedModel)
            } else {
                XCTFail()
            }
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1)
    }
}
