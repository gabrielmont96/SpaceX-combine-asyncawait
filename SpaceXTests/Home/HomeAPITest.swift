//
//  HomeAPITest.swift
//  SpaceXTests
//
//  Created by Gabriel Monteiro Camargo da Silva - GCM on 25/01/22.
//

import Foundation
import XCTest
@testable import SpaceX

class HomeAPITests: XCTestCase {
    func testInfoAPI() {
        let info = HomeAPI.info
        
        XCTAssertEqual(info.baseURL, "https://api.spacexdata.com/")
        XCTAssertEqual(info.method, .get)
        XCTAssertNil(info.headers)
        XCTAssertEqual(info.path, "v3/info")
    }
    
    func testLaunchesAPI() {
        let launches = HomeAPI.rocketsLaunched
        
        XCTAssertEqual(launches.baseURL, "https://api.spacexdata.com/")
        XCTAssertEqual(launches.method, .get)
        XCTAssertNil(launches.headers)
        XCTAssertEqual(launches.path, "v3/launches")
    }
}
