//
//  FindYourOnlysTests.swift
//  FindYourOnlysTests
//
//  Created by 鄭昭韋 on 2022/5/20.
//

import XCTest
@testable import FindYourOnlys

class FindYourOnlysTests: XCTestCase {
    
    var sut: URLSession!

    override func setUpWithError() throws {
        try super.setUpWithError()
        
        sut = URLSession(configuration: .default)
    }

    override func tearDownWithError() throws {
        
        sut = nil
        
        try super.tearDownWithError()
    }
    
    func testApiCallsComplete() throws {
        
        let networkMonitor = NetworkMonitor.shared
        
        try XCTSkipUnless(
            networkMonitor.isReachable,
            "Network connnectivity needed for this test."
        )
        
        let url = URL(string: "https://data.coa.gov.tw/Service/OpenData/TransService.aspx?UnitId=QcbUEzN6E6DL&$top=10&$skip=0")!
        
        var statusCode: Int?
        
        var responseError: Error?
        
        let promise = expectation(description: "The completion handler is invoked.")
        
        let dataTask = sut.dataTask(with: url) { _, response, error in
            
            statusCode = (response as? HTTPURLResponse)?.statusCode
            
            responseError = error
            
            promise.fulfill()
        }
        
        dataTask.resume()
        
        XCTAssertNil(responseError)
        
        XCTAssertEqual(statusCode, 200)
    }

    func testValidApiCallGetsHTTPStatusCode200() throws {
      
      let networkMonitor = NetworkMonitor.shared

      try XCTSkipUnless(
        networkMonitor.isReachable,
        "Network connectivity needed for this test."
      )

      // given
      let urlString =
        "https://data.coa.gov.tw/Service/OpenData/TransService.aspx?UnitId=QcbUEzN6E6DL&$top=10&$skip=0"
        
      let url = URL(string: urlString)!
        
      // 1
      let promise = expectation(description: "Status code: 200")

      // when
      let dataTask = sut.dataTask(with: url) { _, response, error in
        // then
        if
            let error = error {
            
          XCTFail("Error: \(error.localizedDescription)")
            
          return
            
        } else if
            let statusCode = (response as? HTTPURLResponse)?.statusCode {
            
          if statusCode == 200 {
              
            // 2
            promise.fulfill()
              
          } else {
              
            XCTFail("Status code: \(statusCode)")
          }
        }
      }
        
      dataTask.resume()
      // 3
      wait(for: [promise], timeout: 5)
    }
}
