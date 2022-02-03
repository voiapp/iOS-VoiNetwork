//
//  ApiSuccess.swift
//  
//
//  Created by Mayur Deshmukh on 2022-02-03.
//

import Foundation

public struct ApiSuccess {
    public let statusCode: HTTPStatusCode
    public let data: Data
}

//MARK: Decodable parsing

public extension ApiSuccess {
    func parseToType<T: Decodable>(statusCodes: HTTPStatusCode..., jsonDecoder: JSONDecoder = JSONDecoder()) throws -> T {
        guard statusCodes.contains(statusCode) else {
            throw APIServiceError.statusCodeNotMatching
        }
        do {
            return try jsonDecoder.decode(T.self, from: data)
        } catch {
            throw APIServiceError.parsingFailed(error)
        }
    }
}
