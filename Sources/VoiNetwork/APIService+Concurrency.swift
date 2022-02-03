//
//  APIService+Concurrency.swift
//  
//
//  Created by Mayur Deshmukh on 2022-02-03.
//

import Foundation

public extension APIServiceProtocol {
    func performRequest(_ apiRequest: APIRequest) async throws -> ApiSuccess {
        let (data, response) = try await dispatcher.execute(apiRequest: apiRequest)
        guard let httpResponse = response as? HTTPURLResponse,
              let statusCode = httpResponse.httpStatusCode else {
                  throw APIServiceError.invalidHTTPURLResponse
              }
        return ApiSuccess(statusCode: statusCode, data: data)
    }
}
