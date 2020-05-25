//
//  APIExampleServiceTests+WithoutErrorHandling.swift
//  voi-appTests
//
//  Created by David Jangdal on 2020-01-20.
//  Copyright © 2020 Voi Technology. All rights reserved.
//

import XCTest
import Foundation
import VoiNetwork

class APIExampleServiceTests_WithoutErrorHandling: XCTestCase {
    let dispatcher = MockAPIRequestDispatcher()
    var service: APIExampleServiceProtocol!
    
    override func setUp() {
        super.setUp()
        self.service = APIExampleService(dispatcher: dispatcher)
    }
    
    func testExampleRequestWithOurErrorHandling_ParseModel_Success() {
        let expectation = XCTestExpectation()
        dispatcher.data = responseModel_valid.data(using: .utf8)
        service.requestWithoutErrorHandling { result in
            switch result {
            case .failure: XCTFail()
            case .success(let model):
                XCTAssertEqual(model.name, "Example Name")
                XCTAssertEqual(model.value, 42)
            }
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1)
    }
    
    func testExampleRequestWithOurErrorHandling_ParseModel_Fail() {
        let expectation = XCTestExpectation()
        dispatcher.data = responseModel_inValid.data(using: .utf8)
        service.requestWithoutErrorHandling { result in
            if case .failure(let error) = result, let serviceError = error as? APIServiceError {
                XCTAssertEqual(serviceError, APIServiceError.couldNotParseToSpecifiedModel)
            } else {
                XCTFail()
            }
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1)
    }
    
    func testExampleRequestWithOurErrorHandling_UnhandledStatusCode_Fail() {
        let expectation = XCTestExpectation()
        dispatcher.data = responseModel_valid.data(using: .utf8)
        dispatcher.statusCode = 400
        service.requestWithoutErrorHandling { result in
            if case .failure(let error) = result, let serviceError = error as? APIServiceError {
                XCTAssertEqual(serviceError, APIServiceError.statusCodeNotHandled)
            } else {
                XCTFail()
            }
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1)
    }
    
    let responseModel_valid = """
                                {
                                    "name": "Example Name",
                                    "value": 42
                                }
                              """
    
    let responseModel_inValid = """
                                {
                                    "first_name": "Example Name",
                                    "value": 42
                                }
                                """
}
