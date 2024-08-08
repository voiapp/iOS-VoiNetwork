//
//  APIService.swift
//  voi-app
//
//  Created by David Jangdal on 2019-04-03.
//  Copyright © 2019 Voi Technology. All rights reserved.
//

import Foundation

public enum APIServiceError: Error {
    case invalidHTTPURLResponse
    case statusCodeNotHandled
    case couldNotParseToSpecifiedModel
    case dataMissingFromResponse
}

public typealias APIServiceSuccessType = (statusCode: HTTPStatusCode, data: Data?)
public struct APIServiceResponse {
    public let statusCode: HTTPStatusCode
    public let data: Data?
}

public protocol APIServiceProtocol {
    var dispatcher: APIRequestDispatcherProtocol { get }

    func performRequest(_ apiRequest: APIRequest) async throws -> APIServiceResponse

    @available(*, deprecated, message: "Please use the async version")
    func performRequest(_ apiRequest: APIRequest, _ completion: @escaping (Result<APIServiceSuccessType, Error>) -> Void)
}

public extension APIServiceProtocol {
    func performRequest(_ apiRequest: APIRequest) async throws -> APIServiceResponse {
        let response = try await dispatcher.execute(apiRequest: apiRequest)
        guard let httpResponse = response.1 as? HTTPURLResponse, let statusCode = httpResponse.httpStatusCode else {
            throw APIServiceError.invalidHTTPURLResponse
        }

        return APIServiceResponse(statusCode: statusCode, data: response.0)
    }
}

public extension APIServiceResponse {
    func parse<T: Decodable>(jsonDecoder: JSONDecoder = JSONDecoder()) throws -> T {
        guard let data = data else {
            throw APIServiceError.dataMissingFromResponse
        }

        if T.self is String.Type, let parsed = String(data: data, encoding: .utf8) as? T {
            return parsed
        }
        return try jsonDecoder.decode(T.self, from: data)
    }

    func parse<SuccessType: Decodable, ErrorType: Decodable & Error>(success: (type: SuccessType.Type, statusCode: HTTPStatusCode),
                                       error: (type: ErrorType.Type, statusCode: HTTPStatusCode),
                                                                     jsonDecoder: JSONDecoder = JSONDecoder()) throws -> SuccessType {

        if statusCode == success.statusCode {
            return try parse()
        } else if statusCode == error.statusCode {
            let error: ErrorType = try parse()
            throw error
        } else {
            throw APIServiceError.statusCodeNotHandled
        }
    }
}

//Mark: Code below is from old API with completion handlers

public extension APIServiceProtocol {
    func performRequest(_ apiRequest: APIRequest, _ completion: @escaping (Result<APIServiceSuccessType, Error>) -> Void) {
        self.dispatcher.execute(apiRequest: apiRequest, completion: {(data, response, error) in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse, let statusCode = httpResponse.httpStatusCode else {
                completion(.failure(APIServiceError.invalidHTTPURLResponse))
                return
            }
            completion(.success((statusCode, data)))
        })
    }
}

public extension Result where Success == APIServiceSuccessType {
    func parseToType<SuccessType: Decodable, ErrorType: Decodable & Error>(success: (type: SuccessType.Type, statusCode: HTTPStatusCode),
                                                                           error: (type: ErrorType.Type, statusCode: HTTPStatusCode),
                                                                           jsonDecoder: JSONDecoder = JSONDecoder(),
                                                                           completion: @escaping (Result<SuccessType, Error>) -> Void) {
        if case Result.failure(let error) = self {
            completion(.failure(error))
        }
        else if let parsed: SuccessType = self.tryParse(success.statusCode, jsonDecoder: jsonDecoder) {
            completion(.success(parsed))
        }
        else if let parsed: ErrorType = self.tryParse(error.statusCode, jsonDecoder: jsonDecoder) {
            completion(.failure(parsed))
        }
        else if isStatusCode(success.statusCode) || isStatusCode(error.statusCode) {
            completion(.failure(APIServiceError.couldNotParseToSpecifiedModel))
        }
        else {
            completion(.failure(APIServiceError.statusCodeNotHandled))
        }
    }
    
    func parseToType<Type: Decodable>(_ type: Type.Type, statusCode: HTTPStatusCode, jsonDecoder: JSONDecoder = JSONDecoder(), completion: @escaping (Result<Type, Error>) -> Void) {
        if case Result.failure(let error) = self {
            completion(.failure(error))
        }
        else if let parsed: Type = self.tryParse(statusCode, jsonDecoder: jsonDecoder) {
            completion(.success(parsed))
        }
        else if isStatusCode(statusCode) {
            completion(.failure(APIServiceError.couldNotParseToSpecifiedModel))
        }
        else {
            completion(.failure(APIServiceError.statusCodeNotHandled))
        }
    }
    
    func tryParse<T: Decodable>(_ statusCode: HTTPStatusCode, jsonDecoder: JSONDecoder = JSONDecoder()) -> T? {
        guard let successValue = try? self.get(), statusCode == successValue.statusCode, let data = successValue.data else {
            return nil
        }
        if T.self is String.Type, let parsed = String(data: data, encoding: .utf8) as? T {
            return parsed
        }
        if let parsed = try? jsonDecoder.decode(T.self, from: data) {
            return parsed
        }
        return nil
    }
    
    func isStatusCode(_ statusCode: HTTPStatusCode) -> Bool {
        guard let successValue = try? self.get() else { return false }
        return statusCode == successValue.statusCode
    }
    
    func checkStatusCode(_ statusCode: HTTPStatusCode, completion: @escaping (Result<Void, Error>) -> Void) {
        switch self {
        case .failure(let error): completion(.failure(error))
        case .success:
            if isStatusCode(statusCode) {
                completion(.success(()))
            } else {
                completion(.failure(APIServiceError.statusCodeNotHandled))
            }
        }
    }
}
