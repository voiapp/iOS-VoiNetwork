//
//  APIExampleRequest.swift
//  voi-appTests
//
//  Created by David Jangdal on 2020-01-20.
//  Copyright © 2020 Voi Technology. All rights reserved.
//

import XCTest
import VoiNetwork

enum APIExampleRequest: APIRequest {
    case emptyRequest
    case exampleRequest
    case exampleRequestWithEncodableBody(body: ExampleBody)
    case exampleRequestWithDictionaryBody(body: [String: Any])
    
    var baseURLPath: String {
        switch self {
        case .emptyRequest: return ""
        default:
            return "https://example.com"
        }
    }
    var path: String { "" }
    var method: HTTPMethod { HTTPMethod.get }
    var requestHeaders: [String : String]? {
        ["header2": "value2"]
    }
    
    var body: HTTPBody? {
        switch self {
        case .exampleRequest, .emptyRequest: return nil
        case .exampleRequestWithEncodableBody(let encodable): return .jsonFromEncodable(body: encodable)
        case .exampleRequestWithDictionaryBody(let dictionary): return .jsonFromDictionary(dictionary: dictionary)
        }
    }
}

extension APIExampleRequest {
    struct ExampleBody: Codable {
        let title: String
        let value: Int
        let nested: Nested
        
        struct Nested: Codable {
            let condition: Bool
        }
    }
}
