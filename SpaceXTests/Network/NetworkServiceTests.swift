//
//  NetworkServiceTests.swift
//  SpaceXTests
//
//  Created by Gabriel Monteiro Camargo da Silva - GCM on 25/01/22.
//

import Foundation
import XCTest
@testable import SpaceX

class NetworkServiceTests: XCTestCase {
    var service: NetworkService<TestAPI>!
    var executor: ExecutorMock!
    
    override func setUp() {
        executor = ExecutorMock()
        service = NetworkService<TestAPI>()
        service.executor = executor
    }
    
    override func tearDown() {
        executor = nil
        service = nil
    }
    
    func testInvalidURL() async {
        let result = await service.request(target: .invalid, expecting: TestModel.self)
        switch result {
        case .failure(let error):
            XCTAssertEqual(error, .invalidURL)
        case .success:
            XCTFail("This test should be error")
        }
    }
    
    func testParseError() async {
        executor.mockedData = "parseError".data(using: .utf8)
        let result = await service.request(target: .test, expecting: TestModel.self)
        
        switch result {
        case .failure(let error):
            XCTAssertEqual(error, .parse(NSError(domain: "generic", code: 0, userInfo: nil)))
        case .success:
            XCTFail("This test should be error")
        }
    }
    
    func testAPIError() async {
        executor.mockedStatusCode = 401
        let result = await service.request(target: .test, expecting: TestModel.self)
        
        switch result {
        case .failure(let error):
            XCTAssertEqual(error, .api(statusCode: 401, message: nil))
        case .success:
            XCTFail("This test should be error")
        }
    }
    
    func testParseSuccess() async {
        executor.mockedData = "{ \"name\": \"Gabriel\" }".data(using: .utf8)
        let result = await service.request(target: .test, expecting: TestModel.self)
        
        switch result {
        case .failure:
            XCTFail("This test should be success")
        case .success(let model):
            XCTAssertEqual(model.name, "Gabriel")
        }
    }
}

private struct TestModel: Codable {
    let name: String
}
