//
//  MockAPIRequestDispatcher.swift
//  voi-appTests
//
//  Created by David Jangdal on 2019-05-22.
//  Copyright © 2019 Voi Technology. All rights reserved.
//

import Foundation
import VoiNetwork

class MockAPIRequestDispatcher: APIRequestDispatcherProtocol {
    var data: Data?
    var statusCode: Int
    var error: Error?
    var numberOfTimesExecuteIsCalled: Int = 0
    
    init(data: Data? = nil, statusCode: Int = 200, error: Error? = nil) {
        self.data = data
        self.statusCode = statusCode
        self.error = error
    }
    
    func execute(apiRequest: APIRequest, completion: @escaping (Data?, URLResponse?, Error?) -> Void) {
        numberOfTimesExecuteIsCalled += 1
        let response = HTTPURLResponse(url: apiRequest.urlRequest!.url!, statusCode: statusCode, httpVersion: nil, headerFields: nil)
        completion(data, response, error)
    }
}
