//
//  HomeViewModelTests.swift
//  SpaceXTests
//
//  Created by Gabriel Monteiro Camargo da Silva - GCM on 25/01/22.
//

import XCTest
@testable import SpaceX
import Combine

class HomeViewModelTests: XCTestCase {
    var viewModel: HomeViewModel!
    var executor: ExecutorMock!
    
    override func setUp() {
        executor = ExecutorMock()
        let service = NetworkService<HomeAPI>()
        service.executor = executor
        viewModel = HomeViewModel(service: service)
    }
    
    override func tearDown() {
        viewModel = nil
        executor = nil
    }
    
    func testInfoDataWithSuccess() {
        let infoDataExpectation = XCTestExpectation(description: "waiting for info request")
        let expectedText = "SpaceX was founded by Elon Musk in 2002. It has now 7000 employees, " +
        "3 launch sites, and is valued at USD $10,000.00."
        
        // Given
        let data = """
        {
            "name": "SpaceX",
            "founder": "Elon Musk",
            "founded": 2002,
            "employees": 7000,
            "launch_sites": 3,
            "valuation": 10000
         }
        """.data(using: .utf8)
        executor.mockedData = data
        
        let cancellableBag = viewModel.$infoText
            .receive(on: DispatchQueue.global(qos: .background))
            .sink { text in
            // Then
            if text == expectedText {
                infoDataExpectation.fulfill()
            }
        }
        
        // When
        Task {
            await viewModel.fetchInfo()
        }
        
        wait(for: [infoDataExpectation])
        cancellableBag.cancel()
    }
    
    func testInfoDataWithAPIError() {
        let errorExpectation = XCTestExpectation(description: "waiting for request error")
        let errorMessage = "test error"
        
        // Given
        executor.mockedData = errorMessage.data(using: .utf8)
        executor.mockedStatusCode = 500
        
        let cancellableBag = viewModel.$error
            .receive(on: DispatchQueue.global(qos: .background))
            .sink { error in
            // Then
            if case let .api(statusCode, message) = error {
                XCTAssertEqual(statusCode, 500)
                XCTAssertEqual(message, errorMessage)
                errorExpectation.fulfill()
            }
        }
        
        // When
        Task {
            await viewModel.fetchInfo()
        }
        
        wait(for: [errorExpectation])
        cancellableBag.cancel()
    }
    
    func testLaunchesDataWithSuccess() {
        let rocketsLaunchedExpectation = XCTestExpectation(description: "waiting for launch request")
        
        let missionName = "FalconSat"
        let launchYear = "2006"
        let launchDate = 1143239400
        let rocketName = "Falcon 1"
        let rocketType = "Merlin A"
        let smallImagePath = "smallImage"
        let wikipediaLink = "wikipediaLink"
        let videoLink = "videoLink"
        let articleLink = "articleLink"
        
        // Given
        let data =
        """
        [
            {
                "mission_name": "FalconSat",
                "launch_year": "2006",
                "launch_date_unix": 1143239400,
                "rocket": {
                    "rocket_name": "Falcon 1",
                    "rocket_type": "Merlin A"
                },
                "launch_success": false,
                "links": {
                    "mission_patch_small": "smallImage",
                    "article_link": "articleLink",
                    "wikipedia": "wikipediaLink",
                    "video_link": "videoLink"
                }
            }
        ]
        """.data(using: .utf8)
        executor.mockedData = data
        
        let cancellableBag = viewModel.$rocketsLaunched
            .receive(on: DispatchQueue.global(qos: .background))
            .sink { [weak self] _ in
            // Then
            if (self?.viewModel.rocketsLaunched.count ?? 0) > 0 {
                XCTAssertEqual(self?.viewModel.rocketsLaunched.count, 1)
                XCTAssertEqual(self?.viewModel.getRocket(for: 0).missionName, missionName)
                XCTAssertEqual(self?.viewModel.getRocket(for: 0).launchYear, launchYear)
                XCTAssertEqual(self?.viewModel.getRocket(for: 0).launchDate, launchDate)
                XCTAssertEqual(self?.viewModel.getRocket(for: 0).rocket.rocketName, rocketName)
                XCTAssertEqual(self?.viewModel.getRocket(for: 0).rocket.rocketType, rocketType)
                XCTAssertFalse(self?.viewModel.getRocket(for: 0).launchSuccess ?? true)
                XCTAssertEqual(self?.viewModel.getRocket(for: 0).links.smallImage, smallImagePath)
                XCTAssertEqual(self?.viewModel.getRocket(for: 0).links.wikipediaLink, wikipediaLink)
                XCTAssertEqual(self?.viewModel.getRocket(for: 0).links.videoLink, videoLink)
                XCTAssertEqual(self?.viewModel.getRocket(for: 0).links.articleLink, articleLink)
                rocketsLaunchedExpectation.fulfill()
            }
        }
        
        // When
        Task {
            await viewModel.fetchRocketsLaunched()
        }
        
        wait(for: [rocketsLaunchedExpectation])
        cancellableBag.cancel()
    }

    func testLaunchesDataWithAPIError() {
        let errorExpectation = XCTestExpectation(description: "waiting for request error")
        let errorMessage = "test error"
        
        // Given
        executor.mockedData = errorMessage.data(using: .utf8)
        executor.mockedStatusCode = 404
        
        let cancellableBag = viewModel.$error
            .receive(on: DispatchQueue.global(qos: .background))
            .sink { error in
            // Then
            if case let .api(statusCode, message) = error {
                XCTAssertEqual(statusCode, 404)
                XCTAssertEqual(message, errorMessage)
                errorExpectation.fulfill()
            }
        }
        
        // When
        Task {
            await viewModel.fetchRocketsLaunched()
        }
        
        wait(for: [errorExpectation])
        cancellableBag.cancel()
    }
    
    func testOpenDetail() {
        let rocketsLaunchedExpectation = XCTestExpectation(description: "waiting for launch request")
        let rocketDetailExpectation = XCTestExpectation(description: "waiting for open detail delegate")
        
        // Given
        let data =
        """
        [
            {
                "mission_name": "FalconSat",
                "launch_year": "2006",
                "launch_date_unix": 1143239400,
                "rocket": {
                    "rocket_name": "Falcon 1",
                    "rocket_type": "Merlin A"
                },
                "launch_success": false,
                "links": {
                    "mission_patch": "largeImage",
                    "mission_patch_small": "smallImage",
                    "article_link": "articleLink",
                    "wikipedia": "wikipediaLink",
                    "video_link": "videoLink"
                }
            }
        ]
        """.data(using: .utf8)
        executor.mockedData = data
        
        let rocketsLaunchedCancellableBag = viewModel.$rocketsLaunched
            .receive(on: DispatchQueue.global(qos: .background))
            .sink { value in
            if value.count > 0 {
                rocketsLaunchedExpectation.fulfill()
            }
        }
        
        let selectedRocketCancellableBag = viewModel.$selectedRocket
            .receive(on: DispatchQueue.global(qos: .background))
            .sink { value in
            if value != nil {
                rocketDetailExpectation.fulfill()
            }
        }
        
        // When // Then
        Task {
            await viewModel.fetchRocketsLaunched()
            viewModel.openDetails(index: 0)
        }
        
        wait(for: [rocketsLaunchedExpectation, rocketDetailExpectation])
        rocketsLaunchedCancellableBag.cancel()
        selectedRocketCancellableBag.cancel()
    }
}
