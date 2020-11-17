//
//  APIParser.swift
//  
//
//  Created by Dmytro Benedyk on 09.11.2020.
//

import Foundation

public protocol APIParser {
    associatedtype Response: Decodable
    associatedtype CustomError: Decodable & Error
    
    func parseData(_ result: Data?, jsonDecoder: JSONDecoder) -> Result<Decodable?, Error>
    
    var isSuccess: Bool { get }
}

public class AnyParser {
    private let parseDataBlock: (Data?, JSONDecoder) -> Result<Decodable?, Error>
    private let successBlock: () -> Bool
    private var parser: Any
    
    public init<T: APIParser>(parser: T) {
        self.parser = parser
        self.parseDataBlock = { (data, decoder) in
            return parser.parseData(data, jsonDecoder: decoder)
        }
        self.successBlock = {
            return parser.isSuccess
        }
    }
}

extension AnyParser: APIParser {
    public typealias Response = AnyResponse
    public typealias CustomError = AnyError
    
    public func parseData(_ result: Data?, jsonDecoder: JSONDecoder = JSONDecoder()) -> Result<Decodable?, Error> {
        return self.parseDataBlock(result, jsonDecoder)
    }
    
    public var isSuccess: Bool {
        get {
            return self.successBlock()
        }
    }
    
}

public final class AnyResponse: Decodable {
    public init(from decoder: Decoder) throws {
        fatalError()
    }
}

public final class AnyError: Decodable, Error {
    public init(from decoder: Decoder) throws {
        fatalError()
    }
}

public extension APIParser {
    var isSuccess: Bool {
        get {
            return true
        }
    }
    
    func parseData(_ result: Data?, jsonDecoder: JSONDecoder = JSONDecoder()) -> Result<Decodable?, Error> {
        
        func tryParse<T: Decodable>(_ data: Data, jsonDecoder: JSONDecoder = JSONDecoder()) throws -> T {
            if T.self is String.Type, let parsed = String(data: data, encoding: .utf8) as? T {
                return parsed
            }
            return try jsonDecoder.decode(T.self, from: data)
        }
        
        do {
            if isSuccess {
                if let data = result {
                    let parsed: Response = try tryParse(data, jsonDecoder: jsonDecoder)
                    return .success(parsed)
                } else {
                    return .success(nil)
                }
            } else {
                if let data = result {
                    let parsed: CustomError = try tryParse(data, jsonDecoder: jsonDecoder)
                    return .failure(parsed)
                } else {
                    return .failure(APIServiceError.couldNotParseToSpecifiedModel)
                }
            }
        }
        catch( _ ) {
            return .failure(APIServiceError.couldNotParseToSpecifiedModel)
        }
    }
    
}
