//
//  APIRequestDispatcherTests.swift
//  
//
//  Created by David Jangdal on 2020-06-02.
//

import XCTest
import VoiNetwork

class APIRequestDispatcherTests: XCTestCase {
    func testDispatcher_isAddingDeviceHeaders() {
        let expectation = XCTestExpectation(description: "")
        let headerProvider = MockDeviceHeaderProvider()
        let dispatcher = APIRequestDispatcher(deviceHeaderProvider: headerProvider)
        let service = APITestService(dispatcher: dispatcher)
        XCTAssertEqual(dispatcher.deviceHeaderProvider.deviceHeaders["aHeader"], "aValue")
        service.test { 
            XCTAssertTrue(headerProvider.headersWasCalled)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1)
    }
}

private extension APIRequestDispatcherTests {
    class MockDeviceHeaderProvider: DeviceHeaderProvider {
        var headersWasCalled = false
        var deviceHeaders: [String : String] {
            headersWasCalled = true
            return ["aHeader":"aValue"]
        }
    }
    
    enum APITestRequest: APIRequest {
        case testRequest
        var baseURLPath: String { "" }
        var path: String { "" }
        var method: HTTPMethod { HTTPMethod.get }
    }

    struct APITestService: APIServiceProtocol {
        var dispatcher: APIRequestDispatcherProtocol
        
        func test(completion: @escaping () -> Void) {
            let request = APIExampleRequest.exampleRequest
            performRequest(request) { _ in
                completion()
            }
        }
    }
}
