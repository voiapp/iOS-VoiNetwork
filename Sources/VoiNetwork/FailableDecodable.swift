//
//  FailableDecodable.swift
//  voi-app
//
//  Created by Mayur Deshmukh on 2020-02-20.
//  Copyright © 2020 Voi Technology. All rights reserved.
//

import Foundation

/// `FailableDecodable` helps us not fail when we have an array of Decodable elements. When we try to decode a JSON data containing one or more corrupt JSON objects in an array, we do not want to fail the entire main decodable. Hence we should use this helper class wherever we have arrays in Decodables, and filter out the failed objects using `compactMap()`
public struct FailableDecodable<Base: Decodable>: Decodable {

    let base: Base?

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        self.base = try? container.decode(Base.self)
    }
}
