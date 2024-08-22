
import XCTest
@testable import Reciplease
import Alamofire

class NetworkServiceTests: XCTestCase {
    
    var networkService: AlamofireNetworkService!
    
    override func setUp() {
        super.setUp()
        networkService = AlamofireNetworkService()
    }
    
    override func tearDown() {
        networkService = nil
        super.tearDown()
    }
    
    func testSuccessfulRequest() {
        let expectation = self.expectation(description: "Successful network request")
        
        guard let url = URL(string: "https://httpbin.org/get") else {
            XCTFail("Invalid URL")
            return
        }
        
        networkService.request(url) { result in
            switch result {
            case .success(let data):
                XCTAssertNotNil(data)
                XCTAssertGreaterThan(data.count, 0)
            case .failure(let error):
                XCTFail("Expected success, but got failure with error: \(error)")
            }
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 10, handler: nil)
    }
    
    func testFailedRequest() {
        let expectation = self.expectation(description: "Failed network request")
        
        guard let url = URL(string: "https://httpbin.org/status/404") else {
            XCTFail("Invalid URL")
            return
        }
        
        networkService.request(url) { result in
            switch result {
            case .success:
                XCTFail("Expected failure, but got success")
            case .failure(let error):
                XCTAssertNotNil(error)
            }
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 10, handler: nil)
    }
}
