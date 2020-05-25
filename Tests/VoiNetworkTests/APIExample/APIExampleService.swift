//
//  APIExampleService.swift
//  voi-appTests
//
//  Created by David Jangdal on 2020-01-20.
//  Copyright © 2020 Voi Technology. All rights reserved.
//

import XCTest
import VoiNetwork

protocol APIExampleServiceProtocol: APIServiceProtocol {
    func requestWithoutErrorHandling(completion: @escaping (Result<ExampleSuccess, Error>) -> Void)
    func requestWithErrorHandling(completion: @escaping (Result<ExampleSuccess, Error>) -> Void)
    func requestWithStringResponse(completion: @escaping (Result<String, Error>) -> Void)
}

struct APIExampleService: APIExampleServiceProtocol {
    var dispatcher: APIRequestDispatcherProtocol
    
    func requestWithoutErrorHandling(completion: @escaping (Result<ExampleSuccess, Error>) -> Void) {
        let request = APIExampleRequest.exampleRequest
        performRequest(request) { result in
            result.parseToType(ExampleSuccess.self, statusCode: .ok, completion: completion)
        }
    }
    
    func requestWithErrorHandling(completion: @escaping (Result<ExampleSuccess, Error>) -> Void) {
        let request = APIExampleRequest.exampleRequest
        performRequest(request) { result in
            result.parseToType(success: (type: ExampleSuccess.self, statusCode: .ok),
                               error: (type: ExampleError.self, statusCode: .badRequest), completion: completion)
        }
    }
    
    func requestWithStringResponse(completion: @escaping (Result<String, Error>) -> Void) {
        let request = APIExampleRequest.exampleRequest
        performRequest(request) { result in
            result.parseToType(String.self, statusCode: .ok, completion: completion)
        }
    }
}

struct ExampleSuccess: Decodable {
    let name: String
    let value: Int
}

struct ExampleError: Decodable, Error {
    let errorMessage: String
    let errorCode: Int
}
