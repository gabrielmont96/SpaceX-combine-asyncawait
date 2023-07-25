//
//  XCTextExpectation+Test.swift
//  SpaceXTests
//
//  Created by Gabriel Monteiro Camargo da Silva on 25/07/23.
//

import XCTest

extension XCTestCase {
    func wait(for expectations: [XCTestExpectation]) {
        wait(for: expectations, timeout: 1.0)
    }
}
