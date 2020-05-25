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

public protocol APIRequestDispatcherProtocol {
    func execute(apiRequest: APIRequest, completion: @escaping (Data?, URLResponse?, Error?) -> Void)
}

public final class APIRequestDispatcher: APIRequestDispatcherProtocol {
    public init() {
    }
    
    public func execute(apiRequest: APIRequest, completion: @escaping (Data?, URLResponse?, Error?) -> Void) {
        guard let request = apiRequest.urlRequest else {
            completion(nil, nil, APIRequestError.requestMissing)
            return
        }
        URLSession.shared.dataTask(with: request, completionHandler: completion).resume()
    }
}
