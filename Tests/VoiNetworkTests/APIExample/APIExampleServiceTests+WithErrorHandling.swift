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

    func testExampleRequestWithOutErrorHandling_ParseError_Success() {
        let expectation = XCTestExpectation()
        service.requestWithoutErrorHandling { result in
            if case .failure(let error) = result  {
                XCTAssertNotNil(error)
                XCTAssertEqual(self.dispatcher.numberOfTimesExecuteIsCalled, 1)
                XCTAssertNil(self.dispatcher.data)
            } else {
                XCTFail()
            }
            expectation.fulfill()
        }
        wait(for: [expectation], timeout:  1)
    }
    
    
    func testExampleRequestWithErrorHandling_CheckStatusCode_Fail() {
        let expectation = XCTestExpectation()
        service.requestWithErrorHandling { result in
            if case .failure(let error) = result, let error = error as? APIServiceError {
                XCTAssertEqual(error, .statusCodeNotHandled)
            } else {
                XCTFail()
            }
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1)
    }

    // MARK: Async methods

    func testExampleRequest_AsyncWithModelResponse_Succeeds() async {
        let request = APIExampleRequest.exampleRequest
        do {
            let response = try await dispatcher.execute(apiRequest: request)
            XCTAssertTrue(dispatcher.numberOfTimesExecuteIsCalled == 1)
            XCTAssertNotNil(response)
        } catch {
            XCTFail()
        }
    }

    func testExampleRequest_AsyncWithErrorResponse_Succeeds() async {
        let request = APIExampleRequest.exampleRequest
        do {
           _ = try await dispatcher.execute(apiRequest: request)
        } catch let error as APIRequestError {
            XCTAssertEqual(error, .requestMissing)
        } catch {
            XCTFail()
        }
    }

}
