//
//  APIRequestDispatcher.swift
//  voi-app
//
//  Created by David Jangdal on 2019-04-03.
//  Copyright © 2019 Voi Technology. All rights reserved.
//

import Foundation

public enum APIRequestError: Error {
    case requestMissing
}

public protocol DeviceHeaderProvider {
    var deviceHeaders: [String: String] { get }
}

public protocol APIRequestDispatcherProtocol {
    var deviceHeaderProvider: DeviceHeaderProvider { get }
    func execute(apiRequest: APIRequest) async throws -> (Data?, URLResponse?)
    func execute(apiRequest: APIRequest, completion: @escaping (Data?, URLResponse?, Error?) -> Void)
}

public final class APIRequestDispatcher: APIRequestDispatcherProtocol {
    public var deviceHeaderProvider: DeviceHeaderProvider
    
    public init(deviceHeaderProvider: DeviceHeaderProvider) {
        self.deviceHeaderProvider = deviceHeaderProvider
    }
    
    public func execute(apiRequest: APIRequest, completion: @escaping (Data?, URLResponse?, Error?) -> Void) {
        guard var request = apiRequest.urlRequest else {
            completion(nil, nil, APIRequestError.requestMissing)
            return
        }
        request.allHTTPHeaderFields?.merge(deviceHeaderProvider.deviceHeaders, uniquingKeysWith: { (left, right) in left })
        URLSession.shared.dataTask(with: request, completionHandler: completion).resume()
    }

    public func execute(apiRequest: APIRequest) async throws -> (Data?, URLResponse?) {
        guard var request = apiRequest.urlRequest else {
            throw APIRequestError.requestMissing
        }
        request.allHTTPHeaderFields?.merge(deviceHeaderProvider.deviceHeaders, uniquingKeysWith: { (left, right) in left })
        return try await withCheckedThrowingContinuation { continuation in
            URLSession.shared.dataTask(with: request) { (data, response, error) in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }
                continuation.resume(returning: (data, response))
            }.resume()
        }
    }
}
