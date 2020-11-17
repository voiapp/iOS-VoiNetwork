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
    case exampleRequest
    case exampleRequestWithEncodableBody(body: ExampleBody)
    case exampleRequestWithDictionaryBody(body: [String: Any])
    
    var baseURLPath: String { "" }
    var path: String { "" }
    var method: HTTPMethod { HTTPMethod.get }
    var requestHeaders: [String : String]? {
        ["header2": "value2"]
    }
    
    var body: HTTPBody? {
        switch self {
        case .exampleRequest: return nil
        case .exampleRequestWithEncodableBody(let encodable): return .jsonFromEncodable(body: encodable)
        case .exampleRequestWithDictionaryBody(let dictionary): return .jsonFromDictionary(dictionary: dictionary)
        }
    }
    
    var parsersMap: [HTTPStatusCode : AnyParser] {
        get {
            return [.ok : AnyParser(parser: APIExampleParser()),
                    .badRequest: AnyParser(parser: APIExampleErrorParser()),
                    .noContent: AnyParser(parser: APIExampleErrorParser())]
        }
    }
}

final class APIExampleParser: APIParser {
    typealias Response = ExampleSuccess
    typealias CustomError = ExampleError
    var isSuccess: Bool {
        get {
            return true
        }
    }
}

final class APIExampleErrorParser: APIParser {
    typealias Response = ExampleSuccess
    typealias CustomError = ExampleError
    var isSuccess: Bool {
        get {
            return false
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
