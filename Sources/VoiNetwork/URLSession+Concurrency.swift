//
//  URLSession+Concurrency.swift
//  
//
//  Created by Mayur Deshmukh on 2022-02-03.
//

import Foundation

public enum APIResponseError: Error {
    case responseMissing
    case dataMissing
}

public extension URLSession {
    struct DataTaskCompletionTupleRepresentation {
        let data: Data?
        let response: URLResponse?
        let error: Error?
        
        public init(data: Data?,
                    response: URLResponse?,
                    error: Error?) {
            self.data = data
            self.response = response
            self.error = error
        }
        
        public func getDataAndResponse() throws -> (Data, URLResponse) {
            guard error == nil else {
                throw error!
            }
            guard let data = data else {
                throw APIResponseError.dataMissing
            }
            guard let response = response else {
                throw APIResponseError.responseMissing
            }
            return (data, response)
        }
    }
    
    func asyncData(for request: URLRequest, delegate: URLSessionTaskDelegate? = nil) async throws -> (Data, URLResponse) {
        let dataResponseError =  await withCheckedContinuation({ continuation in
            URLSession.shared.dataTask(with: request, completionHandler: { data, response, error  in
                continuation.resume(
                    returning: DataTaskCompletionTupleRepresentation(data: data,
                                                                     response: response,
                                                                     error: error)
                )
            }).resume()
        })
        return try dataResponseError.getDataAndResponse()
    }
}
