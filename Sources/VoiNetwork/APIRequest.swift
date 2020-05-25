//
//  APIRequest.swift
//  voi-app
//
//  Created by David Jangdal on 2019-04-03.
//  Copyright © 2019 Voi Technology. All rights reserved.
//

import UIKit

public enum HTTPMethod: String {
    case get
    case post
    case put
    case patch
    case delete
}

public enum HTTPBody {
    case json(body: Encodable)
    case urlEncoded(body: [String: Any])
    case image(_ data: Data)
}

public protocol APIRequest {
    // Required
    var baseURLPath: String { get }
    var path: String { get }
    var method: HTTPMethod { get }
    
    //Optional
    var queryParameters: [String: String]? { get }
    var body: HTTPBody? { get }
    var deviceHeaders: [String: String]? { get }
    var requestHeaders: [String: String]? { get }
    var cachingPolicy: URLRequest.CachePolicy { get }
    
    //Computing URLRequest from above parameters
    var urlRequest: URLRequest? { get }
}

public extension APIRequest {
    var deviceHeaders: [String: String]? { return nil }
    var requestHeaders: [String: String]? { return nil }
    var queryParameters: [String: String]? { return nil }
    var body: HTTPBody? { return nil }
    var cachingPolicy: URLRequest.CachePolicy { return .reloadIgnoringLocalAndRemoteCacheData }
    
    var urlRequest: URLRequest? {
        guard var urlComponents = URLComponents(string: baseURLPath + path) else { return nil }
        
        if urlComponents.queryItems == nil || urlComponents.queryItems?.isEmpty == true {
            urlComponents.queryItems = queryParameters?.map { URLQueryItem(name: $0, value: $1) }
        } else if let queryParams = queryParameters, var queryItems = urlComponents.queryItems {
            queryItems.append(contentsOf: queryParams.map { URLQueryItem(name: $0, value: $1) })
            urlComponents.queryItems = queryItems
        }
        
        guard let url = urlComponents.url else { return nil }
        
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue.capitalized
        request.cachePolicy = cachingPolicy
        request.allHTTPHeaderFields = deviceHeaders
        requestHeaders?.forEach { (key: String, value: String) in
            request.addValue(value, forHTTPHeaderField: key)
        }
        
        switch body {
        case .json(let body):
            request.allHTTPHeaderFields?["Content-Type"] = "application/json"
            request.httpBody = try? JSONSerialization.data(withJSONObject: body, options: .prettyPrinted)
        case .urlEncoded(let body):
            request.allHTTPHeaderFields?["Content-Type"] = "application/x-www-form-urlencoded"
            request.httpBody = urlEncodedBody(from: body)
        case .image(let data):
            request.allHTTPHeaderFields?["Content-Type"] = "image/jpeg"
            request.httpBody = data
        case .none:
            break
        }
        
        return request
    }
    
    private func urlEncodedBody(from dictionary: [String: Any]) -> Data? {
        var urlComponents = URLComponents()
        urlComponents.queryItems = dictionary.map {URLQueryItem(name: $0, value: "\($1)")}
        return urlComponents.query?.data(using: .utf8)
    }
}
