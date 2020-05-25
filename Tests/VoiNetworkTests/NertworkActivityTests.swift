//
//  NetworkActivityTests.swift
//  voi-appTests
//
//  Created by Mayur Deshmukh on 2019-03-20.
//  Copyright © 2019 Voi Technology. All rights reserved.
//

import XCTest
@testable import VoiNetwork

class NetworkActivityTests: XCTestCase {
    
    override func setUp() {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
    
    func testSingleActivity() {
        NetworkActivity.start()
        XCTAssertEqual(NetworkActivity.activities, 1)
        
        NetworkActivity.stop()
        XCTAssertEqual(NetworkActivity.activities, 0)
    }
    
    func testMultipleParallelActivities() {
        NetworkActivity.start()
        XCTAssertEqual(NetworkActivity.activities, 1)
        
        NetworkActivity.start()
        XCTAssertEqual(NetworkActivity.activities, 2)
        
        NetworkActivity.stop()
        XCTAssertEqual(NetworkActivity.activities, 1)
        
        NetworkActivity.start()
        XCTAssertEqual(NetworkActivity.activities, 2)
        
        NetworkActivity.stop()
        XCTAssertEqual(NetworkActivity.activities, 1)
        
        NetworkActivity.stop()
        XCTAssertEqual(NetworkActivity.activities, 0)
    }
    
    func testFalseStops() {
        
        NetworkActivity.stop()
        XCTAssertEqual(NetworkActivity.activities, 0)
        
        NetworkActivity.stop()
        XCTAssertEqual(NetworkActivity.activities, 0)
        
        NetworkActivity.stop()
        XCTAssertEqual(NetworkActivity.activities, 0)
        
        NetworkActivity.start()
        XCTAssertEqual(NetworkActivity.activities, 1)
        
        NetworkActivity.stop()
        XCTAssertEqual(NetworkActivity.activities, 0)
    }
}
