//
//  FailableDecodableTests.swift
//  VoiNetworkTests
//
//  Created by Mayur Deshmukh on 2020-10-14.
//

import XCTest
@testable import VoiNetwork

final class ApiTestService {}

extension ApiTestService {
    struct TestEndpoint {
        struct ResponseBody: Decodable {
            private let failableData: [FailableDecodable<TestItem>]
            
            var data: [TestItem] {
                return failableData.compactMap { $0.base }
            }
            
            enum CodingKeys: String, CodingKey {
                case failableData = "data"
            }
            
            struct TestItem: Decodable {
                let id: String
                let name: String
                let discount: Double?
                private let failableTags: [FailableDecodable<String>]?
                
                enum CodingKeys: String, CodingKey {
                    case id
                    case name
                    case discount
                    case failableTags = "tags"
                }
                
                var tags: [String]? {
                    return failableTags?.compactMap { $0.base }
                }
            }
        }
    }
}

let testStrJson = """
{
  "data": [
    {
      "id": "a8f50a28-0e61-11eb-adc1-0242ac120002",
      "name": "Valid Item with discount",
      "discount": 0.15,
      "tags": [
        "Valid",
        "Discount",
        "Valid tags"
      ]
    },
    {
      "id": "a8f50a28-0e61-11eb-adc1-0242ac120003",
      "name": "Valid Item without discount",
      "tags": [
        "Valid",
        "Some invalid tags",
        99,
        true
      ]
    },
    {
      "id": "a8f50a28-0e61-11eb-adc1-0242ac120007",
      "name": "Valid Item without discount",
      "tags": [
        99,
        true
      ]
    },
    {
      "id": "a8f50a28-0e61-11eb-adc1-0242ac120004",
      "name": "Valid Item without discount"
    },
    {
      "ide": "a8f50a28-0e61-11eb-adc1-0242ac120005",
      "name": "Invalid Item with discount",
      "discount": 0.25
    },
    {
      "name": "Invalid Item without discount"
    }
  ]
}
"""

let testData = testStrJson.data(using: .utf8)!

class FailableDecodableTests: XCTestCase {

    func testDecodingEntitiesContainingFailableDecodables() throws {
        //If decoding fails, the test function will throw and test will fail.
        let responseBody: ApiTestService.TestEndpoint.ResponseBody = try JSONDecoder().decode(ApiTestService.TestEndpoint.ResponseBody.self, from: testData)
        
        XCTAssertEqual(responseBody.data.count, 4) // 4 valid `TestItems` are received
        XCTAssertEqual(responseBody.data[0].tags!.count, 3) // First test item contains all 3 valid tags
        XCTAssertEqual(responseBody.data[1].tags!.count, 2) // Second test item contains 2 valid tags, the 2 invalid tags are filtered
        XCTAssertEqual(responseBody.data[2].tags!.count, 0) // Third test item contains 0 valid tags, the 2 invalid tags are filtered
        XCTAssertNil(responseBody.data[3].tags) // Fourth test item has Optional<Nil> valid tags
    }

}
