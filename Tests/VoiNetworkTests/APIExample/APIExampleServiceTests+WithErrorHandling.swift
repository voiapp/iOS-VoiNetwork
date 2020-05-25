//
//  APIExampleServiceTest+WithErrorHandling.swift
//  voi-appTests
//
//  Created by David Jangdal on 2020-01-20.
//  Copyright © 2020 Voi Technology. All rights reserved.
//

import XCTest
import VoiNetwork

class APIExampleServiceTests_WithErrorHandling: XCTestCase {
    let dispatcher = MockAPIRequestDispatcher()
    var service: APIExampleServiceProtocol!
    
    override func setUp() {
        super.setUp()
        self.service = APIExampleService(dispatcher: dispatcher)
    }
    
    func testExampleRequestWithErrorHandling_ParseBasicModel_Successful() {
        let expectation = XCTestExpectation()
        dispatcher.data = responseModel_valid.data(using: .utf8)
        service.requestWithErrorHandling { result in
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
    
    func testExampleRequestWithErrorHandling_ParseBasicModel_Fail() {
        let expectation = XCTestExpectation()
        dispatcher.data = responseModel_inValid.data(using: .utf8)
        service.requestWithErrorHandling { result in
            if case .failure(let error) = result, let serviceError = error as? APIServiceError {
                XCTAssertEqual(serviceError, APIServiceError.couldNotParseToSpecifiedModel)
            } else {
                XCTFail()
            }
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1)
    }
    
    func testExampleRequestWithErrorHandling_ParseError_Success() {
        let expectation = XCTestExpectation()
        dispatcher.data = responseError_valid.data(using: .utf8)
        dispatcher.statusCode = 400
        service.requestWithErrorHandling { result in
            if case .failure(let error) = result, let responseError = error as? ExampleError {
                XCTAssertEqual(responseError.errorMessage, "The requested value could not be found")
                XCTAssertEqual(responseError.errorCode, 420)
            } else {
                XCTFail()
            }
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1)
    }
    
    func testExampleRequestWithErrorHandling_ParseError_Fail() {
        let expectation = XCTestExpectation()
        dispatcher.data = responseError_inValid.data(using: .utf8)
        dispatcher.statusCode = 400
        service.requestWithErrorHandling { result in
            if case .failure(let error) = result, let serviceError = error as? APIServiceError {
                XCTAssertEqual(serviceError, APIServiceError.couldNotParseToSpecifiedModel)
            } else {
                XCTFail()
            }
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1)
    }
    
    func testExampleRequestWithErrorHandling_CheckStatusCode_Fail() {
        let expectation = XCTestExpectation()
        dispatcher.data = responseError_inValid.data(using: .utf8)
        dispatcher.statusCode = 204
        service.requestWithErrorHandling { result in
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
    
    
    let responseError_valid = """
                                {
                                    "errorMessage": "The requested value could not be found",
                                    "errorCode": 420
                                }
                              """
    
    let responseError_inValid = """
                                {
                                    "error_message": "I'm not correct",
                                    "errorCode": 420
                                }
                                """
}
