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
}

public typealias APIServiceSuccessType = (statusCode: HTTPStatusCode, data: Data?)

public protocol APIServiceProtocol {
    var dispatcher: APIRequestDispatcherProtocol { get }
    
    func performRequest(_ apiRequest: APIRequest, _ completion: @escaping (Result<APIServiceSuccessType, Error>) -> Void)
    func performRequest<Response: Decodable, CustomError: Error & Decodable>(_ apiRequest: APIRequest, _ errorType: CustomError.Type, _ completion: @escaping (Result<Response, Error>) -> Void)
}

public extension APIServiceProtocol {
    func performRequest(_ apiRequest: APIRequest, _ completion: @escaping (Result<APIServiceSuccessType, Error>) -> Void) {
        NetworkActivity.start()
        self.dispatcher.execute(apiRequest: apiRequest, completion: {(data, response, error) in
            NetworkActivity.stop()
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
    
    func performRequest<Response: Decodable, CustomError: Error & Decodable>(_ apiRequest: APIRequest, _ errorType: CustomError.Type, _ completion: @escaping (Result<Response, Error>) -> Void) {
        NetworkActivity.start()
        self.dispatcher.execute(apiRequest: apiRequest, completion: {(data, response, error) in
            NetworkActivity.stop()
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let httpResponse = response as? HTTPURLResponse, let statusCode = httpResponse.httpStatusCode else {
                completion(.failure(APIServiceError.statusCodeNotHandled))
                return
            }
            
            do {
                if apiRequest.successCode == statusCode {
                    if let responseData = data {
                        let responseObject: Response = try parse(responseData)
                        completion(.success(responseObject))
                    } else {
                        completion(.failure(APIServiceError.invalidHTTPURLResponse))
                    }
                } else {
                    if let responseData = data {
                        let errorObject: CustomError = try parse(responseData)
                        completion(.failure(errorObject))
                    } else {
                        completion(.failure(APIServiceError.invalidHTTPURLResponse))
                    }
                }
            } catch (let error) {
                completion(.failure(error))
            }
        })
    }
}

extension APIServiceProtocol {
    func parse<T: Decodable>(_ data: Data, jsonDecoder: JSONDecoder = JSONDecoder()) throws -> T  {
        if T.self is String.Type {
            if let parsed = String(data: data, encoding: .utf8) as? T {
                return parsed
            } else {
                throw APIServiceError.couldNotParseToSpecifiedModel
            }
        }
        return try jsonDecoder.decode(T.self, from: data)
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
        if T.self is String.Type, let parsed = String(data: successValue.data!, encoding: .utf8) as? T {
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
