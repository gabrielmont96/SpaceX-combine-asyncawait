//
//  ExecutorMock.swift
//  SpaceXTests
//
//  Created by Gabriel Monteiro Camargo da Silva - GCM on 25/01/22.
//

import Foundation
@testable import SpaceX

class ExecutorMock: Executor {
    var mockedData: Data?
    var mockedError: Error?
    var mockedStatusCode = 200
    var mockedResponseHeaders: [String: String]? = [:]
    
    func data(from url: URL) async throws -> (Data, URLResponse) {
        let urlResponse = HTTPURLResponse(url: url,
                                          statusCode: mockedStatusCode,
                                          httpVersion: nil,
                                          headerFields: mockedResponseHeaders)
        
        return (mockedData ?? Data(), urlResponse ?? URLResponse())
    }
}
